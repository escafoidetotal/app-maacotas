import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/pet_model.dart';
import '../../services/hive_service.dart';

class PdfExportScreen extends StatefulWidget {
  const PdfExportScreen({super.key});

  @override
  State<PdfExportScreen> createState() => _PdfExportScreenState();
}

class _PdfExportScreenState extends State<PdfExportScreen> {
  PetModel? _selectedPet;
  bool _includeVaccines = true;
  bool _includeWeight = true;
  bool _includeDeworming = true;
  bool _includeMedications = true;
  bool _includeVetAppointments = true;
  bool _isGenerating = false;

  List<PetModel> get _pets => HiveService.getAllPets();

  @override
  void initState() {
    super.initState();
    final pets = _pets;
    if (pets.isNotEmpty) {
      _selectedPet = pets.first;
    }
  }

  String _calculateAge(DateTime birthdate) {
    final now = DateTime.now();
    int months = (now.year - birthdate.year) * 12 + now.month - birthdate.month;
    if (now.day < birthdate.day) months--;
    if (months < 12) {
      return '$months ${months == 1 ? 'mes' : 'meses'}';
    }
    final years = months ~/ 12;
    final rem = months % 12;
    if (rem == 0) return '$years ${years == 1 ? 'año' : 'años'}';
    return '$years ${years == 1 ? 'año' : 'años'} y $rem ${rem == 1 ? 'mes' : 'meses'}';
  }

  Future<void> _generatePdf() async {
    final pet = _selectedPet;
    if (pet == null) return;

    setState(() => _isGenerating = true);

    try {
      final doc = pw.Document();
      final now = DateTime.now();
      final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(now);

      // Colors
      final primaryColor = PdfColor.fromHex('FF6B35');
      final lightOrange = PdfColor.fromHex('FFECE3');
      final grey = PdfColor.fromHex('636E72');
      final darkColor = PdfColor.fromHex('2D3436');

      // Data
      final vaccines = _includeVaccines ? HiveService.getVaccinesForPet(pet.id) : [];
      final weights = _includeWeight ? HiveService.getWeightRecordsForPet(pet.id) : [];
      final dewormings = _includeDeworming ? HiveService.getDewormingForPet(pet.id) : [];
      final medications = _includeMedications ? HiveService.getMedicationsForPet(pet.id) : [];
      final appointments = _includeVetAppointments ? HiveService.getVetAppointmentsForPet(pet.id) : [];

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => pw.Container(
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MaaCOTAS',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Historial de salud',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      pet.name,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      pet.breed,
                      style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
                    ),
                    pw.Text(
                      _calculateAge(pet.birthdate),
                      style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              'Generado el $dateStr  |  Página ${context.pageNumber} de ${context.pagesCount}',
              style: pw.TextStyle(color: grey, fontSize: 9),
            ),
          ),
          build: (context) {
            final widgets = <pw.Widget>[];

            widgets.add(pw.SizedBox(height: 12));

            // Pet info card
            widgets.add(
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: lightOrange,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: primaryColor, width: 0.5),
                ),
                padding: const pw.EdgeInsets.all(12),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _pdfInfoItem('Nombre', pet.name, primaryColor, darkColor),
                    _pdfInfoItem('Raza', pet.breed, primaryColor, darkColor),
                    _pdfInfoItem('Edad', _calculateAge(pet.birthdate), primaryColor, darkColor),
                    _pdfInfoItem('Peso', '${pet.weight} kg', primaryColor, darkColor),
                    _pdfInfoItem('Sexo', pet.gender == 'male' ? 'Macho' : 'Hembra', primaryColor, darkColor),
                  ],
                ),
              ),
            );

            widgets.add(pw.SizedBox(height: 16));

            // Vaccines section
            if (_includeVaccines) {
              widgets.add(_pdfSectionTitle('Vacunas', primaryColor));
              widgets.add(pw.SizedBox(height: 6));
              if (vaccines.isEmpty) {
                widgets.add(_pdfEmptyRow(grey));
              } else {
                widgets.add(
                  pw.TableHelper.fromTextArray(
                    headers: ['Vacuna', 'Fecha', 'Próxima dosis', 'Notas'],
                    data: vaccines.map((v) => [
                      v.name,
                      DateFormat('dd/MM/yyyy').format(v.vaccineDate),
                      v.nextDoseDate != null ? DateFormat('dd/MM/yyyy').format(v.nextDoseDate!) : '-',
                      v.notes ?? '-',
                    ]).toList(),
                    headerStyle: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                    headerDecoration: pw.BoxDecoration(color: primaryColor),
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    cellAlignments: {
                      0: pw.Alignment.centerLeft,
                      1: pw.Alignment.center,
                      2: pw.Alignment.center,
                      3: pw.Alignment.centerLeft,
                    },
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    oddRowDecoration: pw.BoxDecoration(color: PdfColors.grey100),
                  ),
                );
              }
              widgets.add(pw.SizedBox(height: 14));
            }

            // Weight section
            if (_includeWeight) {
              widgets.add(_pdfSectionTitle('Historial de peso', primaryColor));
              widgets.add(pw.SizedBox(height: 6));
              if (weights.isEmpty) {
                widgets.add(_pdfEmptyRow(grey));
              } else {
                widgets.add(
                  pw.TableHelper.fromTextArray(
                    headers: ['Fecha', 'Peso (kg)', 'Notas'],
                    data: weights.map((w) => [
                      DateFormat('dd/MM/yyyy').format(w.recordDate),
                      w.weight.toStringAsFixed(2),
                      w.notes ?? '-',
                    ]).toList(),
                    headerStyle: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                    headerDecoration: pw.BoxDecoration(color: primaryColor),
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    oddRowDecoration: pw.BoxDecoration(color: PdfColors.grey100),
                  ),
                );
              }
              widgets.add(pw.SizedBox(height: 14));
            }

            // Deworming section
            if (_includeDeworming) {
              widgets.add(_pdfSectionTitle('Desparasitación', primaryColor));
              widgets.add(pw.SizedBox(height: 6));
              if (dewormings.isEmpty) {
                widgets.add(_pdfEmptyRow(grey));
              } else {
                widgets.add(
                  pw.TableHelper.fromTextArray(
                    headers: ['Tipo', 'Producto', 'Fecha aplicación', 'Próxima aplicación'],
                    data: dewormings.map((d) => [
                      d.type == 'internal' ? 'Interno' : 'Externo',
                      d.productName,
                      DateFormat('dd/MM/yyyy').format(d.applicationDate),
                      d.nextApplicationDate != null
                          ? DateFormat('dd/MM/yyyy').format(d.nextApplicationDate!)
                          : '-',
                    ]).toList(),
                    headerStyle: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                    headerDecoration: pw.BoxDecoration(color: primaryColor),
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    oddRowDecoration: pw.BoxDecoration(color: PdfColors.grey100),
                  ),
                );
              }
              widgets.add(pw.SizedBox(height: 14));
            }

            // Medications section
            if (_includeMedications) {
              widgets.add(_pdfSectionTitle('Medicamentos', primaryColor));
              widgets.add(pw.SizedBox(height: 6));
              if (medications.isEmpty) {
                widgets.add(_pdfEmptyRow(grey));
              } else {
                widgets.add(
                  pw.TableHelper.fromTextArray(
                    headers: ['Medicamento', 'Dosis', 'Frecuencia', 'Inicio', 'Fin', 'Activo'],
                    data: medications.map((m) => [
                      m.name,
                      m.dose,
                      m.frequency,
                      DateFormat('dd/MM/yyyy').format(m.startDate),
                      m.endDate != null ? DateFormat('dd/MM/yyyy').format(m.endDate!) : '-',
                      m.isActive ? 'Sí' : 'No',
                    ]).toList(),
                    headerStyle: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                    headerDecoration: pw.BoxDecoration(color: primaryColor),
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    oddRowDecoration: pw.BoxDecoration(color: PdfColors.grey100),
                  ),
                );
              }
              widgets.add(pw.SizedBox(height: 14));
            }

            // Vet appointments section
            if (_includeVetAppointments) {
              widgets.add(_pdfSectionTitle('Citas Veterinarias', primaryColor));
              widgets.add(pw.SizedBox(height: 6));
              if (appointments.isEmpty) {
                widgets.add(_pdfEmptyRow(grey));
              } else {
                widgets.add(
                  pw.TableHelper.fromTextArray(
                    headers: ['Motivo', 'Fecha', 'Veterinario', 'Clínica', 'Estado'],
                    data: appointments.map((a) => [
                      a.reason ?? '-',
                      DateFormat('dd/MM/yyyy').format(a.appointmentDate),
                      a.vetName,
                      a.clinic ?? '-',
                      a.isCompleted ? 'Completada' : 'Pendiente',
                    ]).toList(),
                    headerStyle: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                    headerDecoration: pw.BoxDecoration(color: primaryColor),
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    oddRowDecoration: pw.BoxDecoration(color: PdfColors.grey100),
                  ),
                );
              }
              widgets.add(pw.SizedBox(height: 14));
            }

            return widgets;
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => doc.save(),
        name: 'MaaCOTAS_${pet.name}_${DateFormat('yyyyMMdd').format(now)}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  pw.Widget _pdfSectionTitle(String title, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _pdfEmptyRow(PdfColor grey) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        'Sin registros',
        style: pw.TextStyle(color: grey, fontSize: 9, fontStyle: pw.FontStyle.italic),
      ),
    );
  }

  pw.Widget _pdfInfoItem(String label, String value, PdfColor labelColor, PdfColor valueColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label, style: pw.TextStyle(color: labelColor, fontSize: 8, fontWeight: pw.FontWeight.bold)),
        pw.Text(value, style: pw.TextStyle(color: valueColor, fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pets = _pets;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Exportar PDF'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: pets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 64, color: AppColors.textLight.withOpacity(0.5)),
                  const SizedBox(height: AppSizes.md),
                  const Text(
                    'No hay mascotas registradas',
                    style: TextStyle(color: AppColors.textLight, fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet selector
                  const Text(
                    'Seleccionar mascota',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: pets.map((pet) {
                        final isSelected = _selectedPet?.id == pet.id;
                        return RadioListTile<PetModel>(
                          title: Text(
                            pet.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.primary : AppColors.textDark,
                            ),
                          ),
                          subtitle: Text(
                            pet.breed,
                            style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                          ),
                          value: pet,
                          groupValue: _selectedPet,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _selectedPet = val),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Sections selector
                  const Text(
                    'Secciones a incluir',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _SectionCheckbox(
                          label: 'Vacunas',
                          icon: Icons.vaccines,
                          color: const Color(0xFF3498DB),
                          value: _includeVaccines,
                          onChanged: (v) => setState(() => _includeVaccines = v ?? true),
                        ),
                        _divider(),
                        _SectionCheckbox(
                          label: 'Peso',
                          icon: Icons.monitor_weight,
                          color: const Color(0xFF2ECC71),
                          value: _includeWeight,
                          onChanged: (v) => setState(() => _includeWeight = v ?? true),
                        ),
                        _divider(),
                        _SectionCheckbox(
                          label: 'Desparasitación',
                          icon: Icons.pest_control,
                          color: const Color(0xFFE67E22),
                          value: _includeDeworming,
                          onChanged: (v) => setState(() => _includeDeworming = v ?? true),
                        ),
                        _divider(),
                        _SectionCheckbox(
                          label: 'Medicamentos',
                          icon: Icons.medication,
                          color: const Color(0xFFE74C3C),
                          value: _includeMedications,
                          onChanged: (v) => setState(() => _includeMedications = v ?? true),
                        ),
                        _divider(),
                        _SectionCheckbox(
                          label: 'Citas Vet',
                          icon: Icons.local_hospital,
                          color: const Color(0xFF9B59B6),
                          value: _includeVetAppointments,
                          onChanged: (v) => setState(() => _includeVetAppointments = v ?? true),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.xl),

                  // Generate button
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: (_selectedPet == null || _isGenerating) ? null : _generatePdf,
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.picture_as_pdf),
                      label: Text(_isGenerating ? 'Generando...' : 'Generar PDF'),
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
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 16, endIndent: 16);
}

class _SectionCheckbox extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _SectionCheckbox({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textDark),
          ),
        ],
      ),
      value: value,
      activeColor: AppColors.primary,
      controlAffinity: ListTileControlAffinity.trailing,
      onChanged: onChanged,
    );
  }
}
