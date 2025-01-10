class Student {
  final int rollNumber;
  String? gread;

  Student({required this.rollNumber, this.gread});

  Map<String, dynamic> toMap() {
    return {
      'rollNumber': rollNumber,
      'gread': gread,
    };
  }

  static Student toModel(Map<dynamic, dynamic> student) {
    return Student(rollNumber: student["rollNumber"], gread: student["gread"]);
  }
}
