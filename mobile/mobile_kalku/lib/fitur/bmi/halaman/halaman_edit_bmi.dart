import 'package:flutter/material.dart';
import '../../../data/model/catatan_bmi.dart';
import '../../../data/repositori/repositori_bmi.dart';
import '../pengontrol/pengontrol_edit_bmi.dart';

/// Screen for editing an existing [BmiRecord].
///
/// Only Name, Age, Weight, and Height are editable.
/// BMI and Category are derived through pure domain calculation and cannot
/// be directly edited.
///
/// On successful save, pops with `true` to notify the calling list to refresh.
class BmiEditPage extends StatefulWidget {
  final BmiRecord record;
  final BmiRepository bmiRepository;
  final BmiEditController? controller;

  const BmiEditPage({
    super.key,
    required this.record,
    required this.bmiRepository,
    this.controller,
  });

  @override
  State<BmiEditPage> createState() => _BmiEditPageState();
}

class _BmiEditPageState extends State<BmiEditPage> {
  late final BmiEditController _controller;
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        BmiEditController(
          bmiRepository: widget.bmiRepository,
          originalRecord: widget.record,
        );

    _nameController = TextEditingController(text: widget.record.name);
    _ageController = TextEditingController(text: widget.record.age.toString());
    _weightController = TextEditingController(text: widget.record.weightKg.toString());
    _heightController = TextEditingController(text: widget.record.heightCm.toString());

    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await _controller.updateRecord(
      rawName: _nameController.text,
      rawAge: _ageController.text,
      rawWeightKg: _weightController.text,
      rawHeightCm: _heightController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perubahan data BMI berhasil disimpan.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Data BMI'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_controller.generalError != null) ...[
                Container(
                  key: const ValueKey('edit_general_error'),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _controller.generalError!,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                key: const ValueKey('edit_name_field'),
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  errorText: _controller.nameError,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('edit_age_field'),
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Umur (tahun)',
                  errorText: _controller.ageError,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('edit_weight_field'),
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Berat Badan (kg)',
                  errorText: _controller.weightError,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.monitor_weight),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('edit_height_field'),
                controller: _heightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Tinggi Badan (cm)',
                  errorText: _controller.heightError,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.height),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                key: const ValueKey('edit_save_button'),
                onPressed: _controller.isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _controller.isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
