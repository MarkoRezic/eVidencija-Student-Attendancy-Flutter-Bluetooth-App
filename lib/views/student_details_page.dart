import 'package:e_videncija/globals/database.dart';
import 'package:e_videncija/globals/main_theme.dart';
import 'package:e_videncija/models/student_model.dart';
import 'package:e_videncija/utils/map_indexed_to_list.dart';
import 'package:flutter/material.dart';

class StudentDetailsPage extends StatelessWidget {
  const StudentDetailsPage({super.key, required this.student});

  final StudentModel student;

  Future<List<Map<String, Object?>>> get _attendanceCount =>
      Future.value(_getAttendanceCount());

  Future<List<Map<String, Object?>>> _getAttendanceCount() async {
    final database = await EvidencijaDatabase.getInstance();
    return database.getAttendanceCount(student: student);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Nazad'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.fromBorderSide(
                      BorderSide(width: 2, color: Colors.white),
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    foregroundImage: AssetImage(
                      'assets/images/student_icon_white.png',
                    ),
                    radius: 30,
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${student.firstname} ${student.lastname}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 50),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(EvidencijaTheme.defaultBorderRadius),
                border: Border.fromBorderSide(
                  BorderSide(
                    color: EvidencijaTheme.primaryColorAlt,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 32,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Detalji o studentu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ime:',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        student.firstname,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Prezime:',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        student.lastname,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fakultet:',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        student.university,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(EvidencijaTheme.defaultBorderRadius),
                border: Border.fromBorderSide(
                  BorderSide(
                    color: EvidencijaTheme.primaryColorAlt,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list_alt,
                        size: 32,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Evidencije',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  FutureBuilder<List<Map<String, Object?>>>(
                    future: _attendanceCount,
                    builder: (context, snapshot) => Column(
                      children: snapshot.hasData
                          ? (snapshot.data!.isEmpty
                              ? [Text('Nema evidencija')]
                              : snapshot.data!.mapToList(
                                  (attendanceJSON) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${attendanceJSON["name"]}:',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Text(
                                          '${attendanceJSON["count"]}/${attendanceJSON["total"]}  (${attendanceJSON["percentage"].toString().padLeft(3, ' ')}%)',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                          : [
                              CircularProgressIndicator(),
                            ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
