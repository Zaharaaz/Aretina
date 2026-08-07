
class DetectionModel {
  final int? id;
  final int userId;
  final String imagePath;
  final String diagnosis;          
  final double confidence;         
  final List<double> allScores;    
  final DateTime detectedAt;
  final String? notes;

  const DetectionModel({
    this.id,
    required this.userId,
    required this.imagePath,
    required this.diagnosis,
    required this.confidence,
    required this.allScores,
    required this.detectedAt,
    this.notes,
  });

  // Convenience getters
  bool get isNormal => diagnosis.toLowerCase() == 'normal';
  bool get isConjunctivitis => diagnosis.toLowerCase() == 'conjunctivitis';
  bool get isCataract => diagnosis.toLowerCase() == 'cataract';
  bool get isUnknown => diagnosis.toLowerCase() == 'unknown';

  // labels.txt: cataract=0, conjunctivitis=1, normal=2
  double get cataractScore => allScores.isNotEmpty ? allScores[0] : 0;
  double get conjunctivitisScore => allScores.length > 1 ? allScores[1] : 0;
  double get normalScore => allScores.length > 2 ? allScores[2] : 0;
  double get unknownScore => allScores.isNotEmpty ? allScores.reduce((a, b) => a > b ? a : b) : 0;

  DetectionModel copyWith({
    int? id,
    int? userId,
    String? imagePath,
    String? diagnosis,
    double? confidence,
    List<double>? allScores,
    DateTime? detectedAt,
    String? notes,
  }) {
    return DetectionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imagePath: imagePath ?? this.imagePath,
      diagnosis: diagnosis ?? this.diagnosis,
      confidence: confidence ?? this.confidence,
      allScores: allScores ?? this.allScores,
      detectedAt: detectedAt ?? this.detectedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'image_path': imagePath,
      'diagnosis': diagnosis,
      'confidence': confidence,
      'all_scores': allScores.join(','),
      'detected_at': detectedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory DetectionModel.fromMap(Map<String, dynamic> map) {
    final scoresStr = map['all_scores'] as String? ?? '';
    final scores = scoresStr.isEmpty
        ? <double>[]
        : scoresStr.split(',').map((s) => double.tryParse(s) ?? 0.0).toList();

    return DetectionModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      imagePath: map['image_path'] as String,
      diagnosis: map['diagnosis'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      allScores: scores,
      detectedAt: DateTime.parse(map['detected_at'] as String),
      notes: map['notes'] as String?,
    );
  }

  @override
  String toString() {
    return 'DetectionModel(id: $id, diagnosis: $diagnosis, confidence: $confidence)';
  }
}