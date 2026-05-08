import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/pets_provider.dart';

class AddPetScreen extends ConsumerStatefulWidget {
  const AddPetScreen({super.key});

  @override
  ConsumerState<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends ConsumerState<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _microchipController = TextEditingController();
  final _insuranceController = TextEditingController();

  DateTime? _birthdate;
  String _gender = 'male';
  String? _photoPath;
  bool _isSaving = false;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  static const List<String> _commonBreeds = [
    'Labrador',
    'Golden Retriever',
    'Poodle',
    'Bulldog',
    'German Shepherd',
    'Husky',
    'Dachshund',
    'Pug',
    'Shih Tzu',
    'Border Collie',
    'Beagle',
    'Rottweiler',
    'Yorkshire Terrier',
    'Chihuahua',
    'Maltese',
    'Vira-lata',
    'Outra raça',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _microchipController.dispose();
    _insuranceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Data de nascimento',
    );
    if (picked != null) {
      setState(() => _birthdate = picked);
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _photoPath = image.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthdate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de nascimento')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final pet = await ref.read(petsProvider.notifier).addPet(
        name: _nameController.text.trim(),
        breed: _breedController.text.trim(),
        birthdate: _birthdate!,
        weight: double.parse(_weightController.text.replaceAll(',', '.')),
        gender: _gender,
        photoPath: _photoPath,
        microchipNumber: _microchipController.text.trim().isNotEmpty
            ? _microchipController.text.trim()
            : null,
        insuranceInfo: _insuranceController.text.trim().isNotEmpty
            ? _insuranceController.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${pet.name} adicionado com sucesso!')),
        );
        context.go('/pets/${pet.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
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
        title: const Text('Adicionar Pet'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pets'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: _photoPath != null
                        ? ClipOval(
                            child: Image.network(
                              _photoPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.pets,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : const Icon(Icons.add_a_photo, size: 40, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              const Center(
                child: Text(
                  'Toque para adicionar foto',
                  style: TextStyle(color: AppColors.textLight, fontSize: 12),
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do pet *',
                  prefixIcon: Icon(Icons.pets),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: AppSizes.md),

              // Breed
              DropdownButtonFormField<String>(
                value: _commonBreeds.contains(_breedController.text)
                    ? _breedController.text
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Raça *',
                  prefixIcon: Icon(Icons.pets),
                ),
                items: _commonBreeds
                    .map((breed) => DropdownMenuItem(value: breed, child: Text(breed)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _breedController.text = v);
                },
                validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: AppSizes.md),

              // Birthdate
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Data de nascimento *',
                      prefixIcon: Icon(Icons.cake),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: _birthdate != null ? _dateFormat.format(_birthdate!) : '',
                    ),
                    validator: (v) => _birthdate == null ? 'Campo obrigatório' : null,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Weight
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Peso atual (kg) *',
                  prefixIcon: Icon(Icons.monitor_weight),
                  suffixText: 'kg',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) return 'Peso inválido';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),

              // Gender
              const Text(
                'Sexo *',
                style: TextStyle(fontSize: 14, color: AppColors.textLight),
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Expanded(
                    child: _GenderButton(
                      label: 'Macho',
                      icon: Icons.male,
                      isSelected: _gender == 'male',
                      color: Colors.blue,
                      onTap: () => setState(() => _gender = 'male'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: _GenderButton(
                      label: 'Fêmea',
                      icon: Icons.female,
                      isSelected: _gender == 'female',
                      color: Colors.pink,
                      onTap: () => setState(() => _gender = 'female'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),

              // Microchip
              TextFormField(
                controller: _microchipController,
                decoration: const InputDecoration(
                  labelText: 'Número do microchip',
                  prefixIcon: Icon(Icons.qr_code),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Insurance
              TextFormField(
                controller: _insuranceController,
                decoration: const InputDecoration(
                  labelText: 'Informações do seguro',
                  prefixIcon: Icon(Icons.shield),
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // Save button
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Salvar Pet'),
              ),

              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _GenderButton({
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : AppColors.textLight),
            const SizedBox(width: 8),
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
