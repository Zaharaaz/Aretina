class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Aretina';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Deteksi Penyakit Mata Cerdas';

  // Database
  static const String dbName = 'eyescan.db';
  static const int dbVersion = 1;

  // DB Table Names
  static const String tableUsers = 'users';
  static const String tableDetections = 'detections';

  // SharedPrefs Keys
  static const String prefKeyUserId = 'logged_in_user_id';
  static const String prefKeyUserName = 'logged_in_user_name';
  static const String prefKeyIsLoggedIn = 'is_logged_in';

  static const List<String> diseaseLabels = ['Cataract', 'Conjunctivitis', 'Normal'];

  // Shown when the model's top confidence falls below [confidenceThreshold]
  static const String unknownLabel = 'Unknown';

  // Disease Descriptions
  static const Map<String, String> diseaseDescriptions = {
    'Normal': 'Mata Anda tampak sehat tanpa tanda-tanda penyakit yang terdeteksi.',
    'Conjunctivitis':
        'Konjungtivitis (mata merah) adalah peradangan pada konjungtiva, yang sering disebabkan oleh infeksi, alergi, atau iritasi.  Biasanya dapat diobati tetapi bisa menular.',
    'Cataract':
        'Katarak adalah pengaburan pada lensa mata yang biasanya normal. Operasi adalah pengobatan yang umum dan efektif.',
    'Unknown':
        'Model tidak dapat mengklasifikasikan gambar ini menjadi Normal, Conjunctivitis, atau Cataract dengan percaya diri. Hal ini mungkin terjadi jika foto bukanlah gambar mata yang jelas, atau menunjukkan kondisi di luar apa yang telah dilatih model.',
  };

  // Disease Colors (hex strings for reference)
  static const Map<String, String> diseaseColorHex = {
    'Normal': '#22C55E',
    'Conjunctivitis': '#F59E0B',
    'Cataract': '#EF4444',
    'Unknown': '#64748B',
  };

  // Model
  static const String modelPath = 'assets/model/eye_model.tflite';
  static const int modelInputSize = 224;

  static const double confidenceThreshold = 0.5;

  // Image
  static const int imageQuality = 85;
  static const double maxImageSizeMB = 5.0;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
}