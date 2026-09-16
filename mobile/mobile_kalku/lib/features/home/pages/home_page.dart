import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/database/database_helper.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/bmi_repository.dart';
import '../../bmi/pages/bmi_calculator_page.dart';
import '../../bmi/pages/bmi_history_page.dart';
import '../../calendar/pages/nusantara_calendar_page.dart';
import '../../date_converter/pages/date_converter_page.dart';
import '../../members/pages/members_page.dart';
import '../widgets/home_menu_card.dart';

/// Home tab: greeting header + the 5 required vertical menu items
/// (MENU_IMPLEMENTATION.md #4). Home must not contain BMI/calendar logic
/// — it only navigates via `Navigator.push()`.
///
/// [user] is the authenticated user from Splash/Login, propagated to
/// Dev1 BMI pages (calculator, history) so records are scoped correctly.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.user});

  final User user;

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
                    onTap: () async {
                      final db = await DatabaseHelper.instance.database;
                      final repo = BmiRepository(db);
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BmiCalculatorPage(
                            user: user,
                            bmiRepository: repo,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.fieldGap),
                  HomeMenuCard(
                    icon: Icons.history_outlined,
                    title: AppStrings.menuBmiHistoryTitle,
                    description: AppStrings.menuBmiHistoryDesc,
                    onTap: () async {
                      final db = await DatabaseHelper.instance.database;
                      final repo = BmiRepository(db);
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BmiHistoryPage(
                            user: user,
                            bmiRepository: repo,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.fieldGap),
                  HomeMenuCard(
                    icon: Icons.calendar_month_outlined,
                    title: AppStrings.menuDateConverterTitle,
                    description: AppStrings.menuDateConverterDesc,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DateConverterPage()),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.fieldGap),
                  HomeMenuCard(
                    icon: Icons.temple_hindu_outlined,
                    title: AppStrings.menuCalendarTitle,
                    description: AppStrings.menuCalendarDesc,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NusantaraCalendarPage()),
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