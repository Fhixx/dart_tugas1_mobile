import 'package:flutter/foundation.dart';
import '../../../data/models/bmi_record.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/bmi_repository.dart';

/// States for the BMI History screen.
enum HistoryState {
  /// Initial state before any records are requested.
  initial,

  /// Records are currently being fetched from SQLite.
  loading,

  /// Records loaded successfully and list is non-empty.
  success,

  /// Records loaded successfully but list is empty.
  empty,

  /// An error occurred during database fetch.
  error,
}

/// Controller managing the BMI History list, loading, refreshing, and deletion.
///
/// All queries and operations are strictly scoped to the authenticated [userId]
/// (or [user.id]) to enforce user isolation.
/// No SQL code, no Navigator, no Widget imports belong here.
class BmiHistoryController extends ChangeNotifier {
  final BmiRepository _bmiRepository;
  final int _userId;

  BmiHistoryController({
    required BmiRepository bmiRepository,
    User? user,
    int? userId,
  })  : _bmiRepository = bmiRepository,
        _userId = userId ?? user?.id ?? (throw ArgumentError('A valid user or userId must be provided.')),
        assert(
          (userId ?? user?.id) != null,
          'Authenticated userId cannot be null.',
        );

  int get userId => _userId;

  HistoryState _state = HistoryState.initial;
  HistoryState get state => _state;

  List<BmiRecord> _records = [];
  List<BmiRecord> get records => List.unmodifiable(_records);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => state == HistoryState.loading;
  bool get isEmpty => state == HistoryState.empty;
  bool get isSuccess => state == HistoryState.success;
  bool get isError => state == HistoryState.error;

  /// Loads all BMI records for the authenticated user.
  ///
  /// Transitions: initial -> loading -> success / empty / error.
  Future<void> loadRecords() async {
    _state = HistoryState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _bmiRepository.getAllByUser(_userId);
      _records = fetched;
      if (_records.isEmpty) {
        _state = HistoryState.empty;
      } else {
        _state = HistoryState.success;
      }
    } catch (e) {
      _state = HistoryState.error;
      _errorMessage = 'Gagal memuat riwayat BMI. Silakan coba lagi.';
    }

    notifyListeners();
  }

  /// Refreshes the history list (e.g. after edit, delete, or save).
  Future<void> refresh() async {
    await loadRecords();
  }

  /// Deletes a single BMI record by [recordId] owned by the authenticated user.
  ///
  /// Scoped by [_userId] to prevent deleting records belonging to other users.
  /// Returns `true` if deletion was successful, `false` otherwise.
  Future<bool> deleteRecord(int recordId) async {
    try {
      final affected = await _bmiRepository.deleteById(
        id: recordId,
        userId: _userId,
      );
      if (affected > 0) {
        // Remove locally or refresh
        _records.removeWhere((r) => r.id == recordId);
        if (_records.isEmpty) {
          _state = HistoryState.empty;
        } else {
          _state = HistoryState.success;
        }
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Data BMI tidak ditemukan atau bukan milik Anda.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Gagal menghapus data BMI. Silakan coba lagi.';
      notifyListeners();
      return false;
    }
  }
}
