class StudentModel {
  int id;
  String firstname;
  String lastname;
  String university;
  String deviceID;

  StudentModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.university,
    required this.deviceID,
  });

  factory StudentModel.copyFrom(StudentModel student) {
    return StudentModel(
      id: student.id,
      firstname: student.firstname,
      lastname: student.lastname,
      university: student.university,
      deviceID: student.deviceID,
    );
  }

  // Convert into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMapInsert() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'university': university,
      'deviceID': deviceID,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'university': university,
      'deviceID': deviceID,
    };
  }

  // Implement toString to make it easier to see information
  @override
  String toString() {
    return '\nStudent{id: $id, firstname: $firstname, lastname: $lastname, university: $university, deviceID: $deviceID}';
  }
}
