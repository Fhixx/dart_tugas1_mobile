import 'package:flutter/material.dart';
import '../../../data/model/pengguna.dart';
import '../../../data/repositori/repositori_bmi.dart';
import '../pengontrol/pengontrol_perhitungan_bmi.dart';
import 'halaman_hasil_bmi.dart';
import '../../../inti/konstanta/warna_aplikasi.dart';

/// BMI Calculator input screen.
///
/// Receives the authenticated [user] so the saved record is correctly
/// attributed. Does NOT hardcode userId = 1.
///
/// On valid calculation, pushes [BmiResultPage] via Navigator.push() so
/// the user can press Back to return here.
class BmiCalculatorPage extends StatefulWidget {
  final User user;
  final BmiRepository bmiRepository;
  final BmiCalculatorController? controller; // injectable for testing

  const BmiCalculatorPage({
    super.key,
    required this.user,
    required this.bmiRepository,
    this.controller,
  });

  @override
  State<BmiCalculatorPage> createState() => _BmiCalculatorPageState();
}

class _BmiCalculatorPageState extends State<BmiCalculatorPage> {
  late final BmiCalculatorController _controller;

  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        BmiCalculatorController(
          bmiRepository: widget.bmiRepository,
          user: widget.user,
        );
    _controller.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    if (widget.controller == null) _controller.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  void _handleCalculate() {
    final result = _controller.calculate(
      rawName: _nameCtrl.text,
      rawAge: _ageCtrl.text,
      rawWeightKg: _weightCtrl.text,
      rawHeightCm: _heightCtrl.text,
    );

    if (result != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BmiResultPage(
            result: result,
            user: widget.user,
            bmiRepository: widget.bmiRepository,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator BMI'),
        // backgroundColor: AppColors.primary,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── General error ────────────────────────────────────────────
              if (_controller.generalError != null) ...[
                _buildErrorBanner(_controller.generalError!),
                const SizedBox(height: 16),
              ],

              // ── Name ─────────────────────────────────────────────────────
              _buildInput(
                key: const ValueKey('name_field'),
                controller: _nameCtrl,
                label: 'Nama',
                hint: 'Masukkan nama',
                errorText: _controller.nameError,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),

              // ── Age ──────────────────────────────────────────────────────
              _buildInput(
                key: const ValueKey('age_field'),
                controller: _ageCtrl,
                label: 'Umur',
                hint: 'Masukkan umur (1–300)',
                errorText: _controller.ageError,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),

              // ── Weight ───────────────────────────────────────────────────
              _buildInput(
                key: const ValueKey('weight_field'),
                controller: _weightCtrl,
                label: 'Berat Badan (kg)',
                hint: 'Masukkan berat badan',
                errorText: _controller.weightError,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),

              // ── Height ───────────────────────────────────────────────────
              _buildInput(
                key: const ValueKey('height_field'),
                controller: _heightCtrl,
                label: 'Tinggi Badan (cm)',
                hint: 'Masukkan tinggi badan',
                errorText: _controller.heightError,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleCalculate(),
              ),
              const SizedBox(height: 28),

              // ── Calculate Button ─────────────────────────────────────────
              ElevatedButton(
                key: const ValueKey('calculate_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _handleCalculate,
                child: const Text(
                  'Hitung BMI',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required Key key,
    required TextEditingController controller,
    required String label,
    required String hint,
    String? errorText,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
