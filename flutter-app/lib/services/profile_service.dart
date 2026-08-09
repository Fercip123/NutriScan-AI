import 'package:shared_preferences/shared_preferences.dart';

/// Profil pengguna LOKAL (tanpa akun/login/token). Hanya menyimpan
/// preferensi/tujuan harian di HP masing-masing, menggantikan
/// endpoint backend `profile/index.php`.
class ProfileService {
  static Future<Map<String, dynamic>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('profile_name') ?? 'Pengguna',
      'daily_calorie_goal': prefs.getInt('daily_calorie_goal') ?? 1500,
      'daily_water_goal': prefs.getInt('daily_water_goal') ?? 8,
      'daily_activity_goal': prefs.getInt('daily_activity_goal') ?? 30,
    };
  }

  static Future<void> saveProfile({
    String? name,
    int? calorieGoal,
    int? waterGoal,
    int? activityGoal,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString('profile_name', name);
    if (calorieGoal != null) await prefs.setInt('daily_calorie_goal', calorieGoal);
    if (waterGoal != null) await prefs.setInt('daily_water_goal', waterGoal);
    if (activityGoal != null) await prefs.setInt('daily_activity_goal', activityGoal);
  }
}
