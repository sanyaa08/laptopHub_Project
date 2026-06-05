import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/laptop_model.dart';
import '../../providers/laptop_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class LaptopFormScreen extends StatefulWidget {
  final LaptopModel? laptop;
  const LaptopFormScreen({super.key, this.laptop});

  @override
  State<LaptopFormScreen> createState() => _LaptopFormScreenState();
}

class _LaptopFormScreenState extends State<LaptopFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFeatured = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _processorCtrl;
  late final TextEditingController _ramCtrl;
  late final TextEditingController _storageCtrl;
  late final TextEditingController _displayCtrl;
  late final TextEditingController _graphicsCtrl;
  late final TextEditingController _batteryCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _osCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _stockCtrl;

  bool get isEdit => widget.laptop != null;

  @override
  void initState() {
    super.initState();
    final l = widget.laptop;
    _nameCtrl = TextEditingController(text: l?.name ?? '');
    _brandCtrl = TextEditingController(text: l?.brand ?? '');
    _priceCtrl = TextEditingController(text: l?.price.toString() ?? '');
    _imageCtrl = TextEditingController(text: l?.imageUrl ?? '');
    _processorCtrl = TextEditingController(text: l?.processor ?? '');
    _ramCtrl = TextEditingController(text: l?.ram ?? '');
    _storageCtrl = TextEditingController(text: l?.storage ?? '');
    _displayCtrl = TextEditingController(text: l?.display ?? '');
    _graphicsCtrl = TextEditingController(text: l?.graphics ?? '');
    _batteryCtrl = TextEditingController(text: l?.battery ?? '');
    _weightCtrl = TextEditingController(text: l?.weight ?? '');
    _osCtrl = TextEditingController(text: l?.os ?? '');
    _descCtrl = TextEditingController(text: l?.description ?? '');
    _stockCtrl = TextEditingController(text: l?.stock.toString() ?? '0');
    _isFeatured = l?.isFeatured ?? false;
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _brandCtrl, _priceCtrl, _imageCtrl, _processorCtrl,
      _ramCtrl, _storageCtrl, _displayCtrl, _graphicsCtrl, _batteryCtrl,
      _weightCtrl, _osCtrl, _descCtrl, _stockCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'brand': _brandCtrl.text.trim(),
      'price': double.tryParse(_priceCtrl.text) ?? 0,
      'image_url': _imageCtrl.text.trim(),
      'processor': _processorCtrl.text.trim(),
      'ram': _ramCtrl.text.trim(),
      'storage': _storageCtrl.text.trim(),
      'display': _displayCtrl.text.trim(),
      'graphics': _graphicsCtrl.text.trim(),
      'battery': _batteryCtrl.text.trim(),
      'weight': _weightCtrl.text.trim(),
      'os': _osCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'stock': int.tryParse(_stockCtrl.text) ?? 0,
      'is_featured': _isFeatured,
    };

    final provider = context.read<LaptopProvider>();
    String? error;

    if (isEdit) {
      error = await provider.updateLaptop(widget.laptop!.id, data);
    } else {
      error = await provider.createLaptop(data);
    }

    setState(() => _isLoading = false);

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppTheme.error),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Laptop updated!' : 'Laptop added!'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Laptop' : 'Add Laptop'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isEdit)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'EDITING',
                style: TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: '📋 Basic Info'),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameCtrl,
                label: 'Laptop Name *',
                hint: 'e.g. MacBook Pro 16"',
                prefixIcon: Icons.laptop,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _brandCtrl,
                      label: 'Brand *',
                      hint: 'Apple',
                      prefixIcon: Icons.business,
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _priceCtrl,
                      label: 'Price (USD) *',
                      hint: '999.99',
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.isEmpty == true) return 'Required';
                        if (double.tryParse(v!) == null) return 'Invalid price';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _stockCtrl,
                      label: 'Stock',
                      hint: '10',
                      prefixIcon: Icons.inventory,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: AppTheme.accentGold, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(child: Text('Featured', style: TextStyle(color: AppTheme.textSecondary))),
                          Switch(
                            value: _isFeatured,
                            onChanged: (v) => setState(() => _isFeatured = v),
                            activeColor: AppTheme.accent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _imageCtrl,
                label: 'Image URL',
                hint: 'https://...',
                prefixIcon: Icons.image_outlined,
              ),
              const SizedBox(height: 24),

              _SectionHeader(title: '⚙️ Specifications'),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _processorCtrl,
                label: 'Processor',
                hint: 'Intel Core i9-13900H',
                prefixIcon: Icons.memory,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _ramCtrl,
                      label: 'RAM',
                      hint: '16GB DDR5',
                      prefixIcon: Icons.storage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _storageCtrl,
                      label: 'Storage',
                      hint: '512GB SSD',
                      prefixIcon: Icons.disc_full,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _displayCtrl,
                label: 'Display',
                hint: '15.6" FHD IPS 144Hz',
                prefixIcon: Icons.monitor,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _graphicsCtrl,
                label: 'Graphics',
                hint: 'NVIDIA RTX 4060 8GB',
                prefixIcon: Icons.videogame_asset,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _batteryCtrl,
                      label: 'Battery',
                      hint: '10 hours',
                      prefixIcon: Icons.battery_full,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _weightCtrl,
                      label: 'Weight',
                      hint: '1.8 kg',
                      prefixIcon: Icons.scale,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _osCtrl,
                label: 'Operating System',
                hint: 'Windows 11 Home',
                prefixIcon: Icons.computer,
              ),
              const SizedBox(height: 24),

              _SectionHeader(title: '📝 Description'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 5,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Write a detailed description...',
                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.accent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              CustomButton(
                label: isEdit ? 'Update Laptop' : 'Add Laptop',
                onPressed: _submit,
                isLoading: _isLoading,
                icon: isEdit ? Icons.save_rounded : Icons.add_rounded,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
