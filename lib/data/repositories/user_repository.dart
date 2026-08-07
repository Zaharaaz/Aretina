// lib/data/repositories/user_repository.dart

import 'package:sqflite/sqflite.dart';
import 'package:aretina/core/constants/constants.dart';
import 'package:aretina/data/models/user_model.dart';
import 'package:aretina/data/local/database_helper.dart';

class UserRepository {
  UserRepository._internal();
  static final UserRepository instance = UserRepository._internal();

  Future<Database> get _db async => await DatabaseHelper.instance.database;

  // ── Create ────────────────────────────────────────────────────
  Future<UserModel?> createUser(UserModel user) async {
    try {
      final db = await _db;
      final id = await db.insert(
        AppConstants.tableUsers,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      return user.copyWith(id: id);
    } catch (e) {
      return null; // email already exists or other error
    }
  }

  // ── Read ──────────────────────────────────────────────────────
  Future<UserModel?> getUserById(int id) async {
    final db = await _db;
    final maps = await db.query(
      AppConstants.tableUsers,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await _db;
    final maps = await db.query(
      AppConstants.tableUsers,
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getUserByEmailAndPassword(
      String email, String passwordHash) async {
    final db = await _db;
    final maps = await db.query(
      AppConstants.tableUsers,
      where: 'email = ? AND password_hash = ?',
      whereArgs: [email.toLowerCase().trim(), passwordHash],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  // ── Update ────────────────────────────────────────────────────
  Future<bool> updateUser(UserModel user) async {
    if (user.id == null) return false;
    final db = await _db;
    final count = await db.update(
      AppConstants.tableUsers,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    return count > 0;
  }

  Future<bool> updateAvatar(int userId, String? avatarPath) async {
    final db = await _db;
    final count = await db.update(
      AppConstants.tableUsers,
      {'avatar_path': avatarPath},
      where: 'id = ?',
      whereArgs: [userId],
    );
    return count > 0;
  }

  Future<bool> updatePassword(int userId, String newPasswordHash) async {
    final db = await _db;
    final count = await db.update(
      AppConstants.tableUsers,
      {'password_hash': newPasswordHash},
      where: 'id = ?',
      whereArgs: [userId],
    );
    return count > 0;
  }

  // ── Delete ────────────────────────────────────────────────────
  Future<bool> deleteUser(int userId) async {
    final db = await _db;
    final count = await db.delete(
      AppConstants.tableUsers,
      where: 'id = ?',
      whereArgs: [userId],
    );
    return count > 0;
  }
}
