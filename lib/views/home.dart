import 'package:e_videncija/models/enums/role_enum.dart';
import 'package:e_videncija/providers/user_provider.dart';
import 'package:e_videncija/utils/capitalize_first_letter.dart';
import 'package:e_videncija/utils/role_local_name.dart';
import 'package:e_videncija/views/professor_attendance_list.dart';
import 'package:e_videncija/views/settings_page.dart';
import 'package:e_videncija/views/student_attendance_scan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => SettingsPage()));
  }

  _navigateToAttendance(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) =>
            context.watch<UserProvider>().role == Role.student
                ? StudentAttendanceScan()
                : ProfessorAttendanceList()));
  }

  @override
  Widget build(BuildContext context) {
    var user = context.watch<UserProvider>().user;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Nazad'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/${user.role.name}_icon_white.png',
                    width: 80,
                  ),
                  SizedBox(width: 20),
                  Text(
                    user.role.localName.toCapitalized(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Dobrodošli, ${user.firstname}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 150),
              TextButton(
                onPressed: () => _navigateToAttendance(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(user.role == Role.professor
                        ? 'Evidencija'
                        : 'Evdentiraj'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () => _navigateToSettings(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Postavke'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
