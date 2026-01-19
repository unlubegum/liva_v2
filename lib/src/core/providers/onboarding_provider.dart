import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences provider - must be overridden in main.dart
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in ProviderScope');
});

/// Kullanıcının ilk açılış durumu
final isFirstTimeProvider = StateNotifierProvider<IsFirstTimeNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return IsFirstTimeNotifier(prefs);
});

class IsFirstTimeNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'is_first_time';

  IsFirstTimeNotifier(this._prefs) : super(_prefs.getBool(_key) ?? true);

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_key, false);
    state = false;
  }

  // For testing - reset onboarding state
  Future<void> resetOnboarding() async {
    await _prefs.setBool(_key, true);
    state = true;
  }
}

/// Kullanıcı bilgileri
final userNameProvider = StateNotifierProvider<UserNameNotifier, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserNameNotifier(prefs);
});

class UserNameNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;
  static const _key = 'user_name';

  UserNameNotifier(this._prefs) : super(_prefs.getString(_key) ?? '');

  Future<void> setName(String name) async {
    await _prefs.setString(_key, name);
    state = name;
  }
}

/// Cinsiyet enum
enum Gender { male, female, notSelected }

final userGenderProvider = StateNotifierProvider<UserGenderNotifier, Gender>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserGenderNotifier(prefs);
});

class UserGenderNotifier extends StateNotifier<Gender> {
  final SharedPreferences _prefs;
  static const _key = 'user_gender';

  UserGenderNotifier(this._prefs) : super(_genderFromString(_prefs.getString(_key)));

  static Gender _genderFromString(String? value) {
    switch (value) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return Gender.notSelected;
    }
  }

  Future<void> setGender(Gender gender) async {
    await _prefs.setString(_key, gender.name);
    state = gender;
  }
}
