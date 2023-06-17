import 'package:e_videncija/models/enums/role_enum.dart';
import 'package:e_videncija/views/init_role.dart';
import 'package:flutter/material.dart';

class Init extends StatelessWidget {
  const Init({super.key});

  _navigateToProfessor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => InitRole(
          role: Role.professor,
        ),
      ),
    );
  }

  _navigateToStudent(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => InitRole(
          role: Role.student,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset(
                'assets/images/e_videncija_icon_white.png',
                width: 150,
              ),
              SizedBox(height: 20),
              Text(
                'eVidencija',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              SizedBox(height: 80),
              TextButton(
                onPressed: () => _navigateToProfessor(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/professor_icon.png',
                      width: 36,
                    ),
                    SizedBox(width: 10),
                    Text('Profesor'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => _navigateToStudent(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/student_icon_alt.png',
                      width: 36,
                    ),
                    SizedBox(width: 10),
                    Text('Student'),
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
