 // lib/models/enums.dart

enum AlertType { 
  accident, 
  weather, 
  roadClosure, 
  traffic, 
  construction,
  pothole,      // Added for report_page.dart
  roadblock,    // Added for report_page.dart
  other         // Added for report_page.dart
}

enum AlertSeverity { low, medium, high }