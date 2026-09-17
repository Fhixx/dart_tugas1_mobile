import 'package:flutter/material.dart';
import '../../../data/model/catatan_bmi.dart';
import '../../../data/model/pengguna.dart';
import '../../../data/repositori/repositori_bmi.dart';
import '../pengontrol/pengontrol_riwayat_bmi.dart';
import 'halaman_detail_bmi.dart';
import 'halaman_edit_bmi.dart';
import '../../../inti/konstanta/warna_aplikasi.dart';

/// Screen displaying the list of saved BMI records for the authenticated user.
///
/// Strictly scoped to [user] or [userId] — never hardcodes `userId = 1`.
/// Supports viewing detail, editing, and deleting records with confirmation.
class BmiHistoryPage extends StatefulWidget {
  final User? user;
  final int? userId;
  final BmiRepository bmiRepository;
  final BmiHistoryController? controller;

  const BmiHistoryPage({
    super.key,
    this.user,
    this.userId,
    required this.bmiRepository,
    this.controller,
  }) : assert(
          user != null || userId != null,
          'Either authenticated user or userId must be provided.',
        );

  @override
  State<BmiHistoryPage> createState() => _BmiHistoryPageState();
}

class _BmiHistoryPageState extends State<BmiHistoryPage> {
  late final BmiHistoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        BmiHistoryController(
          bmiRepository: widget.bmiRepository,
          user: widget.user,
          userId: widget.userId,
        );

    _controller.addListener(_onControllerChanged);
    if (widget.controller == null || _controller.state == HistoryState.initial) {
      _controller.loadRecords();
    }
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
    super.dispose();
  }

  Future<void> _showDeleteConfirmation(BmiRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data BMI?'),
        content: const Text('Data yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            key: const ValueKey('cancel_delete_button'),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            key: const ValueKey('confirm_delete_button'),
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && record.id != null) {
      final success = await _controller.deleteRecord(record.id!);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data BMI berhasil dihapus.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_controller.errorMessage ?? 'Gagal menghapus data.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat BMI'),
        // backgroundColor: AppColors.primary,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            key: const ValueKey('refresh_history_button'),
            icon: const Icon(Icons.refresh),
            onPressed: _controller.loadRecords,
            tooltip: 'Segarkan',
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(key: ValueKey('history_loading_indicator')),
      );
    }

    if (_controller.isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _controller.errorMessage ?? 'Terjadi kesalahan.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                key: const ValueKey('retry_history_button'),
                onPressed: _controller.loadRecords,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller.isEmpty) {
      return RefreshIndicator(
        onRefresh: _controller.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat BMI',
                    key: ValueKey('history_empty_text'),
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _controller.records.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final record = _controller.records[index];
          return _buildHistoryCard(record);
        },
      ),
    );
  }

  Widget _buildHistoryCard(BmiRecord record) {
    return Card(
      key: ValueKey('history_item_${record.id}'),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final updated = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => BmiDetailPage(
                record: record,
                bmiRepository: widget.bmiRepository,
              ),
            ),
          );
          if (updated == true) {
            _controller.refresh();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // BMI Number Badge
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: _getCategoryColor(record.category).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getCategoryColor(record.category),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  record.bmi.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getCategoryColor(record.category),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${record.category} • ${record.weightKg} kg / ${record.heightCm} cm',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(record.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: ValueKey('edit_record_${record.id}'),
                    icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
                    tooltip: 'Edit',
                    onPressed: () async {
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BmiEditPage(
                            record: record,
                            bmiRepository: widget.bmiRepository,
                          ),
                        ),
                      );
                      if (updated == true) {
                        _controller.refresh();
                      }
                    },
                  ),
                  IconButton(
                    key: ValueKey('delete_record_${record.id}'),
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    tooltip: 'Hapus',
                    onPressed: () => _showDeleteConfirmation(record),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  String _formatDate(DateTime dt) {
    return '${dt.toLocal().year.toString().padLeft(4, '0')}-'
        '${dt.toLocal().month.toString().padLeft(2, '0')}-'
        '${dt.toLocal().day.toString().padLeft(2, '0')} '
        '${dt.toLocal().hour.toString().padLeft(2, '0')}:'
        '${dt.toLocal().minute.toString().padLeft(2, '0')}';
  }
}
