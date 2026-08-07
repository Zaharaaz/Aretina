
import 'package:aretina/core/constants/constants.dart';
import 'package:aretina/data/models/detection_model.dart';
import 'package:aretina/data/local/database_helper.dart';

class DetectionRepository {
  DetectionRepository._internal();
  static final DetectionRepository instance = DetectionRepository._internal();

  // ── Create ────────────────────────────────────────────────────
  Future<DetectionModel?> saveDetection(DetectionModel detection) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final id = await db.insert(
        AppConstants.tableDetections,
        detection.toMap(),
      );
      return detection.copyWith(id: id);
    } catch (e) {
      return null;
    }
  }

  // ── Read ──────────────────────────────────────────────────────
  Future<List<DetectionModel>> getDetectionsByUser(int userId,
      {int? limit, int? offset}) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      AppConstants.tableDetections,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'detected_at DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((m) => DetectionModel.fromMap(m)).toList();
  }

  Future<DetectionModel?> getDetectionById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      AppConstants.tableDetections,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DetectionModel.fromMap(maps.first);
  }

  Future<int> getDetectionCount(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableDetections} WHERE user_id = ?',
      [userId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<Map<String, int>> getDiagnosisSummary(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      '''
      SELECT diagnosis, COUNT(*) as count
      FROM ${AppConstants.tableDetections}
      WHERE user_id = ?
      GROUP BY diagnosis
      ''',
      [userId],
    );
    final map = <String, int>{};
    for (final row in result) {
      map[row['diagnosis'] as String] = (row['count'] as int?) ?? 0;
    }
    return map;
  }

  Future<List<DetectionModel>> getRecentDetections(int userId,
      {int limit = 5}) async {
    return getDetectionsByUser(userId, limit: limit);
  }

  Future<List<DetectionModel>> getDetectionsByDiagnosis(
      int userId, String diagnosis) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      AppConstants.tableDetections,
      where: 'user_id = ? AND diagnosis = ?',
      whereArgs: [userId, diagnosis],
      orderBy: 'detected_at DESC',
    );
    return maps.map((m) => DetectionModel.fromMap(m)).toList();
  }

  // ── Update ────────────────────────────────────────────────────
  Future<bool> updateNotes(int detectionId, String notes) async {
    final db = await DatabaseHelper.instance.database;
    final count = await db.update(
      AppConstants.tableDetections,
      {'notes': notes},
      where: 'id = ?',
      whereArgs: [detectionId],
    );
    return count > 0;
  }

  // ── Delete ────────────────────────────────────────────────────
  Future<bool> deleteDetection(int detectionId) async {
    final db = await DatabaseHelper.instance.database;
    final count = await db.delete(
      AppConstants.tableDetections,
      where: 'id = ?',
      whereArgs: [detectionId],
    );
    return count > 0;
  }

  Future<int> deleteAllUserDetections(int userId) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      AppConstants.tableDetections,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
