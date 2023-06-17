import 'package:e_videncija/globals/settings.dart';
import 'package:e_videncija/models/enums/role_enum.dart';
import 'package:e_videncija/models/user_model.dart';
import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  Role _role = Role.student;
  String _firstname = 'Ime';
  String _lastname = 'Prezime';
  String _university = 'Fakultet';
  String _titles = '';

  Role get role => _role;
  String get roleName => _role.name;
  String get firstname => _firstname;
  String get lastname => _lastname;
  String get university => _university;
  String get titles => _titles;
  UserModel get user => UserModel(
        role: role,
        firstname: firstname,
        lastname: lastname,
        university: university,
        titles: titles,
      );

  void setUser(
      {Role? role,
      String? firstname,
      String? lastname,
      String? university,
      String? titles,
      bool notify = true}) {
    _role = role ?? _role;
    _firstname = firstname ?? _firstname;
    _lastname = lastname ?? _lastname;
    _university = university ?? _university;
    _titles = titles ?? _titles;
    if (notify) {
      notifyListeners();
    }
  }

  void setUserFromSettings(
      {required Map<String, dynamic> settings, bool notify = true}) {
    _role = (settings[Setting.role] != null
            ? Role.values.firstWhere(
                (roleEnum) => roleEnum.name == settings[Setting.role],
                orElse: () => Role.student)
            : null) ??
        _role;
    _firstname = settings[Setting.firstname] ?? _firstname;
    _lastname = settings[Setting.lastname] ?? _lastname;
    _university = settings[Setting.university] ?? _university;
    _titles = settings[Setting.titles] ?? _titles;
    if (notify) {
      notifyListeners();
    }
  }
}
