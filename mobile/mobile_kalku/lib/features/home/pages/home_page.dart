import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../widgets/coming_soon_page.dart';
import '../../members/pages/members_page.dart';
import '../widgets/home_menu_card.dart';

/// Home tab: greeting header + the 5 required vertical menu items
/// (MENU_IMPLEMENTATION.md #4). Home must not contain BMI/calendar logic
/// — it only navigates via `Navigator.push()`.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _HomeHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
                children: [
                  HomeMenuCard(
                    icon: Icons.groups_outlined,
                    title: AppStrings.menuMembersTitle,
                    description: AppStrings.menuMembersDesc,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MembersPage()),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.fieldGap),
                  HomeMenuCard(
                    icon: Icons.monitor_weight_outlined,
                    title: AppStrings.menuBmiCalculatorTitle,
                    description: AppStrings.menuBmiCalculatorDesc,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ComingSoonPage(
                          title: AppStrings.menuBmiCalculatorTitle,
                          note: 'Bagian ini milik Developer 1 (BMI + SQLite).',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.fieldGap),
                  HomeMenuCard(
                    icon: Icons.history_outlined,
                    title: AppStrings.menuBmiHistoryTitle,
                    description: AppStrings.menuBmiHistoryDesc,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ComingSoonPage(
                          title: AppStrings.menuBmiHistoryTitle,
                          note: 'Bagian ini milik Developer 1 (BMI + SQLite).',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.fieldGap),
                  HomeMenuCard(
                    icon: Icons.calendar_month_outlined,
                    title: AppStrings.menuDateConverterTitle,
                    description: AppStrings.menuDateConverterDesc,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ComingSoonPage(
                          title: AppStrings.menuDateConverterTitle,
                          note: 'Menyusul di Tahap 4 (integrasi domain calculator).',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.fieldGap),
                  HomeMenuCard(
                    icon: Icons.temple_hindu_outlined,
                    title: AppStrings.menuCalendarTitle,
                    description: AppStrings.menuCalendarDesc,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ComingSoonPage(
                          title: AppStrings.menuCalendarTitle,
                          note: 'Menyusul di Tahap 4 (integrasi domain calculator).',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenHorizontalPadding,
        AppDimensions.space24,
        AppDimensions.screenHorizontalPadding,
        AppDimensions.space32,
      ),
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.appName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            AppStrings.appSubtitle,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
