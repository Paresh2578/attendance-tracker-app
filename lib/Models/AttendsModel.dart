import 'package:attends_trecker/Models/StudentModel.dart';

class Attendance {
  final String id;
  final DateTime date;
  final List<String> batchs;
  final List<Student> presentList;
  final List<Student> absentList;

  Attendance(
      {required this.id,
      required this.date,
      required this.batchs,
      required this.presentList,
      required this.absentList});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'batchs': batchs,
      'presentList': presentList.map((e) => e.toMap()).toList(),
      'absentList': absentList.map((e) => e.toMap()).toList(),
    };
  }

  static Attendance toModel(Map<dynamic, dynamic> attendance) {
    return Attendance(
      id: attendance["id"],
      date: attendance["date"],
      batchs: List<String>.from(attendance["batchs"]),
      presentList: List<Student>.from(
          attendance["presentList"].map((e) => Student.toModel(e))),
      absentList: List<Student>.from(
          attendance["absentList"].map((e) => Student.toModel(e))),
    );
  }
}
