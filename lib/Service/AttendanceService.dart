import 'package:attends_trecker/Models/AttendsModel.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AttendanceService {
  var _box = Hive.box("attendance");

  Future<void> fillAttendance(Attendance attendance) async {
    await _box.put(attendance.date.toString(), attendance.toMap());

    // _box.clear();
  }

  Future<List<Attendance>> getAllAttendance() async {
    List<Attendance> attendanceList = [];
    for (var i = 0; i < _box.length; i++) {
      attendanceList.add(Attendance.toModel(await _box.getAt(i)));
    }

    // Sort the list by date in ascending order
    attendanceList.sort((a, b) => b.date.compareTo(a.date));

    return attendanceList;
  }

  Future<void> deleteAttendance(Attendance attendance) async {
    await _box.delete(attendance.date.toString());
    print("deleted");
    // await _box.clear();
  }

  Future<void> updateAttendance(Attendance attendance) async {
    // Format the date to ignore time (only the date part)
    await _box.put(attendance.date.toString(), attendance.toMap());
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }
}
