import 'package:e_videncija/models/attendance_model.dart';
import 'package:e_videncija/models/student_attendance_model.dart';
import 'package:e_videncija/utils/remove_null_from_list.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';

import '../models/student_model.dart';
import '../models/subject_model.dart';

class EvidencijaDatabase {
  static EvidencijaDatabase? _singleton;
  final Database database;

  static const String subjectTable = 'subjects';
  static const String attendanceTable = 'attendances';
  static const String studentTable = 'students';
  static const String studentAttendanceTable = 'student_attendances';

  static Future<EvidencijaDatabase> getInstance() async {
    if (_singleton == null) {
      final database = await openDatabase(
        // Set the path to the database. Note: Using the `join` function from the
        // `path` package is best practice to ensure the path is correctly
        // constructed for each platform.
        Path.join(await getDatabasesPath(), 'evidencija_database.db'),
        // When the database is first created, create tables.
        onCreate: (db, version) async {
          // Run the CREATE TABLE statement on the database.
          await db.execute(
            'CREATE TABLE $subjectTable(id INTEGER PRIMARY KEY, name TEXT)',
          );
          await db.execute(
            'CREATE TABLE $attendanceTable(id INTEGER PRIMARY KEY, name TEXT, createdAt TEXT, subjectID INTEGER)',
          );
          await db.execute(
            'CREATE TABLE $studentTable(id INTEGER PRIMARY KEY, firstname TEXT, lastname TEXT, university TEXT, deviceID TEXT)',
          );
          await db.execute(
            'CREATE TABLE $studentAttendanceTable(id INTEGER PRIMARY KEY, attendanceID INTEGER, studentID INTEGER)',
          );
        },
        onUpgrade: (db, versionPrev, version) async {
          // Delete and recreate tables.
          await db.execute('DROP TABLE $subjectTable');
          await db.execute('DROP TABLE $attendanceTable');
          await db.execute('DROP TABLE $studentTable');
          await db.execute('DROP TABLE $studentAttendanceTable');

          await db.execute(
            'CREATE TABLE $subjectTable(id INTEGER PRIMARY KEY, name TEXT)',
          );
          await db.execute(
            'CREATE TABLE $attendanceTable(id INTEGER PRIMARY KEY, name TEXT, createdAt TEXT, subjectID INTEGER)',
          );
          await db.execute(
            'CREATE TABLE $studentTable(id INTEGER PRIMARY KEY, firstname TEXT, lastname TEXT, university TEXT, deviceID TEXT)',
          );
          await db.execute(
            'CREATE TABLE $studentAttendanceTable(id INTEGER PRIMARY KEY, attendanceID INTEGER, studentID INTEGER)',
          );
        },
        // Set the version. This executes the onCreate function and provides a
        // path to perform database upgrades and downgrades.
        version: 1,
      );
      _singleton = EvidencijaDatabase._(database);
    }
    return _singleton!;
  }

  EvidencijaDatabase._(Database db) : database = db;

  /// SUBJECTS TABLE
  Future<void> insertSubject(SubjectModel subject) async {
    // Insert the Subject into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same doc is inserted twice.
    //
    // In this case, replace any previous data.
    await database.insert(
      subjectTable,
      subject.toMapInsert(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all subjects.
  Future<List<SubjectModel>> getSubjects() async {
    // Query the table for all Subjects.
    final List<Map<String, dynamic>> maps = await database.query(subjectTable);

    // Convert the List<Map<String, dynamic> into a List<Subject>.
    return List.generate(maps.length, (i) {
      return SubjectModel(
        id: maps[i]['id'],
        name: maps[i]['name'],
      );
    });
  }

  Future<void> updateSubject(SubjectModel subject) async {
    // Update the given Subject.
    await database.update(
      subjectTable,
      subject.toMap(),
      // Ensure that the Subject has a matching id.
      where: 'id = ?',
      // Pass the Subjects's id as a whereArg to prevent SQL injection.
      whereArgs: [subject.id],
    );
  }

  Future<void> deleteSubjectById(int id) async {
    // First remove all attendances connected to this subject
    await deleteAttendances(subject: SubjectModel(id: id, name: ''));
    // Remove the Subject from the database.
    await database.delete(
      subjectTable,
      // Use a `where` clause to delete a specific document.
      where: 'id = ?',
      // Pass the Subject's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<void> deleteSubjectsByID(List<int> ids) async {
    // Remove the Subjects from the database.
    var batch = database.batch();
    for (var id in ids) {
      // First remove all attendances connected to this subject
      await deleteAttendances(subject: SubjectModel(id: id, name: ''));

      batch.delete(subjectTable, where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true, continueOnError: true);
  }

  /// ATTENDANCES TABLE
  Future<void> insertAttendance(AttendanceModel attendance) async {
    await database.insert(
      attendanceTable,
      attendance.toMapInsert(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AttendanceModel>> getAttendances({SubjectModel? subject}) async {
    final List<Map<String, dynamic>> maps = await database.query(
      attendanceTable,
      where: subject != null ? 'subjectID = ?' : null,
      whereArgs: subject != null ? [subject.id] : null,
    );

    return List.generate(maps.length, (i) {
      return AttendanceModel(
        id: maps[i]['id'],
        name: maps[i]['name'],
        createdAt: maps[i]['createdAt'],
        subjectID: maps[i]['subjectID'],
      );
    });
  }

  Future<void> updateAttendance(AttendanceModel attendance) async {
    await database.update(
      attendanceTable,
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<void> deleteAttendanceByID(int id) async {
    await deleteStudentAttendances(
        attendance:
            AttendanceModel(id: id, name: '', createdAt: '', subjectID: -1));

    await database.delete(
      attendanceTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAttendancesById(List<int> ids) async {
    var batch = database.batch();
    for (var id in ids) {
      batch.delete(studentAttendanceTable,
          where: 'attendanceID = ?', whereArgs: [id]);

      batch.delete(attendanceTable, where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true, continueOnError: true);
  }

  Future<void> deleteAttendances({SubjectModel? subject}) async {
    var batch = database.batch();
    for (var attendance in (await getAttendances(subject: subject))) {
      batch.delete(studentAttendanceTable,
          where: 'attendanceID = ?', whereArgs: [attendance.id]);
    }
    await batch.commit(noResult: true, continueOnError: true);

    await database.delete(
      attendanceTable,
      where: subject == null ? null : 'subjectID = ?',
      whereArgs: [subject?.id],
    );
  }

  /// STUDENTS TABLE
  Future<void> insertStudent(StudentModel student) async {
    await database.insert(
      studentTable,
      student.toMapInsert(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StudentModel>> getStudents() async {
    final List<Map<String, dynamic>> maps = await database.query(
      studentTable,
    );

    return List.generate(maps.length, (i) {
      return StudentModel(
        id: maps[i]['id'],
        firstname: maps[i]['firstname'],
        lastname: maps[i]['lastname'],
        university: maps[i]['university'],
        deviceID: maps[i]['deviceID'],
      );
    });
  }

  Future<bool> checkStudentDeviceIDExists(String deviceID) async {
    return (await database.query(
      studentTable,
      where: 'deviceID = ?',
      whereArgs: [deviceID],
    ))
        .isNotEmpty;
  }

  Future<void> updateStudent(StudentModel student) async {
    await database.update(
      studentTable,
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<void> deleteStudentById(int id) async {
    await deleteStudentAttendances(
        student: StudentModel(
            id: id, firstname: '', lastname: '', university: '', deviceID: ''));

    await database.delete(
      studentTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteStudentsById(List<int> ids) async {
    var batch = database.batch();
    for (var id in ids) {
      batch.delete(studentAttendanceTable,
          where: 'studentID = ?', whereArgs: [id]);

      batch.delete(studentTable, where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true, continueOnError: true);
  }

  /// STUDENT ATTENDANCES TABLE
  Future<void> insertStudentAttendance(
      StudentAttendanceModel studentAttendance) async {
    await database.insert(
      studentAttendanceTable,
      studentAttendance.toMapInsert(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StudentAttendanceModel>> getStudentAttendances(
      {AttendanceModel? attendance, StudentModel? student}) async {
    final List<Map<String, dynamic>> maps = await database.query(
      studentAttendanceTable,
      where: (attendance == null && student == null)
          ? null
          : [
              attendance != null ? 'attendanceID = ?' : '',
              student != null ? 'studentID = ?' : ''
            ].join(' AND '),
      whereArgs: [attendance?.id, student?.id].removeNull(),
    );

    return List.generate(maps.length, (i) {
      return StudentAttendanceModel(
        id: maps[i]['id'],
        attendanceID: maps[i]['attendanceID'],
        studentID: maps[i]['studentID'],
      );
    });
  }

  Future<void> updateStudentAttendance(
      StudentAttendanceModel studentAttendance) async {
    await database.update(
      studentAttendanceTable,
      studentAttendance.toMap(),
      where: 'id = ?',
      whereArgs: [studentAttendance.id],
    );
  }

  Future<void> deleteStudentAttendanceById(int id) async {
    await database.delete(
      studentAttendanceTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteStudentAttendancesById(List<int> ids) async {
    var batch = database.batch();
    for (var id in ids) {
      batch.delete(studentAttendanceTable, where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true, continueOnError: true);
  }

  Future<void> deleteStudentAttendances(
      {AttendanceModel? attendance, StudentModel? student}) async {
    await database.delete(
      studentAttendanceTable,
      where: (attendance == null && student == null)
          ? null
          : [
              attendance != null ? 'attendanceID = ?' : '',
              student != null ? 'studentID = ?' : ''
            ].join(' AND '),
      whereArgs: [attendance?.id, student?.id].removeNull(),
    );
  }
}
