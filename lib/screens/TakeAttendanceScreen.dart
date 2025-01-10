import 'package:attends_trecker/Models/AttendsModel.dart';
import 'package:attends_trecker/Models/StudentModel.dart';
import 'package:flutter/material.dart';

class TakeAttendanceScreen extends StatefulWidget {
  final List<int> rollNumbers;
  final String batchs;
  final DateTime date;
  List<Student>? absentList;
  List<Student>? presentList;

  TakeAttendanceScreen(
      {super.key,
      required this.rollNumbers,
      required this.batchs,
      required this.date,
      this.absentList,
      this.presentList});

  @override
  State<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  List<Student> presentList = [], tempPresentList = [];
  List<Student> absentList = [], tempAbsentList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.presentList != null && widget.absentList != null) {
      presentList = widget.presentList!;
      tempPresentList = presentList;

      absentList = widget.absentList!;
      tempAbsentList = absentList;
    } else {
      absentList =
          widget.rollNumbers.map((roll) => Student(rollNumber: roll)).toList();
      tempAbsentList = absentList;
    }
//
    setState(() {});
  }

  @override
  void dispose() {
    searchController.dispose();

    // clear all data
    presentList.clear();
    tempPresentList.clear();
    absentList.clear();
    tempAbsentList.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    print("********* call &*************");

    return WillPopScope(
      onWillPop: () async {
        // Show the dialog when the user tries to pop the screen (back)
        bool shouldDelete = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Delete Attendance',
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
                  onPressed: () {
                    Navigator.of(context).pop(false); // No delete, just cancel
                  },
                  child: const Text('No'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Confirm delete
                  },
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
        );

        return shouldDelete; // Proceed with popping the screen
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.inversePrimary,
          title: Text(
            '${widget.batchs} | P: ${presentList.length} | A: ${absentList.length} | T: ${presentList.length + absentList.length}',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: Column(
          children: [
            searchWidget(colorScheme),
            Expanded(
              child: ListView.builder(
                itemCount: tempAbsentList.length + tempPresentList.length,
                itemBuilder: (context, index) {
                  Student student;

                  if (index < tempAbsentList.length) {
                    student = tempAbsentList[index];
                  } else {
                    student = tempPresentList[index - tempAbsentList.length];
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
                      // title: Text(
                      //   'Roll Number: ${student.rollNumber}',
                      //   style: TextStyle(
                      //       fontWeight: FontWeight.bold,
                      //       color: colorScheme.onBackground),
                      // ),
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 40,
          color: colorScheme.primaryContainer,
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop(Attendance(
                  date: widget.date,
                  batchs: widget.batchs.split(","),
                  presentList: presentList,
                  absentList: absentList));
            },
            child: Center(
              child: Text(
                "${widget.presentList == null ? "Save" : "Edit"}",
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       ElevatedButton.icon(
          //         onPressed: () {
          // Navigator.of(context).pop(Attendance(
          //   date: widget.date,
          //   batchs: widget.batchs.split(","),
          //   presentList: presentList,
          //   absentList: absentList,
          // ));
          //         },
          //         icon: const Icon(Icons.save),
          //         label: const Text("Save"),
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: colorScheme.primary,
          //           foregroundColor: colorScheme.onPrimary,
          //           textStyle: const TextStyle(fontWeight: FontWeight.bold),
          //         ),
          //       ),
          //     ],
          //   ),
        ),
      ),
    );
  }

  void presentToAbsent({required Student student}) {
    // Remove the student from present list
    if (presentList.contains(student)) {
      presentList.remove(student);
      tempPresentList.remove(student);
    }

    // Ensure student is not added to absent list twice
    if (!absentList.contains(student)) {
      student.gread = null; // Remove grade
      absentList.add(student);
      tempAbsentList.add(student);
    }

    sortStudent();
    setState(() {});
  }

  void sortStudent() {
    presentList.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
    tempPresentList.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
    absentList.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
    tempAbsentList.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
  }

  Widget greadsWidget(
      {required String gread,
      required Student student,
      required ColorScheme colorScheme}) {
    bool isPresentOperation =
        student.gread != null ? student.gread!.isEmpty : true;

    return InkWell(
      onTap: () {
        // If the grade is already set to this one, don't do anything
        // if (student.gread == gread.trim()) return;

        student.gread = gread;

        // Ensure we only add the student if they are not already in the lists
        if (isPresentOperation) {
          // If it's not already in the present list, add it
          if (!presentList.contains(student)) {
            // presentList.add(student);
            tempPresentList.add(student);
          }
          // Remove the student from absent list if they're already there
          if (absentList.contains(student)) {
            // absentList.remove(student);
            tempAbsentList.remove(student);
          }
        }

        sortStudent();
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: (student.gread ?? "") == gread.trim()
              ? colorScheme.tertiaryContainer
              : Colors.transparent,
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
            color: (student.gread ?? "") == gread.trim()
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
        boxShadow: [
          const BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
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
        onChanged: (value) {
          tempPresentList = presentList
              .where(
                (stu) => stu.rollNumber
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()),
              )
              .toList();

          tempAbsentList = absentList
              .where(
                (stu) => stu.rollNumber
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()),
              )
              .toList();

          setState(() {});
        },
      ),
    );
  }
}
