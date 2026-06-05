import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/laptop_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import '../laptops/laptop_form_screen.dart';
import '../laptops/laptop_list_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<UserModel> _users = [];
  bool _loadingUsers = false;
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loadingUsers = true);
    try {
      _users = await _api.getAllUsers();
    } catch (_) {}
    setState(() => _loadingUsers = false);
  }

  @override
  Widget build(BuildContext context) {
    final laptops = context.watch<LaptopProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.admin_panel_settings, color: AppTheme.adminBadge, size: 20),
            const SizedBox(width: 8),
            const Text('Admin Dashboard'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await laptops.loadLaptops();
          await _loadUsers();
        },
        color: AppTheme.accent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin Welcome
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.verified_user, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Admin Panel', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text(auth.user?.name ?? 'Admin', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                          const Text('Full system access granted', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.shield, color: Colors.white54, size: 36),
                  ],
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 24),

              // Stats Grid
              Text('Overview', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(label: 'Total Laptops', value: '${laptops.laptops.length}', icon: Icons.laptop_mac, color: AppTheme.accent, subtitle: 'in database'),
                  _StatCard(label: 'Total Users', value: '${_users.length}', icon: Icons.people, color: AppTheme.success, subtitle: 'registered'),
                  _StatCard(label: 'Brands', value: '${laptops.brands.length}', icon: Icons.category, color: AppTheme.accentGold, subtitle: 'available'),
                  _StatCard(label: 'Featured', value: '${laptops.featuredLaptops.length}', icon: Icons.star, color: AppTheme.adminBadge, subtitle: 'highlighted'),
                ],
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 28),

              // Quick Actions
              Text('Quick Actions', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.add_box,
                      label: 'Add Laptop',
                      color: AppTheme.accent,
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const LaptopFormScreen()));
                        if (context.mounted) laptops.loadLaptops();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.list_alt,
                      label: 'Manage Laptops',
                      color: AppTheme.accentGold,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LaptopListScreen())),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 250.ms),
              const SizedBox(height: 28),

              // Users Module Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Users Module', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  IconButton(onPressed: _loadUsers, icon: const Icon(Icons.refresh, color: AppTheme.accent)),
                ],
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 12),

              _loadingUsers
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                  : _users.isEmpty
                      ? const Center(child: Text('No users found', style: TextStyle(color: AppTheme.textSecondary)))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return _UserTile(
                              user: user,
                              currentUserId: auth.user?.id,
                              onEdit: () => _showEditUserDialog(context, user),
                              onDelete: user.id != auth.user?.id ? () => _confirmDeleteUser(context, user) : null,
                            ).animate().fadeIn(delay: (50 * index).ms);
                          },
                        ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, UserModel user) {
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    String role = user.role;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppTheme.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit User', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(nameCtrl, 'Name', Icons.person),
                const SizedBox(height: 12),
                _dialogField(emailCtrl, 'Email', Icons.email),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: role,
                  dropdownColor: AppTheme.surfaceLight,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.divider)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.divider)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User', style: TextStyle(color: AppTheme.textPrimary))),
                    DropdownMenuItem(value: 'admin', child: Text('Admin', style: TextStyle(color: AppTheme.adminBadge))),
                  ],
                  onChanged: (v) => setState(() => role = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _api.updateUser(user.id, {'name': nameCtrl.text, 'email': emailCtrl.text, 'role': role});
                _loadUsers();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary),
        filled: true,
        fillColor: AppTheme.surfaceLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.accent, width: 2)),
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete User', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Delete "${user.name}"?', style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _api.deleteUser(user.id);
              _loadUsers();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, subtitle;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
          Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700))),
            Icon(Icons.arrow_forward_ios, color: color, size: 14),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final int? currentUserId;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  const _UserTile({required this.user, this.currentUserId, required this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = user.id == currentUserId;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isCurrentUser ? AppTheme.accent.withOpacity(0.4) : AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: user.isAdmin ? AppTheme.adminBadge.withOpacity(0.2) : AppTheme.accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: user.isAdmin ? AppTheme.adminBadge : AppTheme.accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                        child: const Text('You', style: TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                Text(user.email, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: user.isAdmin ? AppTheme.adminBadge.withOpacity(0.15) : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              user.role.toUpperCase(),
              style: TextStyle(color: user.isAdmin ? AppTheme.adminBadge : AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, color: AppTheme.accent, size: 18)),
          if (onDelete != null)
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outlined, color: AppTheme.error, size: 18)),
        ],
      ),
    );
  }
}
