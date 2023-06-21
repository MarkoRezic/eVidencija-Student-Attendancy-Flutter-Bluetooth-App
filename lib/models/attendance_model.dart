class AttendanceModel {
  int id;
  String name;
  String createdAt;
  int subjectID;

  AttendanceModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.subjectID,
  });

  factory AttendanceModel.copyFrom(AttendanceModel attendance) {
    return AttendanceModel(
      id: attendance.id,
      name: attendance.name,
      createdAt: attendance.createdAt,
      subjectID: attendance.subjectID,
    );
  }

  // Convert into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMapInsert() {
    return {
      'name': name,
      'createdAt': createdAt,
      'subjectID': subjectID,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt,
      'subjectID': subjectID,
    };
  }

  // Implement toString to make it easier to see information
  @override
  String toString() {
    return '\nAttendance{id: $id, name: $name, createdAt: $createdAt, subjectID: $subjectID}';
  }
}
