import 'package:attends_trecker/Models/AttendsModel.dart';
import 'package:attends_trecker/Service/AttendanceService.dart';
import 'package:attends_trecker/screens/TakeAttendanceScreen.dart';
import 'package:attends_trecker/utils/Rollnumbers.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Attendance> attendanceList = [];
  AttendanceService attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    _loadAttendance(); // Load the attendance data when the screen is initialized
  }

  // Function to load attendance from the database
  void _loadAttendance() async {
    List<Attendance> data = await attendanceService.getAllAttendance();
    setState(() {
      attendanceList = data; // Update the attendance list
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Tracker'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: FutureBuilder<List<Attendance>>(
        future:
            attendanceService.getAllAttendance(), // Fetch attendance records
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            attendanceList =
                snapshot.data!; // Update the list when data is received
            return attendanceList.isEmpty
                ? Center(
                    child: Text(
                      'No attendance records found.',
                      style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: attendanceList.length,
                    itemBuilder: (context, index) {
                      Attendance attendance = attendanceList[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(
                            attendance.batchs.join(","),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: colorScheme.primary,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('dd MMM yyyy').format(attendance.date),
                            style: TextStyle(
                              color: colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'P: ${attendance.presentList.length} | A: ${attendance.absentList.length}',
                                style: TextStyle(
                                    color: colorScheme.onPrimaryContainer,
                                    fontSize: 15),
                              ),
                              Text(
                                'T: ${attendance.presentList.length + attendance.absentList.length}',
                                style: TextStyle(
                                    color: colorScheme.secondary, fontSize: 15),
                              ),
                            ],
                          ),
                          onLongPress: () {
                            _deleteAttendance(attendance, colorScheme);
                          },
                          onTap: () {
                            _editAttendance(attendance, colorScheme);
                          },
                        ),
                      );
                    },
                  );
          } else {
            return Center(
              child: Text(
                'Error fetching data.',
                style: TextStyle(
                  fontSize: 18,
                  color: colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addAttendanceDialog(context);
        },
        backgroundColor: colorScheme.secondary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  // Dialog to add attendance
  void _addAttendanceDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    TextEditingController dateController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    dateController.text = DateFormat("dd/MMM/yyyy").format(selectedDate);

    List<String> selectedBatchs = [];
    List<String> allBatchs = ["a5", "a6", "b1", "b2", "b3", "c1"];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context1, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Add Attendance',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: dateController,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2026),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: colorScheme.copyWith(
                                  primary: colorScheme.primary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          selectedDate = date;
                          dateController.text =
                              DateFormat("dd/MMM/yyyy").format(date);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ChipsChoice<String>.multiple(
                      value: selectedBatchs,
                      onChanged: (val) => setState(() => selectedBatchs = val),
                      choiceItems: C2Choice.listFrom<String, String>(
                        source: allBatchs,
                        value: (i, v) => v,
                        label: (i, v) => v.toUpperCase(),
                      ),
                      choiceStyle: C2ChipStyle.filled(
                        selectedStyle: C2ChipStyle(
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _startAttendance(selectedBatchs, selectedDate);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Start attendance screen with the selected batches
  void _startAttendance(List<String> selectedBatchs, DateTime selectedDate) {
    List<int> rollNumbers = [];

    for (var batch in selectedBatchs) {
      rollNumbers.addAll(RollNumbers.rollNumbers[batch]!);
    }

    rollNumbers.sort();

    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => TakeAttendanceScreen(
        rollNumbers: rollNumbers,
        batchs: selectedBatchs.map((batch) => batch.toUpperCase()).join(","),
        date: selectedDate,
      ),
    ))
        .then((value) {
      if (value != null) {
        setState(() {
          attendanceList.add(value); // Add the new attendance to the list
          attendanceService.fillAttendance(value); // Save the attendance
        });
      }
      Navigator.of(context).pop();
    });
  }

  // Delete the selected attendance
  void _deleteAttendance(Attendance attendance, ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Attendance',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this attendance record?',
            style: TextStyle(
              color: colorScheme.onBackground,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await attendanceService
                    .deleteAttendance(attendance); // Delete attendance
                setState(() {
                  attendanceList.remove(attendance); // Remove it from the UI
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Edit the selected attendance
  void _editAttendance(Attendance attendance, ColorScheme colorScheme) {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => TakeAttendanceScreen(
        rollNumbers: [],
        batchs: attendance.batchs.join(","),
        date: attendance.date,
        absentList: attendance.absentList,
        presentList: attendance.presentList,
      ),
    ))
        .then((value) {
      if (value != null) {
        attendanceService.updateAttendance(attendance); // Update the attendance
        setState(() {}); // Refresh the UI
      }
    });
  }
}
