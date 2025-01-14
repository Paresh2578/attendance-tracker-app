import 'package:attends_trecker/Models/AttendsModel.dart';
import 'package:attends_trecker/Models/StudentModel.dart';
import 'package:flutter/material.dart';

class TakeAttendanceScreen extends StatefulWidget {
  final String? id;
  final List<int> rollNumbers;
  final String batchs;
  final DateTime date;
  final List<Student>? absentList;
  final List<Student>? presentList;

  const TakeAttendanceScreen({
    Key? key,
    this.id,
    required this.rollNumbers,
    required this.batchs,
    required this.date,
    this.absentList,
    this.presentList,
  }) : super(key: key);

  @override
  State<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  late DateTime selectedDate;
  List<Student> presentList = [];
  List<Student> absentList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.date;

    if (widget.presentList != null && widget.absentList != null) {
      presentList = widget.presentList!;
      absentList = widget.absentList!;
    } else {
      absentList =
          widget.rollNumbers.map((roll) => Student(rollNumber: roll)).toList();
    }
    sortStudent();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return WillPopScope(
      onWillPop: () => _showBackConfirmationDialog(colorScheme),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          title: Text(
            '${widget.batchs} | P: ${presentList.length} | A: ${absentList.length} | T: ${presentList.length + absentList.length}',
            style: const TextStyle(fontSize: 20),
          ),
          actions: [
            IconButton(
              onPressed: _updateDate,
              icon: const Icon(Icons.date_range_outlined),
            ),
          ],
        ),
        body: Column(
          children: [
            searchWidget(colorScheme),
            Expanded(
              child: ListView.builder(
                itemCount: absentList.length + presentList.length,
                itemBuilder: (context, index) {
                  Student student;
                  if (index < absentList.length) {
                    student = absentList[index];
                  } else {
                    student = presentList[index - absentList.length];
                  }

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.secondary,
                        child: Text(
                          student.rollNumber.toString(),
                          style: TextStyle(color: colorScheme.onSecondary),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          greadsWidget(
                              gread: "A",
                              student: student,
                              colorScheme: colorScheme),
                          greadsWidget(
                              gread: "B",
                              student: student,
                              colorScheme: colorScheme),
                          greadsWidget(
                              gread: "C",
                              student: student,
                              colorScheme: colorScheme),
                          if (student.gread != null)
                            IconButton(
                              onPressed: () =>
                                  presentToAbsent(student: student),
                              icon: Icon(Icons.cancel_outlined,
                                  color: colorScheme.error),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          height: 50,
          color: colorScheme.secondary,
          child: InkWell(
            onTap: _saveAttendance,
            child: Center(
              child: Text(
                widget.presentList == null ? "Save" : "Edit",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateDate() async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
    );

    if (newDate != null && newDate != selectedDate) {
      setState(() {
        selectedDate = newDate;
      });
    }
  }

  Future<bool> _showBackConfirmationDialog(ColorScheme colorScheme) async {
    return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                'Back Conformation',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
              content: Text(
                'Are you sure you want to Back Without Save?',
                style: TextStyle(
                  color: colorScheme.onBackground,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                  ),
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _saveAttendance() {
    Navigator.of(context).pop(
      Attendance(
        id: widget.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: selectedDate,
        batchs: widget.batchs.split(","),
        presentList: presentList,
        absentList: absentList,
      ),
    );
  }

  void presentToAbsent({required Student student}) {
    if (presentList.contains(student)) {
      presentList.remove(student);
    }
    if (!absentList.contains(student)) {
      student.gread = null;
      absentList.add(student);
    }
    sortStudent();
    setState(() {});
  }

  void sortStudent() {
    presentList.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
    absentList.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
  }

  Widget greadsWidget({
    required String gread,
    required Student student,
    required ColorScheme colorScheme,
  }) {
    bool isSelected = student.gread == gread;
    return InkWell(
      onTap: () {
        if (student.gread != gread) {
          student.gread = gread;
          if (!presentList.contains(student)) {
            presentList.add(student);
          }
          absentList.remove(student);
          sortStudent();
          setState(() {});
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected ? colorScheme.tertiaryContainer : Colors.transparent,
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 13),
        margin: const EdgeInsets.only(left: 15),
        child: Text(
          gread,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isSelected
                ? colorScheme.onTertiaryContainer
                : colorScheme.onBackground,
          ),
        ),
      ),
    );
  }

  Widget searchWidget(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: searchController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          hintText: "Search roll number...",
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        ),
      ),
    );
  }
}
