import 'package:flutter/material.dart';
import '../../../data/models/bmi_record.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/bmi_repository.dart';
import 'bmi_edit_page.dart';

/// Screen displaying the complete details of a single [BmiRecord].
///
/// Can be opened by passing an existing [record], or by providing [recordId]
/// with authenticated [userId] (or [user]) and [bmiRepository] to query SQLite.
/// All queries are strictly scoped by `id AND user_id` to guarantee user isolation.
class BmiDetailPage extends StatefulWidget {
  final BmiRecord? record;
  final int? recordId;
  final int? userId;
  final User? user;
  final BmiRepository? bmiRepository;

  const BmiDetailPage({
    super.key,
    this.record,
    this.recordId,
    this.userId,
    this.user,
    this.bmiRepository,
  }) : assert(
          record != null || (recordId != null && (userId != null || user != null) && bmiRepository != null),
          'Either a non-null record or recordId with userId and bmiRepository must be provided.',
        );

  @override
  State<BmiDetailPage> createState() => _BmiDetailPageState();
}

class _BmiDetailPageState extends State<BmiDetailPage> {
  BmiRecord? _currentRecord;
  bool _isLoading = false;
  String? _errorMessage;

  int get _effectiveUserId =>
      widget.userId ?? widget.user?.id ?? widget.record?.userId ?? -1;

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _currentRecord = widget.record;
    } else {
      _loadFromRepository();
    }
  }

  Future<void> _loadFromRepository() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetched = await widget.bmiRepository!.getById(
        id: widget.recordId!,
        userId: _effectiveUserId,
      );
      if (fetched == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Data tidak ditemukan atau bukan milik Anda.';
        });
      } else {
        setState(() {
          _isLoading = false;
          _currentRecord = fetched;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat detail BMI.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail BMI'),
        actions: [
          if (_currentRecord != null && widget.bmiRepository != null)
            IconButton(
              key: const ValueKey('detail_edit_button'),
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Data',
              onPressed: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BmiEditPage(
                      record: _currentRecord!,
                      bmiRepository: widget.bmiRepository!,
                    ),
                  ),
                );
                if (!context.mounted) return;
                if (updated == true) {
                  if (widget.recordId != null && widget.bmiRepository != null) {
                    _loadFromRepository();
                  } else {
                    Navigator.pop(context, true);
                  }
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(key: ValueKey('detail_loading_indicator')),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    final record = _currentRecord;
    if (record == null) {
      return const Center(child: Text('Data tidak tersedia'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    record.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(record.category).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getCategoryColor(record.category),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      record.category,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _getCategoryColor(record.category),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    record.bmi.toStringAsFixed(2),
                    key: const ValueKey('detail_bmi_value'),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(record.category),
                    ),
                  ),
                  const Text(
                    'Indeks Massa Tubuh (BMI)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  _buildDetailRow(
                    label: 'Umur',
                    value: '${record.age} tahun',
                    key: const ValueKey('detail_age'),
                  ),
                  const Divider(height: 1),
                  _buildDetailRow(
                    label: 'Berat Badan',
                    value: '${record.weightKg} kg',
                    key: const ValueKey('detail_weight'),
                  ),
                  const Divider(height: 1),
                  _buildDetailRow(
                    label: 'Tinggi Badan',
                    value: '${record.heightCm} cm',
                    key: const ValueKey('detail_height'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  _buildDetailRow(
                    label: 'Waktu Dibuat',
                    value: _formatTimestamp(record.createdAt),
                    key: const ValueKey('detail_created_at'),
                  ),
                  const Divider(height: 1),
                  _buildDetailRow(
                    label: 'Terakhir Diperbarui',
                    value: _formatTimestamp(record.updatedAt),
                    key: const ValueKey('detail_updated_at'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Key? key,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            key: key,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'kurus':
        return Colors.blue;
      case 'normal':
        return Colors.green;
      case 'gemuk':
        return Colors.orange;
      case 'obesitas':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.toLocal().year.toString().padLeft(4, '0')}-'
        '${dt.toLocal().month.toString().padLeft(2, '0')}-'
        '${dt.toLocal().day.toString().padLeft(2, '0')} '
        '${dt.toLocal().hour.toString().padLeft(2, '0')}:'
        '${dt.toLocal().minute.toString().padLeft(2, '0')} WIB';
  }
}
