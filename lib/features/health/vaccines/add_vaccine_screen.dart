import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../providers/pets_provider.dart';
import '../../../providers/pawpoints_provider.dart';

class AddVaccineScreen extends ConsumerStatefulWidget {
  final String petId;

  const AddVaccineScreen({super.key, required this.petId});

  @override
  ConsumerState<AddVaccineScreen> createState() => _AddVaccineScreenState();
}

class _AddVaccineScreenState extends ConsumerState<AddVaccineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _vetController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _vaccineDate;
  DateTime? _nextDoseDate;
  bool _isSaving = false;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  static const List<String> _commonVaccines = [
    'V8 / V10 (Polivalente)',
    'Antirrábica',
    'Gripe Canina (Influenza)',
    'Leptospirose',
    'Leishmaniose',
    'Giárdia',
    'Coronavirus',
    'Reforço Anual',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _vetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isVaccineDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: isVaccineDate
          ? DateTime.now()
          : DateTime.now().add(const Duration(days: 3650)),
      helpText: isVaccineDate ? 'Data da vacina' : 'Próxima dose',
    );
    if (picked != null) {
      setState(() {
        if (isVaccineDate) {
          _vaccineDate = picked;
        } else {
          _nextDoseDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_vaccineDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data da vacina')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(vaccinesProvider(widget.petId).notifier).addVaccine(
        name: _nameController.text.trim(),
        vaccineDate: _vaccineDate!,
        nextDoseDate: _nextDoseDate,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        veterinarian: _vetController.text.trim().isNotEmpty
            ? _vetController.text.trim()
            : null,
      );

      await ref.read(pawPointsProvider.notifier).earnPoints(PointsEvent.vaccineUpdated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vacina adicionada! +25 PawPoints'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/pets/${widget.petId}/vaccines');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Adicionar Vacina'),
        backgroundColor: const Color(0xFF3498DB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pets/${widget.petId}/vaccines'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Points notice
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, color: AppColors.success),
                    SizedBox(width: AppSizes.sm),
                    Text(
                      'Ganhe +25 PawPoints ao registrar!',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Vaccine name quick-select chips
              const Text(
                'Vacina',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _commonVaccines.map((vaccine) {
                  final isSelected = _nameController.text == vaccine;
                  return GestureDetector(
                    onTap: () => setState(() => _nameController.text = vaccine),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF3498DB).withOpacity(0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3498DB)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        vaccine,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? const Color(0xFF3498DB)
                              : AppColors.textDark,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.sm),

              // Vaccine name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da vacina *',
                  prefixIcon: Icon(Icons.vaccines),
                  hintText: 'Ou digite outro nome',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: AppSizes.md),

              // Vaccine date
              GestureDetector(
                onTap: () => _pickDate(true),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Data da vacina *',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: _vaccineDate != null
                          ? _dateFormat.format(_vaccineDate!)
                          : '',
                    ),
                    validator: (v) =>
                        _vaccineDate == null ? 'Campo obrigatório' : null,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Next dose date
              GestureDetector(
                onTap: () => _pickDate(false),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Próxima dose',
                      prefixIcon: Icon(Icons.event),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: _nextDoseDate != null
                          ? _dateFormat.format(_nextDoseDate!)
                          : '',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Veterinarian
              TextFormField(
                controller: _vetController,
                decoration: const InputDecoration(
                  labelText: 'Veterinário',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Notes
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
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB)),
                child: _isSaving
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : const Text('Salvar Vacina'),
              ),

              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}
