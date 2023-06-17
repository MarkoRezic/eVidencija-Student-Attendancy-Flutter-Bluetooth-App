import 'package:e_videncija/models/enums/role_enum.dart';

extension LocalNameExtension on Role {
  String get localName => name == Role.professor.name ? 'profesor' : 'student';
}
