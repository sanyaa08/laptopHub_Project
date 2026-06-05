import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/laptop_provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      gradient: auth.isAdmin ? const LinearGradient(colors: [AppTheme.adminBadge, Color(0xFFFF8E53)]) : AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.accentShadow,
                    ),
                    child: Center(
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 14),
                  Text(user?.name ?? 'User', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '', style: const TextStyle(color: AppTheme.textSecondary)).animate().fadeIn(delay: 250.ms),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: auth.isAdmin ? AppTheme.adminBadge.withOpacity(0.15) : AppTheme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: auth.isAdmin ? AppTheme.adminBadge.withOpacity(0.4) : AppTheme.accent.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(auth.isAdmin ? Icons.verified : Icons.person, color: auth.isAdmin ? AppTheme.adminBadge : AppTheme.accent, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          auth.isAdmin ? 'Administrator' : 'Regular User',
                          style: TextStyle(color: auth.isAdmin ? AppTheme.adminBadge : AppTheme.accent, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Info Card
            _InfoCard(
              children: [
                _InfoRow(icon: Icons.person_outline, label: 'Full Name', value: user?.name ?? '-'),
                _InfoRow(icon: Icons.email_outlined, label: 'Email', value: user?.email ?? '-'),
                _InfoRow(icon: Icons.admin_panel_settings_outlined, label: 'Role', value: user?.role.toUpperCase() ?? '-'),
                _InfoRow(icon: Icons.calendar_today_outlined, label: 'Member Since', value: _formatDate(user?.createdAt)),
              ],
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 20),

            // Access Info
            if (auth.isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.adminBadge.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.adminBadge.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security, color: AppTheme.adminBadge, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Admin Access', style: TextStyle(color: AppTheme.adminBadge, fontWeight: FontWeight.w700)),
                          Text('You can manage laptops, users & all CRUD operations.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 32),

            // Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppTheme.cardBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('Sign Out', style: TextStyle(color: AppTheme.textPrimary)),
                      content: const Text('Are you sure you want to sign out?', style: TextStyle(color: AppTheme.textSecondary)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    context.read<CartProvider>().reset();
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
                    }
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error.withOpacity(0.15),
                  foregroundColor: AppTheme.error,
                  side: const BorderSide(color: AppTheme.error),
                  minimumSize: const Size(double.infinity, 52),
                  elevation: 0,
                ),
              ),
            ).animate().fadeIn(delay: 450.ms),
            const SizedBox(height: 20),
            Text('Laptop Hub v1.0.0', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
      child: Column(
        children: List.generate(children.length, (i) => Column(
          children: [
            children[i],
            if (i < children.length - 1) Divider(color: AppTheme.divider, height: 1),
          ],
        )),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
