import 'package:flutter/material.dart';
import '../../../models/pet_model.dart';

class BreedSkin {
  final Color primaryColor;
  final Color secondaryColor;
  final Color noseColor;
  final String earShape; // 'floppy', 'pointy', 'rounded'
  final Color? eyeColor;
  final bool hasMustache;
  final bool hasPatch;
  final Color? patchColor;

  const BreedSkin({
    required this.primaryColor,
    required this.secondaryColor,
    required this.noseColor,
    required this.earShape,
    this.eyeColor,
    this.hasMustache = false,
    this.hasPatch = false,
    this.patchColor,
  });
}

class BreedSkins {
  static const Map<String, BreedSkin> skins = {
    'labrador': BreedSkin(
      primaryColor: Color(0xFFD4A017),
      secondaryColor: Color(0xFFF5DEB3),
      noseColor: Color(0xFF333333),
      earShape: 'floppy',
    ),
    'husky': BreedSkin(
      primaryColor: Color(0xFF9E9E9E),
      secondaryColor: Color(0xFFFFFFFF),
      noseColor: Color(0xFF111111),
      earShape: 'pointy',
      eyeColor: Color(0xFF64B5F6),
      hasPatch: true,
      patchColor: Color(0xFF555555),
    ),
    'poodle': BreedSkin(
      primaryColor: Color(0xFFF5F5F5),
      secondaryColor: Color(0xFFEEEEEE),
      noseColor: Color(0xFFFF69B4),
      earShape: 'floppy',
    ),
    'bulldog': BreedSkin(
      primaryColor: Color(0xFFD2B48C),
      secondaryColor: Color(0xFFF5DEB3),
      noseColor: Color(0xFF444444),
      earShape: 'rounded',
      hasMustache: true,
    ),
    'german shepherd': BreedSkin(
      primaryColor: Color(0xFF8B4513),
      secondaryColor: Color(0xFFD2691E),
      noseColor: Color(0xFF222222),
      earShape: 'pointy',
      hasPatch: true,
      patchColor: Color(0xFF2C1A0E),
    ),
    'golden retriever': BreedSkin(
      primaryColor: Color(0xFFFFA500),
      secondaryColor: Color(0xFFFFD700),
      noseColor: Color(0xFF333333),
      earShape: 'floppy',
    ),
    'dachshund': BreedSkin(
      primaryColor: Color(0xFF8B2500),
      secondaryColor: Color(0xFFCD853F),
      noseColor: Color(0xFF333333),
      earShape: 'floppy',
    ),
    'pug': BreedSkin(
      primaryColor: Color(0xFFD2B48C),
      secondaryColor: Color(0xFFF5DEB3),
      noseColor: Color(0xFF555555),
      earShape: 'rounded',
      hasMustache: true,
    ),
    'shih tzu': BreedSkin(
      primaryColor: Color(0xFFF5DEB3),
      secondaryColor: Color(0xFFFFFFFF),
      noseColor: Color(0xFFFF69B4),
      earShape: 'floppy',
    ),
    'border collie': BreedSkin(
      primaryColor: Color(0xFF333333),
      secondaryColor: Color(0xFFFFFFFF),
      noseColor: Color(0xFF111111),
      earShape: 'rounded',
      hasPatch: true,
      patchColor: Color(0xFFFFFFFF),
    ),
    'default': BreedSkin(
      primaryColor: Color(0xFFAAAAAA),
      secondaryColor: Color(0xFFDDDDDD),
      noseColor: Color(0xFF333333),
      earShape: 'rounded',
    ),
  };

  static BreedSkin getSkin(String breed) {
    final key = breed.toLowerCase().trim();
    for (final entry in skins.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }
    return skins['default']!;
  }
}

class PetAvatarWidget extends StatelessWidget {
  final PetModel pet;
  final double size;
  final bool showAccessories;

  const PetAvatarWidget({
    super.key,
    required this.pet,
    this.size = 80,
    this.showAccessories = true,
  });

  @override
  Widget build(BuildContext context) {
    final skin = BreedSkins.getSkin(pet.breed);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: PetFacePainter(
          skin: skin,
          equippedHat: showAccessories ? pet.equippedHat : null,
          equippedCollar: showAccessories ? pet.equippedCollar : null,
        ),
      ),
    );
  }
}

class PetFacePainter extends CustomPainter {
  final BreedSkin skin;
  final String? equippedHat;
  final String? equippedCollar;

  PetFacePainter({
    required this.skin,
    this.equippedHat,
    this.equippedCollar,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final bodyPaint = Paint()..color = skin.primaryColor;
    final secondaryPaint = Paint()..color = skin.secondaryColor;
    final nosePaint = Paint()..color = skin.noseColor;
    final eyePaint = Paint()..color = skin.eyeColor ?? const Color(0xFF3E2723);
    final eyeWhitePaint = Paint()..color = Colors.white;
    final outlinePaint = Paint()
      ..color = skin.primaryColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw ears based on shape
    _drawEars(canvas, w, h, cx, cy, bodyPaint, outlinePaint);

    // Draw main face circle
    canvas.drawCircle(Offset(cx, cy * 1.05), w * 0.38, bodyPaint);

    // Draw snout area (lighter color oval)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy * 1.2),
        width: w * 0.42,
        height: h * 0.28,
      ),
      secondaryPaint,
    );

    // Draw patch if breed has one
    if (skin.hasPatch && skin.patchColor != null) {
      final patchPaint = Paint()..color = skin.patchColor!;
      canvas.drawCircle(Offset(cx + w * 0.08, cy * 0.85), w * 0.18, patchPaint);
    }

    // Draw eyes
    final eyeY = cy * 0.9;
    final eyeSpacing = w * 0.18;

    // Eye whites
    canvas.drawCircle(Offset(cx - eyeSpacing, eyeY), w * 0.1, eyeWhitePaint);
    canvas.drawCircle(Offset(cx + eyeSpacing, eyeY), w * 0.1, eyeWhitePaint);

    // Eye pupils
    canvas.drawCircle(Offset(cx - eyeSpacing + 1, eyeY + 1), w * 0.065, eyePaint);
    canvas.drawCircle(Offset(cx + eyeSpacing + 1, eyeY + 1), w * 0.065, eyePaint);

    // Eye shine
    final shinePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - eyeSpacing - 2, eyeY - 3), w * 0.022, shinePaint);
    canvas.drawCircle(Offset(cx + eyeSpacing - 2, eyeY - 3), w * 0.022, shinePaint);

    // Nose
    final nosePath = Path();
    nosePath.moveTo(cx, cy * 1.12);
    nosePath.quadraticBezierTo(cx - w * 0.09, cy * 1.12, cx - w * 0.09, cy * 1.18);
    nosePath.quadraticBezierTo(cx - w * 0.09, cy * 1.24, cx, cy * 1.26);
    nosePath.quadraticBezierTo(cx + w * 0.09, cy * 1.24, cx + w * 0.09, cy * 1.18);
    nosePath.quadraticBezierTo(cx + w * 0.09, cy * 1.12, cx, cy * 1.12);
    canvas.drawPath(nosePath, nosePaint);

    // Mouth
    final mouthPaint = Paint()
      ..color = skin.noseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path();
    mouthPath.moveTo(cx - w * 0.09, cy * 1.28);
    mouthPath.quadraticBezierTo(cx, cy * 1.38, cx + w * 0.09, cy * 1.28);
    canvas.drawPath(mouthPath, mouthPaint);

    // Mustache (for bulldogs, pugs)
    if (skin.hasMustache) {
      final mustachePaint = Paint()
        ..color = skin.noseColor.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      // Left whiskers
      canvas.drawLine(Offset(cx - w * 0.24, cy * 1.15), Offset(cx - w * 0.08, cy * 1.18), mustachePaint);
      canvas.drawLine(Offset(cx - w * 0.24, cy * 1.22), Offset(cx - w * 0.08, cy * 1.22), mustachePaint);
      // Right whiskers
      canvas.drawLine(Offset(cx + w * 0.24, cy * 1.15), Offset(cx + w * 0.08, cy * 1.18), mustachePaint);
      canvas.drawLine(Offset(cx + w * 0.24, cy * 1.22), Offset(cx + w * 0.08, cy * 1.22), mustachePaint);
    }

    // Hat accessory
    if (equippedHat != null) {
      _drawHat(canvas, w, h, cx, cy, equippedHat!);
    }

    // Collar accessory
    if (equippedCollar != null) {
      _drawCollar(canvas, w, h, cx, cy, equippedCollar!);
    }
  }

  void _drawEars(Canvas canvas, double w, double h, double cx, double cy, Paint bodyPaint, Paint outlinePaint) {
    switch (skin.earShape) {
      case 'floppy':
        // Large floppy ears hanging down
        final leftEarRect = Rect.fromCenter(
          center: Offset(cx - w * 0.36, cy * 1.0),
          width: w * 0.28,
          height: h * 0.42,
        );
        canvas.drawOval(leftEarRect, bodyPaint);
        canvas.drawOval(leftEarRect, outlinePaint);

        final rightEarRect = Rect.fromCenter(
          center: Offset(cx + w * 0.36, cy * 1.0),
          width: w * 0.28,
          height: h * 0.42,
        );
        canvas.drawOval(rightEarRect, bodyPaint);
        canvas.drawOval(rightEarRect, outlinePaint);
        break;

      case 'pointy':
        // Pointed upright ears
        final leftPath = Path();
        leftPath.moveTo(cx - w * 0.26, cy * 0.68);
        leftPath.lineTo(cx - w * 0.42, cy * 0.18);
        leftPath.lineTo(cx - w * 0.12, cy * 0.62);
        leftPath.close();
        canvas.drawPath(leftPath, bodyPaint);

        final rightPath = Path();
        rightPath.moveTo(cx + w * 0.26, cy * 0.68);
        rightPath.lineTo(cx + w * 0.42, cy * 0.18);
        rightPath.lineTo(cx + w * 0.12, cy * 0.62);
        rightPath.close();
        canvas.drawPath(rightPath, bodyPaint);
        break;

      case 'rounded':
      default:
        // Rounded top ears
        canvas.drawCircle(Offset(cx - w * 0.3, cy * 0.62), w * 0.16, bodyPaint);
        canvas.drawCircle(Offset(cx + w * 0.3, cy * 0.62), w * 0.16, bodyPaint);
        break;
    }
  }

  void _drawHat(Canvas canvas, double w, double h, double cx, double cy, String hatId) {
    if (hatId == 'hat_party') {
      final hatPaint = Paint()..color = const Color(0xFFFF6B35);
      final hatPath = Path();
      hatPath.moveTo(cx - w * 0.18, cy * 0.55);
      hatPath.lineTo(cx, cy * 0.05);
      hatPath.lineTo(cx + w * 0.18, cy * 0.55);
      hatPath.close();
      canvas.drawPath(hatPath, hatPaint);
      // Hat band
      canvas.drawRect(
        Rect.fromLTWH(cx - w * 0.18, cy * 0.48, w * 0.36, h * 0.06),
        Paint()..color = const Color(0xFFFFE66D),
      );
    } else if (hatId == 'hat_crown') {
      final crownPaint = Paint()..color = const Color(0xFFFFD700);
      final crownPath = Path();
      crownPath.moveTo(cx - w * 0.2, cy * 0.58);
      crownPath.lineTo(cx - w * 0.2, cy * 0.35);
      crownPath.lineTo(cx - w * 0.07, cy * 0.48);
      crownPath.lineTo(cx, cy * 0.28);
      crownPath.lineTo(cx + w * 0.07, cy * 0.48);
      crownPath.lineTo(cx + w * 0.2, cy * 0.35);
      crownPath.lineTo(cx + w * 0.2, cy * 0.58);
      crownPath.close();
      canvas.drawPath(crownPath, crownPaint);
    } else if (hatId == 'hat_cowboy') {
      final hatPaint = Paint()..color = const Color(0xFF8B4513);
      // Brim
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy * 0.58), width: w * 0.56, height: h * 0.1),
        hatPaint,
      );
      // Top
      canvas.drawRect(
        Rect.fromCenter(center: Offset(cx, cy * 0.42), width: w * 0.32, height: h * 0.2),
        hatPaint,
      );
    }
  }

  void _drawCollar(Canvas canvas, double w, double h, double cx, double cy, String collarId) {
    Color collarColor;
    if (collarId == 'collar_bow') {
      collarColor = const Color(0xFFFF69B4);
    } else if (collarId == 'collar_diamond') {
      collarColor = const Color(0xFF4ECDC4);
    } else {
      collarColor = const Color(0xFFFFE66D);
    }

    // Collar band
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy * 1.55), width: w * 0.55, height: h * 0.07),
      Paint()..color = collarColor,
    );

    if (collarId == 'collar_bow') {
      // Bow
      final bowPaint = Paint()..color = const Color(0xFFFF1493);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - w * 0.08, cy * 1.55), width: w * 0.12, height: h * 0.1),
        bowPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + w * 0.08, cy * 1.55), width: w * 0.12, height: h * 0.1),
        bowPaint,
      );
      canvas.drawCircle(Offset(cx, cy * 1.55), w * 0.04, bowPaint);
    } else if (collarId == 'collar_diamond') {
      // Diamond studs
      for (int i = -1; i <= 1; i++) {
        canvas.drawCircle(
          Offset(cx + i * w * 0.12, cy * 1.55),
          w * 0.03,
          Paint()..color = Colors.white,
        );
      }
    }
  }

  @override
  bool shouldRepaint(PetFacePainter oldDelegate) {
    return oldDelegate.skin != skin ||
        oldDelegate.equippedHat != equippedHat ||
        oldDelegate.equippedCollar != equippedCollar;
  }
}
