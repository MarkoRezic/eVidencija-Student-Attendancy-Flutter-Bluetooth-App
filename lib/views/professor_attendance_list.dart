import 'package:e_videncija/providers/user_provider.dart';
import 'package:e_videncija/utils/map_indexed_to_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfessorAttendanceList extends StatefulWidget {
  const ProfessorAttendanceList({super.key});

  @override
  State<ProfessorAttendanceList> createState() =>
      _ProfessorAttendanceListState();
}

class _ProfessorAttendanceListState extends State<ProfessorAttendanceList> {
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
              Text(
                'Evidencija Aktivna',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Bluetooth uređaj je vidljiv, molimo pričekajte da profesor odobri evidenciju.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 40),
              SizedBox.square(
                dimension: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 10,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Spojeni profesori:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              ...professorNames.mapToList(
                (professorName) => Row(
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      professorName,
                    )
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
