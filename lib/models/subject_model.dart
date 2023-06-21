class SubjectModel {
  int id;
  String name;

  SubjectModel({
    required this.id,
    required this.name,
  });

  factory SubjectModel.copyFrom(SubjectModel subject) {
    return SubjectModel(
      id: subject.id,
      name: subject.name,
    );
  }

  // Convert into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMapInsert() {
    return {
      'name': name,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Implement toString to make it easier to see information
  @override
  String toString() {
    return '\nSubject{id: $id, name: $name}';
  }
}
