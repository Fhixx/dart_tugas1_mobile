import 'package:flutter/material.dart';

import '../../../inti/konstanta/warna_aplikasi.dart';
import '../../../inti/konstanta/dimensi_aplikasi.dart';
import '../data/bagian_panduan.dart';

/// Panduan tab — accordion list, never one long unbroken paragraph
/// (DESIGN_SYSTEM.md #18).
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Panduan',
         style: TextStyle(
            color: AppColors.surface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.surface,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.space8,
          horizontal: AppDimensions.space12,
        ),
        itemCount: kHelpSections.length,
          separatorBuilder: (context, _) => const SizedBox(height: AppDimensions.space8),
        itemBuilder: (context, index) {
          final section = kHelpSections[index];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            ),
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              leading: Icon(section.icon, color: AppColors.primary),
              title: Text(
                section.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(
                AppDimensions.space16,
                0,
                AppDimensions.space16,
                AppDimensions.space16,
              ),
              children: [
                for (final step in section.steps)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.space8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6, right: 8),
                          child: Icon(Icons.circle, size: 6, color: AppColors.primary),
                        ),
                        Expanded(
                          child: Text(
                            step,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
