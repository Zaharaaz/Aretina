import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aretina/core/constants/constants.dart';
import 'package:aretina/core/utils/utils.dart';
import 'package:aretina/data/models/user_model.dart';
import 'package:aretina/data/repositories/user_repository.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthController extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  final UserRepository _userRepo = UserRepository.instance;

  // ── Init ──────────────────────────────────────────────────────
  Future<void> checkAuthStatus() async {
    _setState(AuthState.loading);
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AppConstants.prefKeyIsLoggedIn) ?? false;
      final userId = prefs.getInt(AppConstants.prefKeyUserId);

      if (isLoggedIn && userId != null) {
        final user = await _userRepo.getUserById(userId);
        if (user != null) {
          _currentUser = user;
          _setState(AuthState.authenticated);
          return;
        }
      }
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setState(AuthState.unauthenticated);
    }
  }

  // ── Register ──────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    try {
      final emailLower = email.toLowerCase().trim();

      // Check if email already exists
      final exists = await _userRepo.emailExists(emailLower);
      if (exists) {
        _errorMessage = 'An account with this email already exists.';
        _setState(AuthState.unauthenticated);
        return false;
      }

      final user = UserModel(
        name: name.trim(),
        email: emailLower,
        passwordHash: AppUtils.hashPassword(password),
        createdAt: DateTime.now(),
      );

      final created = await _userRepo.createUser(user);
      if (created == null) {
        _errorMessage = 'Registration failed. Please try again.';
        _setState(AuthState.unauthenticated);
        return false;
      }

      // Auto-login after register
      _currentUser = created;
      await _persistSession(created);
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _setState(AuthState.unauthenticated);
      return false;
    }
  }

  // ── Login ─────────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    try {
      final user = await _userRepo.getUserByEmailAndPassword(
        email.toLowerCase().trim(),
        AppUtils.hashPassword(password),
      );

      if (user == null) {
        _errorMessage = 'Invalid email or password.';
        _setState(AuthState.unauthenticated);
        return false;
      }

      _currentUser = user;
      await _persistSession(user);
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      _setState(AuthState.unauthenticated);
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefKeyIsLoggedIn);
    await prefs.remove(AppConstants.prefKeyUserId);
    await prefs.remove(AppConstants.prefKeyUserName);
    _currentUser = null;
    _errorMessage = null;
    _setState(AuthState.unauthenticated);
  }

  // ── Profile Update ────────────────────────────────────────────
  Future<bool> updateProfile({String? name, String? avatarPath}) async {
    if (_currentUser == null) return false;
    try {
      final updated = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        avatarPath: avatarPath ?? _currentUser!.avatarPath,
      );
      final success = await _userRepo.updateUser(updated);
      if (success) {
        _currentUser = updated;
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) return false;
    try {
      final currentHash = AppUtils.hashPassword(currentPassword);
      if (currentHash != _currentUser!.passwordHash) {
        _errorMessage = 'Current password is incorrect.';
        notifyListeners();
        return false;
      }
      final newHash = AppUtils.hashPassword(newPassword);
      final success =
          await _userRepo.updatePassword(_currentUser!.id!, newHash);
      if (success) {
        _currentUser = _currentUser!.copyWith(passwordHash: newHash);
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────
  Future<void> _persistSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefKeyIsLoggedIn, true);
    await prefs.setInt(AppConstants.prefKeyUserId, user.id!);
    await prefs.setString(AppConstants.prefKeyUserName, user.name);
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
