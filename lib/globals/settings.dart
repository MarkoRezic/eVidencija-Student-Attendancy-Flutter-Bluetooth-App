import 'dart:convert';

import 'package:e_videncija/models/enums/role_enum.dart';
import 'package:e_videncija/utils/map_indexed_to_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SettingTypes { text, select, boolean, number }

class Setting {
  static const initialized = 'initialized';
  static const firstname = 'firstname';
  static const lastname = 'lastname';
  static const university = 'university';
  static const role = 'role';
  static const titles = 'titles';
  static const deviceID = 'deviceId';
}

class Settings {
  static Settings? _singleton;
  final SharedPreferences preferences;
  static const defaults = {
    Setting.initialized: false,
    Setting.firstname: '',
    Setting.lastname: '',
    Setting.university: '',
    Setting.role: '',
    Setting.titles: '',
    Setting.deviceID: '',
  };
  static final selectValues = {
    Setting.role: Role.values.mapToList((role) => role.name),
  };
  static const labels = {
    Setting.firstname: 'Ime',
    Setting.lastname: 'Prezime',
    Setting.university: 'Fakultet',
    Setting.role: 'Uloga',
    Setting.titles: 'Titule',
  };
  static const professorLabels = {
    Setting.firstname: 'Ime',
    Setting.lastname: 'Prezime',
    Setting.university: 'Fakultet',
    Setting.titles: 'Titule',
  };
  static const studentLabels = {
    Setting.firstname: 'Ime',
    Setting.lastname: 'Prezime',
    Setting.university: 'Fakultet',
  };
  static const types = {
    Setting.initialized: SettingTypes.boolean,
    Setting.firstname: SettingTypes.text,
    Setting.lastname: SettingTypes.text,
    Setting.university: SettingTypes.text,
    Setting.role: SettingTypes.select,
    Setting.titles: SettingTypes.text,
    Setting.deviceID: SettingTypes.text,
  };
  static const rules = {
    Setting.initialized: [],
    Setting.firstname: ['required'],
    Setting.lastname: ['required'],
    Setting.university: ['required'],
    Setting.role: ['required'],
    Setting.titles: [],
    Setting.deviceID: [],
  };

  static Future<Settings> getInstance() async {
    if (_singleton == null) {
      final prefs = await SharedPreferences.getInstance();
      _singleton = Settings._(prefs);
    }
    if (_singleton?.preferences.getString('settings') == null) {
      await _singleton?.preferences.setString('settings', jsonEncode(defaults));
    }
    return _singleton!;
  }

  Settings._(SharedPreferences prefs) : preferences = prefs;

  Future<void> reload() async {
    await preferences.reload();
  }

  Future<void> resetDefaults() async {
    await preferences.setString('settings', jsonEncode(defaults));
  }

  Future<void> updateSettings(Map<String, dynamic> updatedSettings) async {
    await preferences.setString('settings', jsonEncode(updatedSettings));
  }

  Future<void> setSetting(String key, dynamic value) async {
    var settings = preferences.getString('settings') != null
        ? jsonDecode(preferences.getString('settings')!)
        : defaults;
    settings[key] = value;
    await preferences.setString('settings', jsonEncode(settings));
  }

  dynamic getSetting(String key) {
    dynamic settings;
    settings = preferences.getString('settings') != null
        ? jsonDecode(preferences.getString('settings')!)
        : defaults;
    return settings[key];
  }

  Map<String, dynamic> toJSON() {
    return jsonDecode(preferences.getString('settings')!);
  }
}
