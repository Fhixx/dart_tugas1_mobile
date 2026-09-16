import 'package:flutter/material.dart';

import '../inti/konstanta/warna_aplikasi.dart';
import '../inti/konstanta/dimensi_aplikasi.dart';

/// Temporary destination for Home menu items whose real screen isn't
/// implemented yet (either owned by Developer 1, or scheduled for a
/// later Developer 2 tahap). Replace with the real page once it exists —
/// do not leave Home pointing here permanently.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.title, this.note});

  final String title;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_outlined,
                  size: 56, color: AppColors.textSecondary),
              const SizedBox(height: AppDimensions.space16),
              Text(
                'Halaman ini belum tersedia',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (note != null) ...[
                const SizedBox(height: AppDimensions.space8),
                Text(
                  note!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
