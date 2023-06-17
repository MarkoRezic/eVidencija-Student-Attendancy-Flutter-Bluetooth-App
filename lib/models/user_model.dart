import 'dart:core';

import 'enums/role_enum.dart';

class UserModel {
  UserModel({
    required this.role,
    required this.firstname,
    required this.lastname,
    required this.university,
    required this.titles,
  });

  final Role role;
  final String firstname;
  final String lastname;
  final String university;
  final String titles;

  factory UserModel.fromJSON(Map<String, Object?> json) {
    return UserModel(
      role: Role.values
          .firstWhere((roleEnum) => roleEnum.name == (json["role"] as String)),
      firstname: json["firstname"] as String,
      lastname: json["lastname"] as String,
      university: json["university"] as String,
      titles: json["titles"] as String,
    );
  }

  Map<String, Object?> toJSON() {
    return {
      "role": role.name,
      "firstname": firstname,
      "lastname": lastname,
      "university": university,
      "titles": titles,
    };
  }
}
