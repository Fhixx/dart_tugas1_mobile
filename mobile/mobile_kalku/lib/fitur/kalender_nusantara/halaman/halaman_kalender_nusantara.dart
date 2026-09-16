import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../widgets/conversion_result_card.dart';
import '../controller/nusantara_calendar_controller.dart';

class NusantaraCalendarPage extends StatelessWidget {
  const NusantaraCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NusantaraCalendarController(),
      child: const _NusantaraCalendarView(),
    );
  }
}

class _NusantaraCalendarView extends StatelessWidget {
  const _NusantaraCalendarView();

  Future<void> _pickDate(
    BuildContext context,
    NusantaraCalendarController controller,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 100),
    );
    if (picked != null) controller.setSelectedDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NusantaraCalendarController>();
    final weton = controller.wetonResult;
    final saka = controller.sakaResult;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Kalender Nusantara')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
        children: [
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
              onTap: () => _pickDate(context, controller),
              child: Container(
                height: AppDimensions.minTouchTarget,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      du.DateUtils.formatFullDate(controller.selectedDate),
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.sectionGap),
          ConversionResultCard(
            title: 'Weton',
            icon: Icons.brightness_5_outlined,
            rows: [
              ConversionRow('Hari', weton.dayName),
              ConversionRow('Pasaran', weton.pasaran),
              ConversionRow('Weton', weton.wetonLabel),
              ConversionRow('Neptu ${weton.dayName}', '${weton.neptuDay}'),
              ConversionRow('Neptu ${weton.pasaran}', '${weton.neptuPasaran}'),
              ConversionRow('Total Neptu', '${weton.totalNeptu}'),
            ],
          ),
          const SizedBox(height: AppDimensions.fieldGap),
          ConversionResultCard(
            title: 'Saka Bali',
            icon: Icons.temple_hindu_outlined,
            rows: [
              ConversionRow('Wuku', saka.wuku),
              ConversionRow('Hari dalam Wuku', 'ke-${saka.wukuDayIndex} dari 7'),
              ConversionRow('Pancawara', saka.pancawara),
              ConversionRow('Saptawara', saka.saptawara),
              ConversionRow(
                'Sasih',
                saka.sasih ?? 'Segera hadir',
              ),
              ConversionRow(
                'Tahun Saka',
                saka.tahunSaka?.toString() ?? 'Segera hadir',
              ),
            ],
            footnote: saka.isLunarDataComplete
                ? null
                : 'Sasih & Tahun Saka presisi menunggu algoritma lunisolar terverifikasi — lihat catatan di bali_calendar_converter.dart.',
          ),
        ],
      ),
    );
  }
}
