import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:e_videncija/globals/settings.dart';
import 'package:e_videncija/models/user_model.dart';
import 'package:e_videncija/providers/user_provider.dart';
import 'package:e_videncija/utils/map_indexed_to_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:provider/provider.dart';

import '../utils/show_toast.dart';

class StudentAttendanceScan extends StatefulWidget {
  const StudentAttendanceScan({super.key});

  @override
  State<StudentAttendanceScan> createState() => _StudentAttendanceScanState();
}

class _StudentAttendanceScanState extends State<StudentAttendanceScan> {
  List<Device> _connectedDevices = [];
  late NearbyService nearbyService;
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;
  late UserModel user;
  bool isPhysicalDevice = true;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      initScan();
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

  void initScan() async {
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
    await nearbyService.init(
        serviceType: 'mpconn',
        deviceName: devInfo,
        strategy: Strategy.P2P_CLUSTER,
        callback: (isRunning) async {
          if (isRunning) {
            await nearbyService.stopAdvertisingPeer();
            await nearbyService.stopBrowsingForPeers();
            await Future.delayed(Duration(microseconds: 200));
            await nearbyService.startAdvertisingPeer();
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

      //find professor device as the one that was not in the previous list
      //(if there are multiple just take first one, because in practice only 1 professor should connect at a time)
      List<Device> newProfessorDevices = devicesList
          .where((device) =>
              device.state == SessionState.connected &&
              !_connectedDevices.any((connectedDevice) =>
                  connectedDevice.deviceId == device.deviceId))
          .toList();
      Device? professorDevice =
          newProfessorDevices.isEmpty ? null : newProfessorDevices.first;
      //send message containing student data to professor that just connected
      if (professorDevice != null) {
        nearbyService.sendMessage(professorDevice.deviceId,
            (await Settings.getInstance()).asJSONString());
      }

      setState(() {
        //update devices list
        _connectedDevices.clear();
        _connectedDevices.addAll(devicesList
            .where((d) => d.state == SessionState.connected)
            .toList());
      });
    });

    receivedDataSubscription =
        nearbyService.dataReceivedSubscription(callback: (data) {
      debugPrint("dataReceivedSubscription: ${jsonEncode(data)}");

      showToast(
        data["message"],
        context: context,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    user = context.watch<UserProvider>().user;
    List<String> professorNames = [
      'Marko Rezic',
      'Toni Milun',
      'Arnold Schwarzeneger'
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Nazad'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset(
                'assets/images/scan_active_icon_white.png',
                width: 150,
              ),
              SizedBox(height: 20),
              Text(
                'Evidencija Aktivna',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Bluetooth uređaj je vidljiv,\nmolimo pričekajte da profesor odobri evidenciju.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 40),
              SizedBox.square(
                dimension: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 12,
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Spojeni uređaji:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  child: ListView(
                    children: (!isPhysicalDevice
                        ? professorNames.mapToList(
                            (professorName) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 4,
                                    backgroundColor: Colors.white,
                                  ),
                                  SizedBox(width: 20),
                                  Text(
                                    professorName,
                                    style: TextStyle(fontSize: 18),
                                  )
                                ],
                              ),
                            ),
                          )
                        : _connectedDevices.mapToList(
                            (device) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 4,
                                    backgroundColor: Colors.white,
                                  ),
                                  SizedBox(width: 20),
                                  Text(
                                    '${device.deviceName}   ID: ${device.deviceId}',
                                    style: TextStyle(fontSize: 18),
                                  )
                                ],
                              ),
                            ),
                          )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
