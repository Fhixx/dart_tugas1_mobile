import 'package:flutter/material.dart';
import '../../../core/security/session_service.dart';
import '../../../core/security/auth_contract.dart';
import '../../../core/database/admin_seed.dart';
import '../../../core/database/database_helper.dart';
import '../../../data/models/user.dart';
import 'login_page.dart';

/// Initial entry screen and authentication gate for NusaFit.
///
/// Executes initialization:
/// 1. Opens SQLite database (nusafit.db)
/// 2. Executes admin seed if not already present
/// 3. Reads secure session
/// 4. Routes to authenticated destination if valid session exists, or [LoginPage] otherwise.
class SplashPage extends StatefulWidget {
  final DatabaseHelper? databaseHelper;
  final SessionService? sessionService;
  final AuthenticatedPageBuilder? authenticatedBuilder;

  const SplashPage({
    super.key,
    this.databaseHelper,
    this.sessionService,
    this.authenticatedBuilder,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final DatabaseHelper _dbHelper;
  late final SessionService _sessionService;

  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _dbHelper = widget.databaseHelper ?? DatabaseHelper.instance;
    _sessionService = widget.sessionService ?? SessionService();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() {
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // 1. Initialize SQLite database
      final db = await _dbHelper.database;

      // 2. Ensure default admin exists
      await AdminSeed().run(db);

      // 3. Verify session
      final session = await _sessionService.readSession();
      User? sessionUser;

      if (session != null) {
        final maps = await db.query(
          'users',
          where: 'id = ? AND is_active = 1',
          whereArgs: [session.userId],
        );
        if (maps.isNotEmpty) {
          sessionUser = User.fromMap(maps.first);
        }
      }
      
      if (!mounted) return;

      if (sessionUser != null) {
        if (widget.authenticatedBuilder != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (ctx) => widget.authenticatedBuilder!(ctx, sessionUser!),
            ),
          );
        } else {
          // Fallback if no builder provided
          setState(() {
            _hasError = true;
            _errorMessage = "No authenticated route builder provided.";
          });
        }
      } else {
        // Clear any corrupt/stale session remnants
        await _sessionService.clearSession();
        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LoginPage(
              authenticatedBuilder: widget.authenticatedBuilder,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.blue,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _hasError ? _buildErrorView() : _buildLoadingView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.health_and_safety_rounded,
              size: 52,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "NusaFit",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Aplikasi Kesehatan Terpadu",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 48),
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Memuat data...",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Gagal Memuat Aplikasi",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          "Terjadi kesalahan saat inisialisasi",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 32),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _initializeApp,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text(
            "Coba Lagi",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
