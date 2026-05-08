import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../providers/pets_provider.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  final String petId;

  const AddMedicationScreen({super.key, required this.petId});

  @override
  ConsumerState<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _notesController = TextEditingController();
  String _frequency = 'daily';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  static const List<Map<String, String>> _frequencies = [
    {'key': 'daily', 'label': '1x ao dia'},
    {'key': 'twice_daily', 'label': '2x ao dia'},
    {'key': 'three_times', 'label': '3x ao dia'},
    {'key': 'weekly', 'label': '1x por semana'},
    {'key': 'biweekly', 'label': '2x por semana'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de início')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(medicationsProvider(widget.petId).notifier).addMedication(
        name: _nameController.text.trim(),
        dose: _doseController.text.trim(),
        frequency: _frequency,
        startDate: _startDate!,
        endDate: _endDate,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicamento adicionado!')),
        );
        context.go('/pets/${widget.petId}/medications');
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Adicionar Medicamento'),
        backgroundColor: const Color(0xFFE74C3C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pets/${widget.petId}/medications'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do medicamento *',
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: AppSizes.md),

              TextFormField(
                controller: _doseController,
                decoration: const InputDecoration(
                  labelText: 'Dose *',
                  prefixIcon: Icon(Icons.science),
                  hintText: 'ex: 1 comprimido, 5ml',
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: AppSizes.md),

              const Text(
                'Frequência',
                style: TextStyle(fontSize: 14, color: AppColors.textLight, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.xs),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _frequencies.map((f) => ChoiceChip(
                  label: Text(f['label']!),
                  selected: _frequency == f['key'],
                  onSelected: (selected) {
                    if (selected) setState(() => _frequency = f['key']!);
                  },
                  selectedColor: const Color(0xFFE74C3C).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _frequency == f['key'] ? const Color(0xFFE74C3C) : AppColors.textDark,
                  ),
                )).toList(),
              ),
              const SizedBox(height: AppSizes.md),

              GestureDetector(
                onTap: () => _pickDate(true),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Data de início *',
                      prefixIcon: Icon(Icons.play_arrow),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: _startDate != null ? _dateFormat.format(_startDate!) : '',
                    ),
                    validator: (v) => _startDate == null ? 'Campo obrigatório' : null,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              GestureDetector(
                onTap: () => _pickDate(false),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Data de término',
                      prefixIcon: Icon(Icons.stop),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: _endDate != null ? _dateFormat.format(_endDate!) : '',
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
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE74C3C)),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text('Salvar Medicamento'),
              ),

              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}
