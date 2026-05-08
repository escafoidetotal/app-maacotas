import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/feeding_model.dart';
import '../../services/hive_service.dart';

class AddFeedingScreen extends StatefulWidget {
  final String petId;
  final FeedingModel? existing;

  const AddFeedingScreen({super.key, required this.petId, this.existing});

  @override
  State<AddFeedingScreen> createState() => _AddFeedingScreenState();
}

class _AddFeedingScreenState extends State<AddFeedingScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _predefinedMealNames = [
    'Desayuno',
    'Comida',
    'Cena',
    'Snack',
    'Personalizado',
  ];

  final List<String> _foodTypes = [
    'Pienso seco',
    'Pienso húmedo',
    'Comida casera',
    'Mixto',
  ];

  String _selectedMealName = 'Desayuno';
  final _customMealController = TextEditingController();
  bool _isCustomMeal = false;

  String _selectedFoodType = 'Pienso seco';
  String _selectedTime = '08:00';
  final _quantityController = TextEditingController(text: '200');
  final _notesController = TextEditingController();

  // Days of week: 1=Monday ... 7=Sunday
  List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];

  final List<String> _dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _selectedTime = e.time;
      _quantityController.text = e.quantityGrams.toString();
      _notesController.text = e.notes ?? '';
      _selectedDays = List.from(e.daysOfWeek);
      _selectedFoodType = e.foodType;
      if (_predefinedMealNames.contains(e.mealName)) {
        _selectedMealName = e.mealName;
        _isCustomMeal = false;
      } else {
        _selectedMealName = 'Personalizado';
        _isCustomMeal = true;
        _customMealController.text = e.mealName;
      }
    }
  }

  @override
  void dispose() {
    _customMealController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final parts = _selectedTime.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un día de la semana'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final mealName = _isCustomMeal ? _customMealController.text.trim() : _selectedMealName;

    final feeding = FeedingModel(
      id: widget.existing?.id ?? const Uuid().v4(),
      petId: widget.petId,
      mealName: mealName,
      time: _selectedTime,
      foodType: _selectedFoodType,
      quantityGrams: int.tryParse(_quantityController.text.trim()) ?? 200,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      daysOfWeek: List.from(_selectedDays)..sort(),
    );

    await HiveService.saveFeeding(feeding);

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar comida' : 'Añadir comida'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal name
              _SectionLabel('Nombre de la comida'),
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _predefinedMealNames.map((name) {
                  final isSelected = _selectedMealName == name;
                  final isCustom = name == 'Personalizado';
                  return ChoiceChip(
                    label: Text(name),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedMealName = name;
                        _isCustomMeal = isCustom;
                      });
                    },
                  );
                }).toList(),
              ),
              if (_isCustomMeal) ...[
                const SizedBox(height: AppSizes.sm),
                TextFormField(
                  controller: _customMealController,
                  decoration: _inputDecoration('Nombre personalizado', Icons.edit),
                  validator: (v) {
                    if (_isCustomMeal && (v == null || v.trim().isEmpty)) {
                      return 'Introduce un nombre';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: AppSizes.md),

              // Time picker
              _SectionLabel('Hora'),
              const SizedBox(height: AppSizes.sm),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md, vertical: AppSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: AppColors.primary),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        _selectedTime,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: AppColors.textLight),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // Food type
              _SectionLabel('Tipo de alimento'),
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _foodTypes.map((type) {
                  final isSelected = _selectedFoodType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    selectedColor: AppColors.secondary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => setState(() => _selectedFoodType = type),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSizes.md),

              // Quantity
              _SectionLabel('Cantidad (gramos)'),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Cantidad en gramos', Icons.scale),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Introduce la cantidad';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Introduce un número válido';
                  return null;
                },
              ),

              const SizedBox(height: AppSizes.md),

              // Days of week
              _SectionLabel('Días de la semana'),
              const SizedBox(height: AppSizes.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final day = i + 1;
                  final isSelected = _selectedDays.contains(day);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedDays.remove(day);
                        } else {
                          _selectedDays.add(day);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.primary : Colors.white,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _dayLabels[i],
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppSizes.md),

              // Notes
              _SectionLabel('Notas (opcional)'),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: _inputDecoration('Notas adicionales...', Icons.notes)
                    .copyWith(alignLabelWithHint: true),
              ),

              const SizedBox(height: AppSizes.xl),

              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: Text(isEditing ? 'Guardar cambios' : 'Añadir comida'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _SectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: AppColors.textDark,
        ),
      );

  InputDecoration _inputDecoration(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      );
}
