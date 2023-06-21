class StudentAttendanceModel {
  int id;
  int attendanceID;
  int studentID;

  StudentAttendanceModel({
    required this.id,
    required this.attendanceID,
    required this.studentID,
  });

  factory StudentAttendanceModel.copyFrom(StudentAttendanceModel attendance) {
    return StudentAttendanceModel(
      id: attendance.id,
      attendanceID: attendance.attendanceID,
      studentID: attendance.studentID,
    );
  }

  // Convert into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMapInsert() {
    return {
      'name': attendanceID,
      'subjectID': studentID,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': attendanceID,
      'subjectID': studentID,
    };
  }

  // Implement toString to make it easier to see information
  @override
  String toString() {
    return '\nAttendance{id: $id, name: $attendanceID, subjectID: $studentID}';
  }
}
