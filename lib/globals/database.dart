import 'dart:math';

import 'package:e_videncija/models/attendance_model.dart';
import 'package:e_videncija/models/student_attendance_model.dart';
import 'package:e_videncija/utils/map_indexed_to_list.dart';
import 'package:e_videncija/utils/remove_null_from_list.dart';
import 'package:flutter/cupertino.dart';
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
  Future<int> insertSubject(SubjectModel subject) async {
    // Insert the Subject into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same doc is inserted twice.
    //
    // In this case, replace any previous data.
    return await database.insert(
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
  Future<int> insertAttendance(AttendanceModel attendance) async {
    return await database.insert(
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
  Future<int> insertStudent(StudentModel student) async {
    return await database.insert(
      studentTable,
      student.toMapInsert(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StudentModel>> getStudents({AttendanceModel? attendance}) async {
    String? attendanceQuery = attendance == null
        ? null
        : '''
        SELECT students.id, students.firstname, students.lastname, students.university, students.deviceID
        FROM students
        JOIN student_attendances ON student_attendances.studentID = students.id
        JOIN attendances ON student_attendances.attendanceID = attendances.id
        WHERE attendances.id = ${attendance.id}
      ''';

    final List<Map<String, dynamic>> maps = attendanceQuery == null
        ? await database.query(
            studentTable,
          )
        : await database.rawQuery(attendanceQuery);

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

  Future<StudentModel?> getStudentByDeviceID({required String deviceID}) async {
    final List<Map<String, dynamic>> maps = await database
        .query(studentTable, where: 'deviceID = ?', whereArgs: [deviceID]);

    final studentList = List.generate(maps.length, (i) {
      return StudentModel(
        id: maps[i]['id'],
        firstname: maps[i]['firstname'],
        lastname: maps[i]['lastname'],
        university: maps[i]['university'],
        deviceID: maps[i]['deviceID'],
      );
    });

    return studentList.isEmpty ? null : studentList.first;
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
  Future<int> insertStudentAttendance(
      StudentAttendanceModel studentAttendance) async {
    return await database.insert(
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
              attendance != null ? 'attendanceID = ?' : null,
              student != null ? 'studentID = ?' : null
            ].removeNull().join(' AND '),
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
              attendance != null ? 'attendanceID = ?' : null,
              student != null ? 'studentID = ?' : null
            ].removeNull().join(' AND '),
      whereArgs: [attendance?.id, student?.id].removeNull(),
    );
  }

  Future<List<Map<String, Object?>>> getAttendanceCount(
      {required StudentModel student}) async {
    String? attendanceCountQuery = '''
        SELECT s.id, s.name, COUNT(st.id) count
        FROM subjects s
        LEFT JOIN attendances a ON a.subjectID = s.id
        LEFT JOIN student_attendances sa ON sa.attendanceID = a.id
        LEFT JOIN students st ON sa.studentID = st.id
        WHERE st.id = ${student.id}
        GROUP BY s.id, st.id 
      ''';

    String? attendanceTotalQuery = '''
        SELECT s.id, s.name, COUNT(a.id) total
        FROM subjects s
        LEFT JOIN attendances a ON a.subjectID = s.id
        GROUP BY s.id
      ''';

    final List<Map<String, dynamic>> mapsCount =
        await database.rawQuery(attendanceCountQuery);
    final List<Map<String, dynamic>> mapsTotal =
        await database.rawQuery(attendanceTotalQuery);

    debugPrint(mapsCount.toString());
    debugPrint(mapsTotal.toString());

    return List.generate(mapsTotal.length, (i) {
      Map<String, dynamic>? mapCount;
      for (var map in mapsCount) {
        if (map["id"] == mapsTotal[i]["id"]) {
          mapCount = map;
          break;
        }
      }
      int studentCount = mapCount?["count"] ?? 0;
      int totalCount = mapsTotal[i]["total"];
      debugPrint(studentCount.toString());
      debugPrint(totalCount.toString());

      return {
        "name": mapsTotal[i]["name"],
        "count": mapCount?["count"] ?? 0,
        "total": mapsTotal[i]["total"],
        "percentage": (studentCount == 0 || totalCount == 0
                ? 0
                : (100 * (studentCount / totalCount)))
            .round(),
      };
    });
  }

  Future<String> exportSubjects(
      {SubjectModel? subject, AttendanceModel? attendance}) async {
    String? allSubjectsAttendancesQuery = '''
        SELECT s.id subjectId, s.name subjectName, a.id attendanceId, a.name attendanceName
        FROM subjects s
        LEFT JOIN attendances a ON a.subjectID = s.id
        ${subject != null ? 'WHERE s.id = ${subject.id}' : ''}
        ${attendance != null ? '${subject == null ? 'WHERE' : 'AND'} a.id = ${attendance.id}' : ''}
        ORDER BY s.id, a.id ASC
      ''';

    String? studentAttendanceQuery = '''
        SELECT s.id subjectId, s.name subjectName, a.id attendanceId, a.name attendanceName, st.id studentId, st.firstname, st.lastname, st.university, sa.id stid
        FROM subjects s
        JOIN attendances a ON a.subjectID = s.id
        JOIN student_attendances sa ON sa.attendanceID = a.id
        JOIN students st ON sa.studentID = st.id
        ${subject != null ? 'WHERE s.id = ${subject.id}' : ''}
        ${attendance != null ? '${subject == null ? 'WHERE' : 'AND'} a.id = ${attendance.id}' : ''}
        ORDER BY s.id, a.id, st.id ASC
      ''';
    final List<Map<String, dynamic>> mapsSubjectsAttendances =
        await database.rawQuery(allSubjectsAttendancesQuery);
    final List<Map<String, dynamic>> mapsStudentAttendances =
        await database.rawQuery(studentAttendanceQuery);

    debugPrint("Subjects and attendances:");
    for (var map in mapsSubjectsAttendances) {
      debugPrint(map.toString());
    }

    debugPrint("Student attendances:");
    for (var map in mapsStudentAttendances) {
      debugPrint(map.toString());
    }

    List<Map<String, dynamic>> subjects = [];

    //this will determine the number of rows for each subject
    Map<String, int> studentsMaxCount = {};

    for (var subjectRow in mapsSubjectsAttendances) {
      int subjectIndex = subjects.indexWhere(
          (subject) => subject["subjectId"] == subjectRow["subjectId"]);
      //Add the new subject to subjects
      if (subjectIndex == -1) {
        subjects.add({
          "subjectId": subjectRow["subjectId"],
          "subjectName": subjectRow["subjectName"],
          "attendances": [],
        });
        subjectIndex = subjects.length - 1;
        studentsMaxCount[subjectRow["subjectId"].toString()] = 0;
      }
      //Add the attendance to the subject
      if (subjectRow["attendanceId"] != null) {
        subjects[subjectIndex]["attendances"].add({
          "attendanceId": subjectRow["attendanceId"],
          "attendanceName": subjectRow["attendanceName"],
          "students": mapsStudentAttendances
              .where((studentAttendanceRow) =>
                  studentAttendanceRow["attendanceId"] ==
                  subjectRow["attendanceId"])
              .mapToList((studentAttendanceRow) => {
                    "studentId": studentAttendanceRow["studentId"],
                    "firstname": studentAttendanceRow["firstname"],
                    "lastname": studentAttendanceRow["lastname"],
                    "university": studentAttendanceRow["university"],
                  }),
        });

        studentsMaxCount[subjectRow["subjectId"].toString()] = max(
            subjects[subjectIndex]["attendances"].last["students"].length,
            studentsMaxCount[subjectRow["subjectId"].toString()]!);
      }
    }
    debugPrint(subjects.toString());

    debugPrint("ROWS:");
    debugPrint(studentsMaxCount.toString());

    String content = '';

    for (var subject in subjects) {
      content += "Predmet:;${subject["subjectName"]};\n";
      for (int i = -1;
          i < studentsMaxCount[subject["subjectId"].toString()]!;
          i++) {
        for (int j = 0; j < subject["attendances"].length; j++) {
          //first row is header for attendanceNames
          if (i == -1) {
            content += subject["attendances"][j]["attendanceName"];
            content += ';';
          }
          //insert the i-th student of the j-th attendance (if not exists then empty string)
          else {
            List<Map<String, dynamic>> studentList =
                subject["attendances"][j]["students"];
            if (studentList.length > i) {
              content +=
                  '${studentList[i]["firstname"]} ${studentList[i]["lastname"]} (${studentList[i]["university"]})';
            }
            content += ';';
          }
        }
        content += "\n";
      }
      content += "\n";
    }

    debugPrint(content);
    return content;
  }
}
