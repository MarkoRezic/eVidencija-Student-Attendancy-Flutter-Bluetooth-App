import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:e_videncija/globals/database.dart';
import 'package:e_videncija/globals/main_theme.dart';
import 'package:e_videncija/models/attendance_model.dart';
import 'package:e_videncija/models/student_attendance_model.dart';
import 'package:e_videncija/models/student_model.dart';
import 'package:e_videncija/utils/map_indexed_to_list.dart';
import 'package:e_videncija/utils/show_toast.dart';
import 'package:e_videncija/views/student_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../globals/settings.dart';
import '../models/subject_model.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class ProfessorAttendanceScan extends StatefulWidget {
  const ProfessorAttendanceScan({
    super.key,
    required this.subject,
    required this.attendance,
  });

  final SubjectModel subject;
  final AttendanceModel attendance;

  @override
  State<ProfessorAttendanceScan> createState() =>
      _ProfessorAttendanceScanState();
}

class _ProfessorAttendanceScanState extends State<ProfessorAttendanceScan> {
  late final EvidencijaDatabase _database;
  List<StudentModel> _attendedStudents = [];

  bool _loadingStudents = false;
  bool _loadingAttendedStudents = true;

  List<Device> _devices = [];
  Set<String> _connectedDeviceIDNames = Set();
  Set<String> _connectedDeviceIDs = Set();
  late NearbyService nearbyService;
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;
  late UserModel user;
  bool isPhysicalDevice = false;
  bool initialized = false;
  bool promptOpen = false;

  @override
  void initState() {
    super.initState();

    EvidencijaDatabase.getInstance().then((database) {
      _database = database;
      _getAttendedStudents();
    });
  }

  @override
  void dispose() {
    if (isPhysicalDevice) {
      subscription.cancel();
      receivedDataSubscription.cancel();
      nearbyService.stopBrowsingForPeers();
      nearbyService.stopAdvertisingPeer();
    }
    super.dispose();
  }

  Future<void> initScan() async {
    debugPrint("INIT");
    nearbyService = NearbyService();
    String devInfo = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      debugPrint(
          "Device UUID: ${(await Settings.getInstance()).getSetting(Setting.deviceID)}");
      devInfo = androidInfo.model;
      if (!androidInfo.isPhysicalDevice) {
        debugPrint("Running in emulator, NearbyService will NOT be started.");
        setState(() {
          isPhysicalDevice = false;
        });
        return;
      }
    }
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      devInfo = iosInfo.localizedModel;
      if (!iosInfo.isPhysicalDevice) {
        debugPrint("Running in emulator, NearbyService will NOT be started.");
        setState(() {
          isPhysicalDevice = false;
        });
        return;
      }
    }
    setState(() {
      isPhysicalDevice = true;
    });
    await nearbyService.init(
        serviceType: 'mpconn',
        deviceName: devInfo,
        strategy: Strategy.P2P_CLUSTER,
        callback: (isRunning) async {
          if (isRunning) {
            await nearbyService.stopBrowsingForPeers();
            await Future.delayed(Duration(microseconds: 200));
            await nearbyService.startBrowsingForPeers();
          }
        });

    subscription =
        nearbyService.stateChangedSubscription(callback: (devicesList) async {
      for (var device in devicesList) {
        print(
            " deviceId: ${device.deviceId} | deviceName: ${device.deviceName} | state: ${device.state}");

        if (Platform.isAndroid) {
          if (device.state == SessionState.connected) {
            nearbyService.stopBrowsingForPeers();
          } else {
            nearbyService.startBrowsingForPeers();
          }
        }
      }

      setState(() {
        //update devices list to show only devices that are not connected and that previously weren't connected
        _devices.clear();
        _devices.addAll(devicesList.where((device) =>
            device.state != SessionState.connected &&
            !_connectedDeviceIDNames
                .contains('${device.deviceId}${device.deviceName}')));
        _connectedDeviceIDNames.addAll(devicesList
            .where((device) => device.state == SessionState.connected)
            .map((device) => '${device.deviceId}${device.deviceName}'));
        _connectedDeviceIDs.addAll(devicesList
            .where((device) => device.state == SessionState.connected)
            .map((device) => device.deviceId));
      });
    });

    receivedDataSubscription =
        nearbyService.dataReceivedSubscription(callback: (data) async {
      Map<String, dynamic> jsonData = jsonDecode(data["message"]);
      debugPrint("dataReceivedSubscription: $data");

      //receive student data, if valid deviceID prompt approval
      if (jsonData[Setting.deviceID] != null) {
        await _openApproveStudentModal(
            student: StudentModel(
          id: -1,
          firstname: jsonData[Setting.firstname],
          lastname: jsonData[Setting.lastname],
          university: jsonData[Setting.university],
          deviceID: jsonData[Setting.deviceID],
        ));
      }
    });
  }

  _startScan() async {
    setState(() {
      _loadingStudents = true;
    });
    if (!initialized) {
      setState(() {
        initialized = true;
      });
      await initScan();
    } else {
      if (isPhysicalDevice) {
        await nearbyService.stopBrowsingForPeers();
        await Future.delayed(Duration(microseconds: 200));
        await nearbyService.startBrowsingForPeers();
      }
    }
  }

  _stopScan() async {
    setState(() {
      _loadingStudents = false;
      _devices = [];
      _connectedDeviceIDNames = Set();
      _connectedDeviceIDs = Set();
    });
    if (isPhysicalDevice) {
      for (var deviceID in _connectedDeviceIDs) {
        nearbyService.disconnectPeer(deviceID: deviceID);
      }
      await nearbyService.stopBrowsingForPeers();
    }
  }

  _requestConnect(Device device) async {
    if (device.state == SessionState.notConnected) {
      debugPrint("REQUESTING CONNECTION: $device");
      await nearbyService.invitePeer(
          deviceID: device.deviceId, deviceName: device.deviceName);
    }
  }

  Future<void> _openApproveStudentModal({required StudentModel student}) async {
    if (promptOpen) {
      return;
    }
    //prevent re-entering the prompt when the same device sent multiple message responses
    //this can happen if the device repeatedly exits and enters the scan mode
    setState(() {
      promptOpen = true;
    });
    //if student already has an attendance, skip this entirely and show toast informing the user
    if (_attendedStudents.any(
        (attendedStudent) => attendedStudent.deviceID == student.deviceID)) {
      debugPrint("DEVICEID ALREADY EXISTS: ${student.deviceID}");
      showToast(
          'Student ${student.firstname} ${student.lastname} je već evidentiran.',
          context: context);
      return;
    }

    bool? approve = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, stateSetter) => SimpleDialog(
          title: Text('Evidentiraj studenta'),
          contentPadding: EdgeInsets.all(20),
          children: [
            Text('Student: ${student.firstname} ${student.lastname}'),
            SizedBox(height: 10),
            Text('Fakultet: ${student.university}'),
            SizedBox(height: 10),
            Text('ID Uređaja: ${student.deviceID}'),
            SizedBox(height: 10),
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
                    child:
                        FittedBox(fit: BoxFit.fitWidth, child: Text('Prekid')),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: FittedBox(
                        fit: BoxFit.fitWidth, child: Text('Evidentiraj')),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );

    if (approve == true) {
      StudentModel? existingStudent =
          await _database.getStudentByDeviceID(deviceID: student.deviceID);
      late StudentModel createdStudent;
      if (existingStudent == null) {
        //new student deviceID, insert student into database
        debugPrint("CREATED STUDENT");
        createdStudent = StudentModel.copyFrom(student);
        createdStudent.id = await _database.insertStudent(student);
      }
      //insert student attendance
      await _database.insertStudentAttendance(StudentAttendanceModel(
          id: -1,
          attendanceID: widget.attendance.id,
          studentID: existingStudent?.id ?? createdStudent.id));

      setState(() {
        promptOpen = false;
      });
      _getAttendedStudents();
    }
  }

  Future<void> _getAttendedStudents() async {
    setState(() {
      _loadingAttendedStudents = true;
    });

    List<StudentModel> attendedStudents =
        await _database.getStudents(attendance: widget.attendance);

    setState(() {
      _attendedStudents = attendedStudents;
      _loadingAttendedStudents = false;
    });
  }

  Future<void> _deleteAttendance({required StudentModel student}) async {
    setState(() {
      _loadingAttendedStudents = true;
    });

    await _database.deleteStudentAttendances(
        attendance: widget.attendance, student: student);

    //reset cached connected devices to allow the deleted user to be added again
    setState(() {
      _connectedDeviceIDNames = Set();
      _connectedDeviceIDs = Set();
    });
    _getAttendedStudents();
  }

  Future<void> _navigateToStudentDetails(
      {required StudentModel student}) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentDetailsPage(student: student),
      ),
    );
  }

  _exportAttendance() async {
    try {
      final settings = await Settings.getInstance();
      final user = context.read<UserProvider>().user;
      final now = DateTime.now();
      final database = await EvidencijaDatabase.getInstance();
      final content = await database.exportSubjects(
          subject: widget.subject, attendance: widget.attendance);
      final response = await http.post(
          Uri.parse(
              '${settings.getSetting(Setting.serverHost)}/${settings.getSetting(Setting.exportRoute)}'),
          body: {
            "fileName":
                "${user.titles} ${user.firstname} ${user.lastname} - ${widget.attendance.name} ${widget.subject.name} ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
            "content": content,
          });
      debugPrint(response.body);
      if (mounted) {
        showToast('Export uspješan', context: context);
      }
    } catch (_) {
      debugPrint(_.toString());
      showToast(
        'Došlo je do greške. Molimo provjerite postavke.',
        context: context,
        backgroundColor: EvidencijaTheme.errorColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    user = context.watch<UserProvider>().user;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Nazad'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              widget.subject.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            SizedBox(height: 20),
            Text(
              widget.attendance.name,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: !_loadingStudents
                          ? null
                          : ButtonStyle(
                              foregroundColor: MaterialStatePropertyAll(
                                  EvidencijaTheme.errorColor),
                              side: MaterialStatePropertyAll(
                                BorderSide(
                                  color: EvidencijaTheme.errorColor,
                                  width: 2,
                                ),
                              ),
                            ),
                      onPressed: !_loadingStudents ? _startScan : _stopScan,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            !_loadingStudents ? Icons.add : Icons.close,
                            size: 24,
                          ),
                          SizedBox(width: 5),
                          ...(!_loadingStudents
                              ? [
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text('Traži studente'),
                                    ),
                                  ),
                                ]
                              : [
                                  Text(
                                    'Prekid',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator()),
                                ]),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _exportAttendance,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload,
                            size: 24,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Export',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              flex: 2,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ..._devices.mapToList(
                    (device) => Row(
                      children: [
                        Text('${device.deviceName}   ID: ${device.deviceId}'),
                        IconButton(
                          onPressed: () => _requestConnect(device),
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          iconSize: 32,
                        ),
                      ],
                    ),
                  ),
                  _loadingStudents
                      ? SizedBox.square(
                          dimension: 50,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 6,
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: EvidencijaTheme.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: EvidencijaTheme.primaryColorAlt.withOpacity(0.5),
                    offset: Offset(0, -13),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Evidentirani studenti:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  SizedBox(height: 20),
                  _loadingAttendedStudents
                      ? SizedBox.square(
                          dimension: 50,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 6,
                            ),
                          ),
                        )
                      : _attendedStudents.isEmpty
                          ? Text('Nema studenata')
                          : SizedBox.shrink(),
                  SizedBox(height: 20),
                  ..._attendedStudents.mapToList(
                    (attendedStudent) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(
                            '${attendedStudent.firstname} ${attendedStudent.lastname}'),
                        trailing: IconButton(
                          onPressed: () =>
                              _deleteAttendance(student: attendedStudent),
                          icon: Icon(Icons.close),
                        ),
                        onTap: () =>
                            _navigateToStudentDetails(student: attendedStudent),
                      ),
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
