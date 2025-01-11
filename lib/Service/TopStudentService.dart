import 'package:shared_preferences/shared_preferences.dart';

class TopStudentService {
  Future<List<int>> getTopStudents() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('rollNumbers')) {
      return [];
    }

    List<int>? rollNumbers = prefs
        .getStringList('rollNumbers')!
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    rollNumbers.sort();
    return rollNumbers;
  }

  Future<void> addStudent(int rollNumber) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? rollNumbers = prefs.getStringList('rollNumbers') ?? [];
    rollNumbers.add(rollNumber.toString());

    await prefs.setStringList('rollNumbers', rollNumbers);
  }

  Future<void> removeStudent(int rollNumber) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? rollNumbers = prefs.getStringList('rollNumbers') ?? [];
    rollNumbers.remove(rollNumber.toString());

    await prefs.setStringList('rollNumbers', rollNumbers);
  }
}
