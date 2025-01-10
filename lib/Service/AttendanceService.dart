import 'dart:math';

import 'package:attends_trecker/Models/AttendsModel.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

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
}
