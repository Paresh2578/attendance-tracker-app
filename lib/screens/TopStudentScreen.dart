import 'package:attends_trecker/Service/TopStudentService.dart';
import 'package:attends_trecker/utils/Rollnumbers.dart';
import 'package:flutter/material.dart';

class TopStudentScreen extends StatefulWidget {
  const TopStudentScreen({super.key});

  @override
  State<TopStudentScreen> createState() => _TopStudentScreenState();
}

class _TopStudentScreenState extends State<TopStudentScreen> {
  TopStudentService topStudentService = TopStudentService();
  List<int> rollNumber = [];

  @override
  void initState() {
    loadTopStudents();
    super.initState();
  }

  void loadTopStudents() async {
    List<int> topStudents = await topStudentService.getTopStudents();
    setState(() {
      rollNumber = topStudents;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Text('Top Students'),
      ),
      body: FutureBuilder(
        future: topStudentService.getTopStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          List<int> topStudents = snapshot.data as List<int>;

          return topStudents.length == 0
              ? Center(
                  child: Text(
                    'No student records found.',
                    style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: topStudents.length,
                  itemBuilder: (context, index) {
                    return StudentCard(topStudents[index], colorScheme);
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addStudenteDialog(context);
        },
        backgroundColor: colorScheme.secondary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  // Widget
  Widget StudentCard(int rollNumber, ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondary,
          child: Text(
            rollNumber.toString(),
            style: TextStyle(color: colorScheme.onSecondary),
          ),
        ),
        title: Text(
          'Batch ${RollNumbers.getBatchByRollNumber(rollNumber).toUpperCase()}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete,
            color: colorScheme.error,
          ),
          onPressed: () {
            _deleteStudent(rollNumber);
          },
        ),
      ),
    );
  }

  // function

  // add student dialog
  void _addStudenteDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController rollNumberController = TextEditingController();
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Add Student',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          content: TextField(
            controller: rollNumberController,
            onChanged: (value) {
              rollNumber.add(int.parse(value));
            },
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              label: Text("Enter Roll Number"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop("");
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(rollNumberController.text);
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
    ).then(
      (value) async {
        if (value != null && value.isNotEmpty) {
          // rollNumber.add(int.parse(value));
          await topStudentService.addStudent(int.parse(value));
          setState(() {});
        }
      },
    );
  }

  // delete student
  Future<void> _deleteStudent(int number) async {
    await topStudentService.removeStudent(number);
    setState(() {});
  }
}
