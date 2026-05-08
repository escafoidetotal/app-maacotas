import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

enum ExerciseLevel { low, medium, high, veryHigh }

class BreedInfo {
  final String breedName;
  final String lifespanYears;
  final String weightRangeKg;
  final ExerciseLevel exerciseLevel;
  final List<String> commonHealthIssues;
  final List<String> temperamentTraits;
  final String groomingNeeds;
  final String description;
  final Color primaryColor;

  const BreedInfo({
    required this.breedName,
    required this.lifespanYears,
    required this.weightRangeKg,
    required this.exerciseLevel,
    required this.commonHealthIssues,
    required this.temperamentTraits,
    required this.groomingNeeds,
    required this.description,
    required this.primaryColor,
  });
}

// ---------------------------------------------------------------------------
// Hardcoded breed data
// ---------------------------------------------------------------------------

const Map<String, BreedInfo> _breedData = {
  'labrador': BreedInfo(
    breedName: 'Labrador Retriever',
    lifespanYears: '10 – 12 años',
    weightRangeKg: '25 – 36 kg',
    exerciseLevel: ExerciseLevel.high,
    commonHealthIssues: [
      'Displasia de cadera',
      'Displasia de codo',
      'Obesidad',
      'Problemas oculares',
    ],
    temperamentTraits: [
      'Amigable',
      'Activo',
      'Leal',
      'Confiable',
      'Juguetón',
      'Gentil',
    ],
    groomingNeeds: 'Moderado — cepillar semanalmente, especialmente en época de muda.',
    description:
        'Una de las razas más populares del mundo. Los labradores son perros de familia perfectos, inteligentes y fáciles de adiestrar.',
    primaryColor: Color(0xFFD4A017),
  ),
  'husky': BreedInfo(
    breedName: 'Husky Siberiano',
    lifespanYears: '12 – 14 años',
    weightRangeKg: '16 – 27 kg',
    exerciseLevel: ExerciseLevel.veryHigh,
    commonHealthIssues: [
      'Problemas oculares (cataratas)',
      'Displasia de cadera',
      'Hipotiroidismo',
      'Problemas de piel',
    ],
    temperamentTraits: [
      'Energético',
      'Independiente',
      'Sociable',
      'Curioso',
      'Vocal',
      'Inteligente',
    ],
    groomingNeeds: 'Alto — doble capa que muda profusamente dos veces al año. Cepillar varias veces por semana.',
    description:
        'Perros de trabajo originarios de Siberia. Son muy enérgicos, necesitan ejercicio intenso diario y estimulación mental.',
    primaryColor: Color(0xFF9E9E9E),
  ),
  'poodle': BreedInfo(
    breedName: 'Caniche (Poodle)',
    lifespanYears: '12 – 15 años',
    weightRangeKg: '3 – 32 kg',
    exerciseLevel: ExerciseLevel.medium,
    commonHealthIssues: [
      'Epilepsia',
      'Enfermedad de Addison',
      'Displasia de cadera',
      'Problemas de tiroides',
    ],
    temperamentTraits: [
      'Inteligente',
      'Activo',
      'Alerta',
      'Fiel',
      'Instintivo',
      'Adaptable',
    ],
    groomingNeeds: 'Muy alto — su pelaje no muda pero crece continuamente. Requiere peluquería cada 6-8 semanas.',
    description:
        'Considerada una de las razas más inteligentes. Excelente en deportes caninos y como perro de terapia. Disponible en tres tamaños: estándar, miniatura y toy.',
    primaryColor: Color(0xFF78909C),
  ),
  'bulldog': BreedInfo(
    breedName: 'Bulldog Inglés',
    lifespanYears: '8 – 10 años',
    weightRangeKg: '18 – 25 kg',
    exerciseLevel: ExerciseLevel.low,
    commonHealthIssues: [
      'Problemas respiratorios (braquicefalia)',
      'Displasia de cadera',
      'Enfermedades de piel',
      'Problemas oculares',
      'Sensibilidad al calor',
    ],
    temperamentTraits: [
      'Dócil',
      'Amigable',
      'Willful',
      'Tranquilo',
      'Valiente',
      'Leal',
    ],
    groomingNeeds: 'Bajo — pelo corto que requiere poco cepillado. Importante limpiar los pliegues de la cara a diario.',
    description:
        'Perros de carácter tranquilo y afectuoso. Su morfología braquicefálica requiere especial atención en épocas de calor y ejercicio moderado.',
    primaryColor: Color(0xFFD2B48C),
  ),
  'german shepherd': BreedInfo(
    breedName: 'Pastor Alemán',
    lifespanYears: '9 – 13 años',
    weightRangeKg: '22 – 40 kg',
    exerciseLevel: ExerciseLevel.high,
    commonHealthIssues: [
      'Displasia de cadera',
      'Displasia de codo',
      'Degeneración mielítica',
      'Bloat (dilatación-torsión gástrica)',
    ],
    temperamentTraits: [
      'Inteligente',
      'Leal',
      'Obediente',
      'Curioso',
      'Alerta',
      'Valiente',
    ],
    groomingNeeds: 'Moderado-Alto — doble capa con muda estacional. Cepillar 2-3 veces por semana.',
    description:
        'Una de las razas de trabajo más versátiles. Excelentes como perros policía, de rescate y de terapia. Muy leales a su familia.',
    primaryColor: Color(0xFF8B4513),
  ),
  'golden retriever': BreedInfo(
    breedName: 'Golden Retriever',
    lifespanYears: '10 – 12 años',
    weightRangeKg: '25 – 34 kg',
    exerciseLevel: ExerciseLevel.high,
    commonHealthIssues: [
      'Cáncer',
      'Displasia de cadera',
      'Cataratas',
      'Epilepsia',
      'Hipotiroidismo',
    ],
    temperamentTraits: [
      'Confiable',
      'Confiado',
      'Amigable',
      'Paciente',
      'Devoto',
      'Juguetón',
    ],
    groomingNeeds: 'Alto — pelo largo y denso que requiere cepillado varias veces a la semana para evitar enredos.',
    description:
        'Perros increíblemente cariñosos y pacientes, ideales como perros de familia, de terapia y de guía. Su entrenabilidad es excepcional.',
    primaryColor: Color(0xFFFFB300),
  ),
  'dachshund': BreedInfo(
    breedName: 'Dachshund (Teckel)',
    lifespanYears: '12 – 16 años',
    weightRangeKg: '4 – 14 kg',
    exerciseLevel: ExerciseLevel.medium,
    commonHealthIssues: [
      'Enfermedad discal intervertebral (IVDD)',
      'Epilepsia',
      'Problemas dentales',
      'Obesidad',
    ],
    temperamentTraits: [
      'Curioso',
      'Valiente',
      'Devoto',
      'Vivaz',
      'Clown',
      'Temperamental',
    ],
    groomingNeeds: 'Bajo a moderado — depende de la variedad (pelo liso, largo o duro). El pelo liso requiere poco mantenimiento.',
    description:
        'Perros pequeños con gran personalidad. Su espalda larga los hace propensos a problemas discales, por lo que se deben evitar saltos desde altura.',
    primaryColor: Color(0xFFA0522D),
  ),
  'pug': BreedInfo(
    breedName: 'Pug (Carlino)',
    lifespanYears: '13 – 15 años',
    weightRangeKg: '6 – 8 kg',
    exerciseLevel: ExerciseLevel.low,
    commonHealthIssues: [
      'Problemas respiratorios (braquicefalia)',
      'Pug Dog Encephalitis',
      'Problemas oculares',
      'Obesidad',
      'Sensibilidad al calor',
    ],
    temperamentTraits: [
      'Encantador',
      'Travieso',
      'Cariñoso',
      'Sociable',
      'Atento',
      'Tranquilo',
    ],
    groomingNeeds: 'Bajo-Moderado — pelo corto pero muda bastante. Limpiar pliegues faciales regularmente.',
    description:
        'Los pugs son perros compañeros por excelencia. Su carácter divertido y cariñoso los hace ideales para apartamentos, aunque requieren cuidado especial por su morfología.',
    primaryColor: Color(0xFFBCAAA4),
  ),
  'shih tzu': BreedInfo(
    breedName: 'Shih Tzu',
    lifespanYears: '10 – 18 años',
    weightRangeKg: '4 – 7 kg',
    exerciseLevel: ExerciseLevel.low,
    commonHealthIssues: [
      'Problemas respiratorios (braquicefalia)',
      'Problemas oculares',
      'Displasia de cadera',
      'Problemas renales',
    ],
    temperamentTraits: [
      'Afectuoso',
      'Juguetón',
      'Extrovertido',
      'Alerta',
      'Amigable',
      'Leal',
    ],
    groomingNeeds: 'Muy alto — pelo largo que requiere cepillado diario o corte regular cada 6-8 semanas.',
    description:
        'Perros de compañía criados originalmente para la realeza china. Son amigables con todos y se adaptan bien a vivir en apartamentos.',
    primaryColor: Color(0xFFCE93D8),
  ),
  'border collie': BreedInfo(
    breedName: 'Border Collie',
    lifespanYears: '12 – 15 años',
    weightRangeKg: '14 – 20 kg',
    exerciseLevel: ExerciseLevel.veryHigh,
    commonHealthIssues: [
      'Epilepsia',
      'Anomalía del ojo de Collie (CEA)',
      'Displasia de cadera',
      'Hipotiroidismo',
    ],
    temperamentTraits: [
      'Extremadamente inteligente',
      'Enérgico',
      'Responsivo',
      'Tenaz',
      'Instinto de pastoreo',
      'Sensitivo',
    ],
    groomingNeeds: 'Moderado — doble capa que requiere cepillado 2-3 veces por semana y más en época de muda.',
    description:
        'Considerado el perro más inteligente del mundo. Necesitan ejercicio y estimulación mental intensa. Ideales para deportes caninos como agility.',
    primaryColor: Color(0xFF424242),
  ),
};

// Fallback for unknown breeds
const BreedInfo _unknownBreed = BreedInfo(
  breedName: 'Raza mixta / Desconocida',
  lifespanYears: '10 – 15 años',
  weightRangeKg: 'Variable',
  exerciseLevel: ExerciseLevel.medium,
  commonHealthIssues: [
    'Variable según herencia genética',
    'Generalmente más robustos que razas puras',
  ],
  temperamentTraits: [
    'Variable',
    'Único',
    'Adaptable',
  ],
  groomingNeeds: 'Variable según el tipo de pelaje heredado.',
  description:
      'Los perros de raza mixta suelen ser más resistentes genéticamente que los de raza pura. Cada uno es único y especial.',
  primaryColor: AppColors.secondary,
);

// ---------------------------------------------------------------------------
// Lookup helper
// ---------------------------------------------------------------------------

BreedInfo _lookupBreed(String breed) {
  final key = breed.trim().toLowerCase();
  // Direct match
  if (_breedData.containsKey(key)) return _breedData[key]!;
  // Partial match
  for (final entry in _breedData.entries) {
    if (key.contains(entry.key) || entry.key.contains(key)) {
      return entry.value;
    }
  }
  return _unknownBreed;
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class BreedInfoScreen extends StatelessWidget {
  final String breed;

  const BreedInfoScreen({super.key, required this.breed});

  @override
  Widget build(BuildContext context) {
    final info = _lookupBreed(breed);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: info.primaryColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      info.primaryColor,
                      info.primaryColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSizes.md, 48, AppSizes.md, AppSizes.md),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Info de raza',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          info.breedName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          info.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick stats row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.favorite,
                          label: 'Esperanza de vida',
                          value: info.lifespanYears,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.monitor_weight,
                          label: 'Peso promedio',
                          value: info.weightRangeKg,
                          color: const Color(0xFF2ECC71),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.md),

                  // Exercise needs
                  _SectionCard(
                    title: 'Necesidades de ejercicio',
                    icon: Icons.directions_run,
                    color: AppColors.primary,
                    child: _ExerciseBars(level: info.exerciseLevel),
                  ),

                  const SizedBox(height: AppSizes.md),

                  // Grooming
                  _SectionCard(
                    title: 'Necesidades de aseo',
                    icon: Icons.content_cut,
                    color: AppColors.secondary,
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSizes.xs),
                      child: Text(
                        info.groomingNeeds,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.md),

                  // Temperament
                  _SectionCard(
                    title: 'Temperamento',
                    icon: Icons.psychology,
                    color: const Color(0xFF9B59B6),
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSizes.sm),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: info.temperamentTraits.map((trait) {
                          return _TraitChip(
                            label: trait,
                            backgroundColor:
                                const Color(0xFF9B59B6).withOpacity(0.1),
                            textColor: const Color(0xFF9B59B6),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.md),

                  // Health issues
                  _SectionCard(
                    title: 'Problemas de salud comunes',
                    icon: Icons.health_and_safety,
                    color: AppColors.error,
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSizes.sm),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: info.commonHealthIssues.map((issue) {
                          return _TraitChip(
                            label: issue,
                            backgroundColor: AppColors.error.withOpacity(0.08),
                            textColor: AppColors.error,
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppSizes.xs),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: AppSizes.sm),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class _ExerciseBars extends StatelessWidget {
  final ExerciseLevel level;

  const _ExerciseBars({required this.level});

  String get _levelLabel {
    switch (level) {
      case ExerciseLevel.low:
        return 'Bajo';
      case ExerciseLevel.medium:
        return 'Moderado';
      case ExerciseLevel.high:
        return 'Alto';
      case ExerciseLevel.veryHigh:
        return 'Muy alto';
    }
  }

  Color get _levelColor {
    switch (level) {
      case ExerciseLevel.low:
        return const Color(0xFF2ECC71);
      case ExerciseLevel.medium:
        return const Color(0xFFF39C12);
      case ExerciseLevel.high:
        return AppColors.primary;
      case ExerciseLevel.veryHigh:
        return AppColors.error;
    }
  }

  int get _filledBars {
    switch (level) {
      case ExerciseLevel.low:
        return 1;
      case ExerciseLevel.medium:
        return 2;
      case ExerciseLevel.high:
        return 3;
      case ExerciseLevel.veryHigh:
        return 4;
    }
  }

  String get _description {
    switch (level) {
      case ExerciseLevel.low:
        return 'Paseos cortos diarios (20-30 min) son suficientes.';
      case ExerciseLevel.medium:
        return 'Necesita 30-60 minutos de ejercicio diario.';
      case ExerciseLevel.high:
        return 'Requiere 1-2 horas de actividad intensa al día.';
      case ExerciseLevel.veryHigh:
        return 'Necesita 2+ horas de ejercicio intenso diario y estimulación mental constante.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (i) {
              final filled = i < _filledBars;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  height: 12,
                  decoration: BoxDecoration(
                    color: filled ? _levelColor : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _levelColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _levelLabel,
                  style: TextStyle(
                    color: _levelColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _description,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TraitChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _TraitChip({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
