import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import 'app_card.dart';

class ConversionRow {
  const ConversionRow(this.label, this.value);
  final String label;
  final String value;
}

/// Standard result card: title + icon + a list of label/value rows, with
/// an optional footnote (e.g. an accuracy disclaimer). Used by Date
/// Converter and Kalender Nusantara — presentation only, all values are
/// passed in already computed by the controller.
class ConversionResultCard extends StatelessWidget {
  const ConversionResultCard({
    super.key,
    required this.title,
    required this.icon,
    required this.rows,
    this.footnote,
    this.accentColor,
  });

  final String title;
  final IconData icon;
  final List<ConversionRow> rows;
  final String? footnote;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppDimensions.space8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    row.label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    row.value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          if (footnote != null) ...[
            const SizedBox(height: AppDimensions.space4),
            Text(
              footnote!,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error/incomplete state variant for a result card (typed failure ->
/// user-facing message, never raw enum/exception text).
class ConversionErrorCard extends StatelessWidget {
  const ConversionErrorCard({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
  });

  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Icon(icon, color: AppColors.warning, size: 20),
          const SizedBox(width: AppDimensions.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
