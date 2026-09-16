import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../inti/konstanta/warna_aplikasi.dart';
import '../../../inti/konstanta/dimensi_aplikasi.dart';
import '../../../inti/utilitas/penerjemah_kesalahan_perhitungan.dart';
import '../../../inti/utilitas/utilitas_tanggal.dart' as du;
import '../../../komponen/kartu_hasil_konversi.dart';
import '../pengontrol/pengontrol_konversi_tanggal.dart';

class DateConverterPage extends StatelessWidget {
  const DateConverterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DateConverterController(),
      child: const _DateConverterView(),
    );
  }
}

class _DateConverterView extends StatelessWidget {
  const _DateConverterView();

  Future<void> _pickDate(BuildContext context, DateConverterController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDateTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 100),
    );
    if (picked == null) return;
    final merged = DateTime(
      picked.year,
      picked.month,
      picked.day,
      controller.selectedDateTime.hour,
      controller.selectedDateTime.minute,
    );
    controller.setSelectedDateTime(merged);
  }

  Future<void> _pickTime(BuildContext context, DateConverterController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(controller.selectedDateTime),
    );
    if (picked == null) return;
    final current = controller.selectedDateTime;
    controller.setSelectedDateTime(
      DateTime(current.year, current.month, current.day, picked.hour, picked.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DateConverterController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Konversi Tanggal & Umur')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
        children: [
          Row(
            children: [
              Expanded(
                child: _PickerButton(
                  icon: Icons.calendar_today_outlined,
                  label: du.DateUtils.formatFullDate(controller.selectedDateTime),
                  onTap: () => _pickDate(context, controller),
                ),
              ),
              const SizedBox(width: AppDimensions.fieldGap),
              _PickerButton(
                icon: Icons.access_time_outlined,
                label: du.DateUtils.formatTime(controller.selectedDateTime),
                onTap: () => _pickTime(context, controller),
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          _FilterSegments(controller: controller),
          const SizedBox(height: AppDimensions.sectionGap),
          if (controller.isVisible(DateConverterFilter.masehi))
            _MasehiCard(controller: controller),
          if (controller.isVisible(DateConverterFilter.masehi))
            const SizedBox(height: AppDimensions.fieldGap),
          if (controller.isVisible(DateConverterFilter.hijriah))
            _HijriahCard(controller: controller),
          if (controller.isVisible(DateConverterFilter.hijriah))
            const SizedBox(height: AppDimensions.fieldGap),
          if (controller.isVisible(DateConverterFilter.weton))
            _WetonCard(controller: controller),
          if (controller.isVisible(DateConverterFilter.weton))
            const SizedBox(height: AppDimensions.fieldGap),
          if (controller.isVisible(DateConverterFilter.sakaBali))
            _SakaBaliCard(controller: controller),
          if (controller.isVisible(DateConverterFilter.sakaBali))
            const SizedBox(height: AppDimensions.fieldGap),
          // Usia realtime is shown regardless of segment filter — it's
          // not one of the 5 filter options, it's a standing feature.
          _UsiaCard(controller: controller),
        ],
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
        onTap: onTap,
        child: Container(
          height: AppDimensions.minTouchTarget,
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          ),
          child: Row(
            mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSegments extends StatelessWidget {
  const _FilterSegments({required this.controller});

  final DateConverterController controller;

  static const _options = {
    DateConverterFilter.semua: 'Semua',
    DateConverterFilter.masehi: 'Masehi',
    DateConverterFilter.hijriah: 'Hijriah',
    DateConverterFilter.weton: 'Weton',
    DateConverterFilter.sakaBali: 'Saka Bali',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.space8,
      runSpacing: AppDimensions.space8,
      children: [
        for (final entry in _options.entries)
          ChoiceChip(
            label: Text(entry.value),
            selected: controller.filter == entry.key,
            onSelected: (_) => controller.setFilter(entry.key),
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: controller.filter == entry.key
                  ? Colors.white
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              side: const BorderSide(color: AppColors.divider),
            ),
          ),
      ],
    );
  }
}

class _MasehiCard extends StatelessWidget {
  const _MasehiCard({required this.controller});

  final DateConverterController controller;

  @override
  Widget build(BuildContext context) {
    final date = controller.selectedDateTime;
    return ConversionResultCard(
      title: 'Masehi',
      icon: Icons.calendar_today_outlined,
      rows: [
        ConversionRow('Tanggal', du.DateUtils.formatFullDate(date)),
        ConversionRow('Waktu', du.DateUtils.formatTime(date)),
      ],
    );
  }
}

class _HijriahCard extends StatelessWidget {
  const _HijriahCard({required this.controller});

  final DateConverterController controller;

  @override
  Widget build(BuildContext context) {
    final outcome = controller.hijriOutcome;
    if (!outcome.isSuccess) {
      return ConversionErrorCard(
        title: 'Hijriah',
        icon: Icons.brightness_3_outlined,
        message: calculationErrorMessage(outcome.error!),
      );
    }
    final result = outcome.result!;
    return ConversionResultCard(
      title: 'Hijriah',
      icon: Icons.brightness_3_outlined,
      rows: [
        ConversionRow(
          'Tanggal',
          '${result.day} ${result.monthName} ${result.year} H',
        ),
      ],
      footnote: 'Perhitungan algoritmik/offline — dapat berbeda 1-2 hari dari penetapan resmi.',
    );
  }
}

class _WetonCard extends StatelessWidget {
  const _WetonCard({required this.controller});

  final DateConverterController controller;

  @override
  Widget build(BuildContext context) {
    final weton = controller.wetonResult;
    return ConversionResultCard(
      title: 'Weton',
      icon: Icons.brightness_5_outlined,
      rows: [
        ConversionRow('Weton', weton.wetonLabel),
        ConversionRow('Neptu ${weton.dayName}', '${weton.neptuDay}'),
        ConversionRow('Neptu ${weton.pasaran}', '${weton.neptuPasaran}'),
        ConversionRow('Total Neptu', '${weton.totalNeptu}'),
      ],
    );
  }
}

class _SakaBaliCard extends StatelessWidget {
  const _SakaBaliCard({required this.controller});

  final DateConverterController controller;

  @override
  Widget build(BuildContext context) {
    final saka = controller.sakaResult;
    return ConversionResultCard(
      title: 'Saka Bali',
      icon: Icons.temple_hindu_outlined,
      rows: [
        ConversionRow('Wuku', '${saka.wuku} (hari ke-${saka.wukuDayIndex})'),
        ConversionRow('Pancawara', saka.pancawara),
        ConversionRow('Saptawara', saka.saptawara),
      ],
      footnote: saka.isLunarDataComplete
          ? null
          : 'Sasih & Tahun Saka presisi belum tersedia pada versi ini.',
    );
  }
}

class _UsiaCard extends StatelessWidget {
  const _UsiaCard({required this.controller});

  final DateConverterController controller;

  @override
  Widget build(BuildContext context) {
    final outcome = controller.ageOutcome;
    if (!outcome.isSuccess) {
      return ConversionErrorCard(
        title: 'Usia',
        icon: Icons.hourglass_bottom_outlined,
        message: calculationErrorMessage(outcome.error!),
      );
    }
    final age = outcome.result!;
    return ConversionResultCard(
      title: 'Usia (realtime)',
      icon: Icons.hourglass_bottom_outlined,
      accentColor: AppColors.primaryTeal,
      rows: [
        ConversionRow('Tahun', '${age.years}'),
        ConversionRow('Bulan', '${age.months}'),
        ConversionRow('Hari', '${age.days}'),
        ConversionRow(
          'Jam:Menit:Detik',
          '${age.hours.toString().padLeft(2, '0')}:'
              '${age.minutes.toString().padLeft(2, '0')}:'
              '${age.seconds.toString().padLeft(2, '0')}',
        ),
      ],
    );
  }
}
