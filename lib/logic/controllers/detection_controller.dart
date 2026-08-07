import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:aretina/core/constants/constants.dart';
import 'package:aretina/data/models/detection_model.dart';
import 'package:aretina/data/repositories/detection_repository.dart';

enum DetectionState { idle, analyzing, success, error }

class DetectionController extends ChangeNotifier {
  DetectionState _state = DetectionState.idle;
  DetectionModel? _lastResult;
  String? _errorMessage;
  final List<DetectionModel> _history = [];
  bool _historyLoaded = false;

  DetectionState get state => _state;
  DetectionModel? get lastResult => _lastResult;
  String? get errorMessage => _errorMessage;
  List<DetectionModel> get history => List.unmodifiable(_history);
  bool get isAnalyzing => _state == DetectionState.analyzing;

  final DetectionRepository _repo = DetectionRepository.instance;

  Future<DetectionModel?> analyzeImage({
    required String imagePath,
    required int userId,
  }) async {
    _setState(DetectionState.analyzing);
    _errorMessage = null;

    try {
      final imageFile = File(imagePath);
      final exists = await imageFile.exists();
      if (!exists) {
        _errorMessage = 'Image file not found.';
        _setState(DetectionState.error);
        return null;
      }

      final rawBytes = await imageFile.readAsBytes();

      final inputTensor = await _preprocessImage(rawBytes);

      final scores = await _runRealInference(inputTensor);

      final maxScore = scores.reduce((a, b) => a > b ? a : b);
      final maxIndex = scores.indexOf(maxScore);
      final diagnosis = maxScore >= AppConstants.confidenceThreshold
          ? AppConstants.diseaseLabels[maxIndex]
          : AppConstants.unknownLabel;

      final detection = DetectionModel(
        userId: userId,
        imagePath: imagePath,
        diagnosis: diagnosis,
        confidence: maxScore,
        allScores: scores,
        detectedAt: DateTime.now(),
      );

      final saved = await _repo.saveDetection(detection);
      final result = saved ?? detection;

      _lastResult = result;
      if (saved != null) _history.insert(0, saved);

      _setState(DetectionState.success);
      return result;

    } catch (e, stack) {
      _errorMessage = 'Analysis failed: $e';
      _setState(DetectionState.error);
      return null;
    }
  }

  Future<void> loadHistory(int userId) async {
    if (_historyLoaded) return;
    try {
      final results = await _repo.getDetectionsByUser(userId);
      _history..clear()..addAll(results);
      _historyLoaded = true;
      notifyListeners();
    } catch (e) {
    }
  }

  Future<void> refreshHistory(int userId) async {
    _historyLoaded = false;
    await loadHistory(userId);
  }

  Future<bool> deleteDetection(int detectionId) async {
    final success = await _repo.deleteDetection(detectionId);
    if (success) {
      _history.removeWhere((d) => d.id == detectionId);
      notifyListeners();
    }
    return success;
  }

  Future<Map<String, int>> getSummary(int userId) async {
    return _repo.getDiagnosisSummary(userId);
  }

  Future<List<List<List<List<double>>>>> _preprocessImage(
      Uint8List rawBytes) async {
    return compute(_preprocessImageIsolate, rawBytes);
  }

  Future<List<double>> _runRealInference(
      List<List<List<List<double>>>> inputTensor) async {
    final interpreter = await Interpreter.fromAsset(AppConstants.modelPath);

    try {
      var output = List.filled(3, 0.0).reshape([1, 3]);
      interpreter.run(inputTensor, output);

      final scores = List<double>.from(output[0]);
      return scores;
    } finally {
      interpreter.close();
    }
  }

  void reset() {
    _state = DetectionState.idle;
    _lastResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _setState(DetectionState s) {
    _state = s;
    notifyListeners();
  }
}

List<List<List<List<double>>>> _preprocessImageIsolate(Uint8List rawBytes) {
  final decoded = img.decodeImage(rawBytes);
  if (decoded == null) throw Exception('Failed to decode image');

  final resized = img.copyResize(
    decoded,
    width: AppConstants.modelInputSize,
    height: AppConstants.modelInputSize,
    interpolation: img.Interpolation.linear,
  );

  return List.generate(
    1,
    (_) => List.generate(
      AppConstants.modelInputSize,
      (y) => List.generate(
        AppConstants.modelInputSize,
        (x) {
          final pixel = resized.getPixel(x, y);
          return [
            pixel.r.toDouble(),
            pixel.g.toDouble(),
            pixel.b.toDouble(),
          ];
        },
      ),
    ),
  );
}