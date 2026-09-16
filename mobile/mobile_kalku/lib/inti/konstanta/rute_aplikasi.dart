/// Central route name constants.
///
/// NOTE: Named routes only cover top-level navigation. Screens that need
/// typed data passed via constructor (e.g. BmiResultPage, BmiEditPage)
/// are still expected to use `Navigator.push(MaterialPageRoute(...))`
/// directly per MENU_IMPLEMENTATION.md / WRITING_RULES.md #12 — named
/// routes here exist mainly for splash/login/mainShell/logout evidence.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String mainShell = '/main';

  // Home children (pushed via Navigator.push, not necessarily named)
  static const String members = '/members';
  static const String bmiCalculator = '/bmi/calculator';
  static const String bmiResult = '/bmi/result';
  static const String bmiHistory = '/bmi/history';
  static const String bmiDetail = '/bmi/detail';
  static const String bmiEdit = '/bmi/edit';
  static const String dateConverter = '/date-converter';
  static const String nusantaraCalendar = '/calendar';

  // Bottom nav tabs (rendered inside MainShell IndexedStack, not routed)
  static const String stopwatch = '/stopwatch';
  static const String panduan = '/panduan';
}
