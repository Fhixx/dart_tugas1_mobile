import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../inti/konstanta/warna_aplikasi.dart';
import '../../../inti/konstanta/dimensi_aplikasi.dart';
import '../../../komponen/tombol_gradasi.dart';
import '../pengontrol/pengontrol_stopwatch.dart';

/// Stopwatch screen. Owns its [StopwatchController] via a local
/// `ChangeNotifierProvider` created once here — because `MainShell` keeps
/// this page alive inside an `IndexedStack`, the controller (and its
/// running state) survives switching bottom-nav tabs, per
/// MENU_IMPLEMENTATION.md #13 ("Stopwatch tidak reset saat berpindah
/// bottom tab").
class StopwatchPage extends StatelessWidget {
  const StopwatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StopwatchController(),
      child: const _StopwatchView(),
    );
  }
}

class _StopwatchView extends StatelessWidget {
  const _StopwatchView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StopwatchController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                Icons.watch_later_outlined,
                size: 96,
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              const SizedBox(height: AppDimensions.space24),
              _ElapsedDisplay(text: controller.formattedElapsed),
              const SizedBox(height: AppDimensions.space8),
              Text(
                _statusLabel(controller.status),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              _StopwatchControls(controller: controller),
              const SizedBox(height: AppDimensions.space24),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(StopwatchStatus status) {
    switch (status) {
      case StopwatchStatus.idle:
        return 'Siap dimulai';
      case StopwatchStatus.running:
        return 'Berjalan';
      case StopwatchStatus.paused:
        return 'Dijeda';
    }
  }
}

class _ElapsedDisplay extends StatelessWidget {
  const _ElapsedDisplay({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 52,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontFeatures: [FontFeature.tabularFigures()],
        letterSpacing: 1,
      ),
    );
  }
}

class _StopwatchControls extends StatelessWidget {
  const _StopwatchControls({required this.controller});

  final StopwatchController controller;

  @override
  Widget build(BuildContext context) {
    final status = controller.status;

    late final String primaryLabel;
    late final VoidCallback primaryAction;
    late final IconData primaryIcon;

    switch (status) {
      case StopwatchStatus.idle:
        primaryLabel = 'Mulai';
        primaryAction = controller.start;
        primaryIcon = Icons.play_arrow;
        break;
      case StopwatchStatus.running:
        primaryLabel = 'Jeda';
        primaryAction = controller.pause;
        primaryIcon = Icons.pause;
        break;
      case StopwatchStatus.paused:
        primaryLabel = 'Lanjutkan';
        primaryAction = controller.resume;
        primaryIcon = Icons.play_arrow;
        break;
    }

    return Row(
      children: [
        Expanded(
          child: GradientButton(
            label: primaryLabel,
            icon: primaryIcon,
            onPressed: primaryAction,
          ),
        ),
        const SizedBox(width: AppDimensions.space16),
        Expanded(
          child: SecondaryButton(
            label: 'Reset',
            onPressed: status == StopwatchStatus.idle ? null : controller.reset,
          ),
        ),
      ],
    );
  }
}
