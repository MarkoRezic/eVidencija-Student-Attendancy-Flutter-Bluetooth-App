import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:e_videncija/globals/settings.dart';
import 'package:e_videncija/models/enums/role_enum.dart';
import 'package:e_videncija/models/user_model.dart';
import 'package:e_videncija/providers/user_provider.dart';
import 'package:e_videncija/utils/map_indexed_to_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:provider/provider.dart';

import '../utils/show_toast.dart';

class StudentAttendanceScan extends StatefulWidget {
  const StudentAttendanceScan({super.key});

  @override
  State<StudentAttendanceScan> createState() => _StudentAttendanceScanState();
}

class _StudentAttendanceScanState extends State<StudentAttendanceScan> {
  List<Device> devices = [];
  List<Device> connectedDevices = [];
  late NearbyService nearbyService;
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;
  late UserModel user;
  bool isPhysicalDevice = true;

  bool isInit = false;

  @override
  void initState() {
    super.initState();
    init();
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

  void init() async {
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
            if (user.role == Role.student) {
              await nearbyService.stopBrowsingForPeers();
              await Future.delayed(Duration(microseconds: 200));
              await nearbyService.startBrowsingForPeers();
            } else {
              await nearbyService.stopAdvertisingPeer();
              await nearbyService.stopBrowsingForPeers();
              await Future.delayed(Duration(microseconds: 200));
              await nearbyService.startAdvertisingPeer();
              await nearbyService.startBrowsingForPeers();
            }
          }
        });
    subscription =
        nearbyService.stateChangedSubscription(callback: (devicesList) {
      devicesList.forEach((element) {
        print(
            " deviceId: ${element.deviceId} | deviceName: ${element.deviceName} | state: ${element.state}");

        if (Platform.isAndroid) {
          if (element.state == SessionState.connected) {
            nearbyService.stopBrowsingForPeers();
          } else {
            nearbyService.startBrowsingForPeers();
          }
        }
      });

      setState(() {
        devices.clear();
        devices.addAll(devicesList);
        connectedDevices.clear();
        connectedDevices.addAll(devicesList
            .where((d) => d.state == SessionState.connected)
            .toList());
        user = context.watch<UserProvider>().user;
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

  String getStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return "disconnected";
      case SessionState.connecting:
        return "waiting";
      default:
        return "connected";
    }
  }

  String getButtonStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return "Connect";
      default:
        return "Disconnect";
    }
  }

  Color getStateColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return Colors.black;
      case SessionState.connecting:
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  Color getButtonColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  _onTabItemListener(Device device) {
    if (device.state == SessionState.connected) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            final myController = TextEditingController();
            return AlertDialog(
              title: Text("Send message"),
              content: TextField(controller: myController),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Send"),
                  onPressed: () {
                    nearbyService.sendMessage(
                        device.deviceId, myController.text);
                    myController.text = '';
                  },
                )
              ],
            );
          });
    }
  }

  _onApprove(Device device) {
    if (device.state == SessionState.connected) {
      nearbyService.sendMessage(device.deviceId, 'Evidencija uspješna!');
    }
  }

  int getItemCount() {
    if (user.role == Role.professor) {
      return connectedDevices.length;
    } else {
      return devices.length;
    }
  }

  _onButtonClicked(Device device) {
    switch (device.state) {
      case SessionState.notConnected:
        nearbyService.invitePeer(
          deviceID: device.deviceId,
          deviceName: device.deviceName,
        );
        break;
      case SessionState.connected:
        nearbyService.disconnectPeer(deviceID: device.deviceId);
        break;
      case SessionState.connecting:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = context.watch<UserProvider>().user;
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
                'Spojeni profesori:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 20),
              ...professorNames.mapToList(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
