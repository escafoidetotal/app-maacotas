import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../providers/pets_provider.dart';

class AddDewormingScreen extends ConsumerStatefulWidget {
  final String petId;

  const AddDewormingScreen({super.key, required this.petId});

  @override
  ConsumerState<AddDewormingScreen> createState() => _AddDewormingScreenState();
}

class _AddDewormingScreenState extends ConsumerState<AddDewormingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _notesController = TextEditingController();
  String _type = 'internal';
  DateTime? _applicationDate;
  DateTime? _nextApplicationDate;
  bool _isSaving = false;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  static const List<String> _internalProducts = [
    'Drontal', 'Milbemax', 'Panacur', 'Vermivet', 'Endal'
  ];
  static const List<String> _externalProducts = [
    'Frontline', 'Advantage', 'Bravecto', 'Nexgard', 'Seresto'
  ];

  @override
  void dispose() {
    _productController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isApplication) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: isApplication ? DateTime.now() : DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isApplication) {
          _applicationDate = picked;
        } else {
          _nextApplicationDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_applicationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de aplicação')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(dewormingProvider(widget.petId).notifier).addDeworming(
        type: _type,
        productName: _productController.text.trim(),
        applicationDate: _applicationDate!,
        nextApplicationDate: _nextApplicationDate,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vermifugação registrada!')),
        );
        context.go('/pets/${widget.petId}/deworming');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = _type == 'internal' ? _internalProducts : _externalProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Adicionar Vermifugação'),
        backgroundColor: const Color(0xFFE67E22),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pets/${widget.petId}/deworming'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tipo de vermifugação', style: TextStyle(fontSize: 14, color: AppColors.textLight, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: 'Interna',
                      icon: Icons.local_pharmacy,
                      isSelected: _type == 'internal',
                      color: const Color(0xFFE67E22),
                      onTap: () => setState(() => _type = 'internal'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: _TypeButton(
                      label: 'Externa',
                      icon: Icons.pest_control,
                      isSelected: _type == 'external',
                      color: const Color(0xFF8E44AD),
                      onTap: () => setState(() => _type = 'external'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              const Text('Produto', style: TextStyle(fontSize: 14, color: AppColors.textLight, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSizes.xs),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: products.map((product) => ChoiceChip(
                  label: Text(product),
                  selected: _productController.text == product,
                  onSelected: (selected) {
                    if (selected) setState(() => _productController.text = product);
                  },
                  selectedColor: const Color(0xFFE67E22).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _productController.text == product
                        ? const Color(0xFFE67E22)
                        : AppColors.textDark,
                  ),
                )).toList(),
              ),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _productController,
                decoration: const InputDecoration(
                  labelText: 'Nome do produto *',
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: AppSizes.md),
              GestureDetector(
                onTap: () => _pickDate(true),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Data de aplicação *',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: _applicationDate != null ? _dateFormat.format(_applicationDate!) : '',
                    ),
                    validator: (v) => _applicationDate == null ? 'Campo obrigatório' : null,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              GestureDetector(
                onTap: () => _pickDate(false),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Próxima aplicação',
                      prefixIcon: Icon(Icons.event),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: _nextApplicationDate != null ? _dateFormat.format(_nextApplicationDate!) : '',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE67E22)),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text('Salvar'),
              ),
              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : AppColors.textLight),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textLight,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
