import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../services/hive_service.dart';

class VetLocatorScreen extends StatefulWidget {
  const VetLocatorScreen({super.key});

  @override
  State<VetLocatorScreen> createState() => _VetLocatorScreenState();
}

class _VetLocatorScreenState extends State<VetLocatorScreen> {
  bool _isLoadingLocation = false;
  final TextEditingController _emergencyNumberController =
      TextEditingController(text: '+1234567890');

  @override
  void dispose() {
    _emergencyNumberController.dispose();
    super.dispose();
  }

  Future<void> _searchNearbyVets() async {
    setState(() => _isLoadingLocation = true);

    try {
      final hasPermission = await _ensureLocationPermission();

      if (hasPermission) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
        final lat = position.latitude.toStringAsFixed(5);
        final lng = position.longitude.toStringAsFixed(5);
        final query = Uri.encodeComponent('veterinario cerca de $lat,$lng');
        final url = Uri.parse('https://maps.google.com/?q=$query');
        await _launchUrl(url);
      } else {
        // Fallback without location
        final url = Uri.parse('https://maps.google.com/?q=veterinario+cerca');
        await _launchUrl(url);
      }
    } catch (_) {
      // Fallback on any error (timeout, etc.)
      final url = Uri.parse('https://maps.google.com/?q=veterinario+cerca');
      await _launchUrl(url);
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<bool> _ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir Google Maps'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _callEmergency() async {
    final number = _emergencyNumberController.text.trim();
    if (number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un número de teléfono')),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el marcador'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Collect unique vet names and clinic names from all saved appointments
  List<_SavedVet> _getSavedVets() {
    final allAppointments = HiveService.vetAppointments.values.toList();
    final seen = <String>{};
    final result = <_SavedVet>[];

    for (final appt in allAppointments) {
      final key = '${appt.vetName}|${appt.clinic ?? ''}';
      if (!seen.contains(key)) {
        seen.add(key);
        result.add(_SavedVet(
          vetName: appt.vetName,
          clinic: appt.clinic,
        ));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final savedVets = _getSavedVets();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Veterinarios'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Illustration hero card
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.xl, horizontal: AppSizes.md),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.medical_services,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  const Text(
                    'Encuentra veterinarios cerca de ti',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  const Text(
                    'Usa tu ubicación para encontrar clínicas veterinarias cercanas en Google Maps',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // Search button
            ElevatedButton.icon(
              onPressed: _isLoadingLocation ? null : _searchNearbyVets,
              icon: _isLoadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.location_on),
              label: Text(
                _isLoadingLocation
                    ? 'Obteniendo ubicación...'
                    : 'Buscar vets cercanos',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // Emergency call section
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C).withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(
                  color: const Color(0xFFE74C3C).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.emergency,
                          color: Color(0xFFE74C3C), size: 22),
                      SizedBox(width: AppSizes.sm),
                      Text(
                        'Llamada de emergencia vet',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFFE74C3C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  const Text(
                    'Ingresa el número de tu veterinario de emergencia:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _emergencyNumberController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: '+1234567890',
                            prefixIcon: const Icon(Icons.phone,
                                color: Color(0xFFE74C3C)),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSm),
                              borderSide: const BorderSide(
                                  color: Color(0xFFE74C3C)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSm),
                              borderSide: const BorderSide(
                                  color: Color(0xFFE74C3C), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.sm, vertical: AppSizes.sm),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      ElevatedButton(
                        onPressed: _callEmergency,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE74C3C),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(56, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSm),
                          ),
                        ),
                        child: const Icon(Icons.call),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // Saved vets section
            const Text(
              'Mis veterinarios guardados',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            if (savedVets.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSizes.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(
                    color: AppColors.textLight.withOpacity(0.2),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.pets, size: 40, color: AppColors.textLight),
                    SizedBox(height: AppSizes.sm),
                    Text(
                      'Aún no tienes citas guardadas',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Las clínicas y veterinarios aparecerán aquí cuando agregues citas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...savedVets.map((vet) => _SavedVetCard(vet: vet)),

            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }
}

class _SavedVet {
  final String vetName;
  final String? clinic;

  const _SavedVet({required this.vetName, this.clinic});
}

class _SavedVetCard extends StatelessWidget {
  final _SavedVet vet;

  const _SavedVetCard({required this.vet});

  Future<void> _searchVetOnMaps(BuildContext context) async {
    final query = Uri.encodeComponent(
      vet.clinic != null ? '${vet.clinic} ${vet.vetName}' : vet.vetName,
    );
    final url = Uri.parse('https://maps.google.com/?q=$query');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Google Maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: const Icon(Icons.medical_services,
                color: AppColors.secondary, size: 26),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vet.vetName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                if (vet.clinic != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    vet.clinic!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _searchVetOnMaps(context),
            icon: const Icon(Icons.map_outlined, color: AppColors.secondary),
            tooltip: 'Buscar en Maps',
          ),
        ],
      ),
    );
  }
}
