import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_provider.dart';

/// Modül yapılandırma modeli
@immutable
class ModuleConfig {
  final bool family;
  final bool home;
  final bool car;
  final bool pets;
  final bool travel;
  final bool podcast;
  final bool budget;
  final bool fitness;
  // Female-specific modules
  final bool cycleTracking;
  final bool pregnancy;
  final bool fashion;


  const ModuleConfig({
    this.family = true,
    this.home = true,
    this.car = false,
    this.pets = true,
    this.travel = true,
    this.podcast = true,
    this.budget = true,
    this.fitness = true,
    this.cycleTracking = false,
    this.pregnancy = false,
    this.fashion = false,

  });

  /// Kadın için varsayılan modüller
  factory ModuleConfig.femaleDefaults() {
    return const ModuleConfig(
      family: true,
      home: true,
      car: false,
      pets: true,
      travel: true,
      podcast: true,
      budget: true,
      fitness: true,
      cycleTracking: true,
      pregnancy: true,
      fashion: true,
    );
  }

  /// Erkek için varsayılan modüller
  factory ModuleConfig.maleDefaults() {
    return const ModuleConfig(
      family: true,
      home: false,
      car: true,
      pets: true,
      travel: true,
      podcast: true,
      budget: true,
      fitness: true,
      cycleTracking: false,
      pregnancy: false,
      fashion: false,

    );
  }

  ModuleConfig copyWith({
    bool? family,
    bool? home,
    bool? car,
    bool? pets,
    bool? travel,
    bool? podcast,
    bool? budget,
    bool? fitness,
    bool? cycleTracking,
    bool? pregnancy,
    bool? fashion,

  }) {
    return ModuleConfig(
      family: family ?? this.family,
      home: home ?? this.home,
      car: car ?? this.car,
      pets: pets ?? this.pets,
      travel: travel ?? this.travel,
      podcast: podcast ?? this.podcast,
      budget: budget ?? this.budget,
      fitness: fitness ?? this.fitness,
      cycleTracking: cycleTracking ?? this.cycleTracking,
      pregnancy: pregnancy ?? this.pregnancy,
      fashion: fashion ?? this.fashion,
    );
  }

  /// JSON'a dönüştür (persistence için)
  Map<String, bool> toJson() => {
    'family': family,
    'home': home,
    'car': car,
    'pets': pets,
    'travel': travel,
    'podcast': podcast,
    'budget': budget,
    'fitness': fitness,
    'cycleTracking': cycleTracking,
    'pregnancy': pregnancy,
    'fashion': fashion,
  };

  /// JSON'dan oluştur
  factory ModuleConfig.fromJson(Map<String, dynamic> json) {
    return ModuleConfig(
      family: json['family'] ?? true,
      home: json['home'] ?? true,
      car: json['car'] ?? false,
      pets: json['pets'] ?? true,
      travel: json['travel'] ?? true,
      podcast: json['podcast'] ?? true,
      budget: json['budget'] ?? true,
      fitness: json['fitness'] ?? true,
      cycleTracking: json['cycleTracking'] ?? false,
      pregnancy: json['pregnancy'] ?? false,
      fashion: json['fashion'] ?? false,
    );
  }

  /// Aktif modül listesi
  List<ModuleInfo> get enabledModules {
    final modules = <ModuleInfo>[];
    if (family) modules.add(ModuleInfo.family);
    if (home) modules.add(ModuleInfo.home);
    if (car) modules.add(ModuleInfo.car);
    if (pets) modules.add(ModuleInfo.pets);
    if (travel) modules.add(ModuleInfo.travel);
    if (podcast) modules.add(ModuleInfo.podcast);
    if (budget) modules.add(ModuleInfo.budget);
    if (fitness) modules.add(ModuleInfo.fitness);
    if (cycleTracking) modules.add(ModuleInfo.cycleTracking);
    if (pregnancy) modules.add(ModuleInfo.pregnancy);
    if (fashion) modules.add(ModuleInfo.fashion);

    return modules;
  }
}

/// Modül bilgileri
enum ModuleInfo {
  family('Aile', 'family_restroom', '/family', 0xFFE8B5CF),
  home('Evim & Faturalar', 'home', '/home-module', 0xFFB5D8E8),
  car('Araba', 'directions_car', '/car', 0xFF9E9E9E),
  pets('Evcil Hayvan', 'pets', '/pets', 0xFFFFCC80),
  travel('Seyahat', 'flight', '/travel', 0xFF80DEEA),
  podcast('Podcast', 'podcasts', '/podcast', 0xFFCE93D8),
  budget('Bütçe', 'account_balance_wallet', '/budget', 0xFFA5D6A7),
  fitness('Fitness', 'fitness_center', '/fitness', 0xFFEF9A9A),
  cycleTracking('Döngü Takibi', 'favorite', '/cycle', 0xFFF48FB1),
  pregnancy('Hamilelik', 'child_friendly', '/pregnancy', 0xFFFFAB91),
  fashion('Moda', 'checkroom', '/fashion', 0xFFB39DDB);

  const ModuleInfo(this.label, this.iconName, this.route, this.colorValue);
  
  final String label;
  final String iconName;
  final String route;
  final int colorValue;
}

/// Modül yapılandırma provider
final moduleConfigProvider = StateNotifierProvider<ModuleConfigNotifier, ModuleConfig>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ModuleConfigNotifier(prefs);
});

class ModuleConfigNotifier extends StateNotifier<ModuleConfig> {
  final SharedPreferences _prefs;
  static const _prefix = 'module_';

  ModuleConfigNotifier(this._prefs) : super(_loadFromPrefs(_prefs));

  static ModuleConfig _loadFromPrefs(SharedPreferences prefs) {
    // Check if any module key exists
    if (prefs.containsKey('${_prefix}family')) {
      return ModuleConfig(
        family: prefs.getBool('${_prefix}family') ?? true,
        home: prefs.getBool('${_prefix}home') ?? true,
        car: prefs.getBool('${_prefix}car') ?? false,
        pets: prefs.getBool('${_prefix}pets') ?? true,
        travel: prefs.getBool('${_prefix}travel') ?? true,
        podcast: prefs.getBool('${_prefix}podcast') ?? true,
        budget: prefs.getBool('${_prefix}budget') ?? true,
        fitness: prefs.getBool('${_prefix}fitness') ?? true,
        cycleTracking: prefs.getBool('${_prefix}cycleTracking') ?? false,
        pregnancy: prefs.getBool('${_prefix}pregnancy') ?? false,
        fashion: prefs.getBool('${_prefix}fashion') ?? false,
      );
    }
    return const ModuleConfig();
  }

  Future<void> _saveToPrefs() async {
    await _prefs.setBool('${_prefix}family', state.family);
    await _prefs.setBool('${_prefix}home', state.home);
    await _prefs.setBool('${_prefix}car', state.car);
    await _prefs.setBool('${_prefix}pets', state.pets);
    await _prefs.setBool('${_prefix}travel', state.travel);
    await _prefs.setBool('${_prefix}podcast', state.podcast);
    await _prefs.setBool('${_prefix}budget', state.budget);
    await _prefs.setBool('${_prefix}fitness', state.fitness);
    await _prefs.setBool('${_prefix}cycleTracking', state.cycleTracking);
    await _prefs.setBool('${_prefix}pregnancy', state.pregnancy);
    await _prefs.setBool('${_prefix}fashion', state.fashion);

  }

  /// Cinsiyete göre varsayılanları uygula
  Future<void> applyGenderDefaults(Gender gender) async {
    state = gender == Gender.female
        ? ModuleConfig.femaleDefaults()
        : ModuleConfig.maleDefaults();
    await _saveToPrefs();
  }

  /// Tek modül toggle
  Future<void> toggleModule(String moduleName, bool value) async {
    switch (moduleName) {
      case 'family':
        state = state.copyWith(family: value);
        break;
      case 'home':
        state = state.copyWith(home: value);
        break;
      case 'car':
        state = state.copyWith(car: value);
        break;
      case 'pets':
        state = state.copyWith(pets: value);
        break;
      case 'travel':
        state = state.copyWith(travel: value);
        break;
      case 'podcast':
        state = state.copyWith(podcast: value);
        break;
      case 'budget':
        state = state.copyWith(budget: value);
        break;
      case 'fitness':
        state = state.copyWith(fitness: value);
        break;
      case 'cycleTracking':
        state = state.copyWith(cycleTracking: value);
        break;
      case 'pregnancy':
        state = state.copyWith(pregnancy: value);
        break;
      case 'fashion':
        state = state.copyWith(fashion: value);
        break;

    }
    await _saveToPrefs();
  }

  /// Direkt config set
  Future<void> setConfig(ModuleConfig config) async {
    state = config;
    await _saveToPrefs();
  }
}
