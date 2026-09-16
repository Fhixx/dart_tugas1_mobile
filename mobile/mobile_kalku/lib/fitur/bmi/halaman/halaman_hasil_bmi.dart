import 'package:flutter/material.dart';
import '../../../inti/domain/hasil_perhitungan_bmi.dart';
import '../../../inti/domain/kategori_bmi.dart';
import '../../../data/model/pengguna.dart';
import '../../../data/repositori/repositori_bmi.dart';
import '../pengontrol/pengontrol_perhitungan_bmi.dart';

/// BMI Result screen.
///
/// Displays all calculated fields and allows the user to save the record
/// to the database exactly once (duplicate-save prevention via [SaveState]).
///
/// Receives a typed [BmiCalculationResult] from [BmiCalculatorPage].
/// Does NOT recalculate from the displayed formatted string.
///
/// Navigation: Back via Navigator.pop() to return to the calculator.
class BmiResultPage extends StatefulWidget {
  final BmiCalculationResult result;
  final User user;
  final BmiRepository bmiRepository;
  final BmiCalculatorController? controller; // injectable for testing

  const BmiResultPage({
    super.key,
    required this.result,
    required this.user,
    required this.bmiRepository,
    this.controller,
  });

  @override
  State<BmiResultPage> createState() => _BmiResultPageState();
}

class _BmiResultPageState extends State<BmiResultPage> {
  late final BmiCalculatorController _controller;

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
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _handleSave() async {
    await _controller.saveResult(widget.result);
    if (mounted && _controller.isSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hasil BMI berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Color _categoryColor(BmiCategory category) {
    switch (category) {
      case BmiCategory.underweight:
        return Colors.blue;
      case BmiCategory.normal:
        return Colors.green;
      case BmiCategory.overweight:
        return Colors.orange;
      case BmiCategory.obesity:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final catColor = _categoryColor(result.category);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil BMI'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── BMI Value Card ────────────────────────────────────────────
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        result.bmiDisplay,
                        key: const ValueKey('bmi_value'),
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: catColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: catColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          result.category.label,
                          key: const ValueKey('bmi_category'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: catColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Details Card ──────────────────────────────────────────────
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      _buildRow('Nama', result.name,
                          key: const ValueKey('result_name')),
                      const Divider(),
                      _buildRow('Umur', '${result.age} tahun',
                          key: const ValueKey('result_age')),
                      const Divider(),
                      _buildRow('Berat',
                          '${result.weightKg.toStringAsFixed(1)} kg',
                          key: const ValueKey('result_weight')),
                      const Divider(),
                      _buildRow('Tinggi',
                          '${result.heightCm.toStringAsFixed(1)} cm',
                          key: const ValueKey('result_height')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Error Banner ─────────────────────────────────────────────
              if (_controller.generalError != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _controller.generalError!,
                    style:
                        const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Save Button ───────────────────────────────────────────────
              ElevatedButton(
                key: const ValueKey('save_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _controller.isSaved ? Colors.grey : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _controller.canSave ? _handleSave : null,
                child: _controller.isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _controller.isSaved ? 'Tersimpan' : 'Simpan Hasil',
                        key: const ValueKey('save_button_label'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 12),

              // ── Back Button ───────────────────────────────────────────────
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Hitung Ulang',
                  style: TextStyle(color: Colors.blue, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: Colors.black54)),
          Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
