import 'package:e_videncija/globals/database.dart';
import 'package:e_videncija/globals/main_theme.dart';
import 'package:e_videncija/models/attendance_model.dart';
import 'package:e_videncija/utils/map_indexed_to_list.dart';
import 'package:flutter/material.dart';

import '../models/subject_model.dart';

class ProfessorAttendanceList extends StatefulWidget {
  const ProfessorAttendanceList({super.key});

  @override
  State<ProfessorAttendanceList> createState() =>
      _ProfessorAttendanceListState();
}

class _ProfessorAttendanceListState extends State<ProfessorAttendanceList> {
  late final EvidencijaDatabase _database;
  List<SubjectModel> _subjects = [];
  List<List<AttendanceModel>> _attendances = [];

  bool _loadingSubjects = true;
  List<bool> _subjectExpanded = [];
  List<bool> _loadingAttendances = [];

  @override
  void initState() {
    super.initState();

    EvidencijaDatabase.getInstance().then((database) {
      _database = database;
      _getSubjects();
    });
  }

  Future<void> _getSubjects() async {
    setState(() {
      _loadingSubjects = true;
    });

    List<SubjectModel> subjects = await _database.getSubjects();

    setState(() {
      _subjects = subjects;
      _attendances = List.generate(_subjects.length, (index) => []);
      _loadingAttendances = List.generate(_subjects.length, (index) => false);
      _subjectExpanded = List.generate(_subjects.length, (index) => false);
      _loadingSubjects = false;
    });
  }

  Future<void> _getAttendances(int subjectIndex) async {
    SubjectModel subject = _subjects[subjectIndex];
    setState(() {
      _loadingAttendances[subjectIndex] = true;
    });

    List<AttendanceModel> attendances =
        await _database.getAttendances(subject: subject);

    setState(() {
      _attendances[subjectIndex] = attendances;
      _loadingAttendances[subjectIndex] = false;
    });
  }

  Future<void> _openCreateSubjectModal() async {
    TextEditingController controller = TextEditingController();
    String? subjectName = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, stateSetter) => SimpleDialog(
          title: Text('Novi predmet'),
          contentPadding: EdgeInsets.all(20),
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: 'Naziv predmeta'),
              onChanged: (value) {
                stateSetter(() {});
              },
              onEditingComplete: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            EvidencijaTheme.errorColor)),
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    },
                    child: Text('Prekid'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: controller.text.isEmpty
                        ? null
                        : () {
                            Navigator.of(context).pop(controller.text);
                          },
                    child: Text('Spremi'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );

    if (subjectName != null) {
      await _database.insertSubject(SubjectModel(
        id: -1,
        name: subjectName,
      ));
      _getSubjects();
    }
  }

  Future<void> _openUpdateSubjectModal(
      SubjectModel subject, int subjectIndex) async {
    TextEditingController controller =
        TextEditingController(text: subject.name);
    String? subjectName = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, stateSetter) => SimpleDialog(
          title: Text('Uredi predmet'),
          contentPadding: EdgeInsets.all(20),
          children: [
            TextField(
              autofocus: true,
              controller: controller,
              decoration: InputDecoration(labelText: 'Naziv predmeta'),
              onChanged: (value) {
                stateSetter(() {});
              },
              onEditingComplete: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            EvidencijaTheme.errorColor)),
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    },
                    child: Text('Prekid'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: controller.text.isEmpty
                        ? null
                        : () {
                            Navigator.of(context).pop(controller.text);
                          },
                    child: Text('Spremi'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );

    if (subjectName != null) {
      await _database.updateSubject(SubjectModel(
        id: subject.id,
        name: subjectName,
      ));
      _getSubjects();
    }
  }

  Future<void> _openCreateAttendanceModal(
      SubjectModel subject, int subjectIndex) async {
    DateTime now = DateTime.now();
    TextEditingController controller = TextEditingController(
        text:
            'Evidencija - ${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}.');
    String? attendanceName = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, stateSetter) => SimpleDialog(
          title: Text('Nova evidencija'),
          contentPadding: EdgeInsets.all(20),
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: 'Naziv evidencije'),
              onChanged: (value) {
                stateSetter(() {});
              },
              onEditingComplete: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            EvidencijaTheme.errorColor)),
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    },
                    child: Text('Prekid'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: controller.text.isEmpty
                        ? null
                        : () {
                            Navigator.of(context).pop(controller.text);
                          },
                    child: Text('Spremi'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );

    if (attendanceName != null) {
      await _database.insertAttendance(AttendanceModel(
        id: -1,
        name: attendanceName,
        createdAt: now.toIso8601String(),
        subjectID: subject.id,
      ));
      _getAttendances(subjectIndex);
    }
  }

  Future<void> _openUpdateAttendanceModal(AttendanceModel attendance,
      SubjectModel subject, int subjectIndex) async {
    DateTime now = DateTime.now();
    TextEditingController controller =
        TextEditingController(text: attendance.name);
    String? attendanceName = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, stateSetter) => SimpleDialog(
          title: Text('Uredi evidenciju'),
          contentPadding: EdgeInsets.all(20),
          children: [
            TextField(
              autofocus: true,
              controller: controller,
              decoration: InputDecoration(labelText: 'Naziv evidencije'),
              onChanged: (value) {
                stateSetter(() {});
              },
              onEditingComplete: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            EvidencijaTheme.errorColor)),
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    },
                    child: Text('Prekid'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: controller.text.isEmpty
                        ? null
                        : () {
                            Navigator.of(context).pop(controller.text);
                          },
                    child: Text('Spremi'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );

    if (attendanceName != null) {
      await _database.updateAttendance(AttendanceModel(
        id: attendance.id,
        name: attendanceName,
        createdAt: attendance.createdAt,
        subjectID: subject.id,
      ));
      _getAttendances(subjectIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Nazad'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.list_alt,
                  size: 100,
                  color: Colors.white,
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'Evidencija',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Ovdje možete pregledati vaše predmete i njihove evidencije.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _openCreateSubjectModal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          size: 24,
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text('Dodaj predmet'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.upload,
                          size: 24,
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text('Export sve predmete'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            ...(_loadingSubjects
                ? [
                    SizedBox.square(
                      dimension: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                      ),
                    ),
                  ]
                : _subjects.isEmpty
                    ? [Text('Nema predmeta')]
                    : _subjects.mapIndexedToList(
                        (subject, subjectIndex) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ExpansionTile(
                              maintainState: true,
                              subtitle: _subjectExpanded[subjectIndex]
                                  ? Text(
                                      '${_attendances[subjectIndex].length} evidencija')
                                  : null,
                              title: Text(subject.name),
                              controlAffinity: ListTileControlAffinity.leading,
                              trailing: IconButton(
                                onPressed: () => _openUpdateSubjectModal(
                                    subject, subjectIndex),
                                icon: Icon(Icons.edit),
                              ),
                              onExpansionChanged: (expanded) {
                                setState(() {
                                  _subjectExpanded[subjectIndex] = expanded;
                                });
                                if (expanded) {
                                  _getAttendances(subjectIndex);
                                }
                              },
                              children: [
                                ...(_loadingAttendances[subjectIndex]
                                    ? [CircularProgressIndicator()]
                                    : _attendances[subjectIndex].isEmpty
                                        ? [
                                            Text('Nema evidencija'),
                                            SizedBox(height: 20),
                                          ]
                                        : [
                                            ..._attendances[subjectIndex]
                                                .mapToList(
                                              (attendance) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10),
                                                child: Material(
                                                  color: EvidencijaTheme
                                                      .primaryColorAlt,
                                                  borderRadius: BorderRadius
                                                      .circular(EvidencijaTheme
                                                          .defaultBorderRadius),
                                                  clipBehavior: Clip.hardEdge,
                                                  child: ListTile(
                                                    title:
                                                        Text(attendance.name),
                                                    trailing: IconButton(
                                                      onPressed: () =>
                                                          _openUpdateAttendanceModal(
                                                              attendance,
                                                              subject,
                                                              subjectIndex),
                                                      icon: Icon(Icons.edit),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 0,
                                                        color: EvidencijaTheme
                                                            .primaryColorAlt,
                                                      ),
                                                      borderRadius: BorderRadius
                                                          .circular(EvidencijaTheme
                                                              .defaultBorderRadius),
                                                    ),
                                                    hoverColor: Colors.white,
                                                    splashColor: Colors.white
                                                        .withOpacity(0.5),
                                                    onTap: () {},
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                          ]),
                                SizedBox(
                                  height: 35,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () =>
                                              _openCreateAttendanceModal(
                                                  subject, subjectIndex),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add,
                                                size: 24,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                'Dodaj',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () => () {},
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.upload,
                                                size: 24,
                                              ),
                                              SizedBox(width: 5),
                                              Expanded(
                                                child: FittedBox(
                                                  fit: BoxFit.fitWidth,
                                                  child: Text('Export sve'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                        ),
                      )),
          ],
        ),
      ),
    );
  }
}
