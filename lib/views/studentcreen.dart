import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key}) : super(key: key);

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User currentUser;
  List exams = [];

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!;
    getExams();
  }

  Future<void> getExams() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Exams')
          .where('Admin_Email', isEqualTo: currentUser.email)
          .get();
      exams = querySnapshot.docs;
      setState(() {});
    } catch (e) {
      print('Error getting exams: $e');
    }
  }

  void navigateToExamDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamDetailScreen(
          adminEmail: currentUser.email ?? 'N/A',
          examName: exams[index].data()['Exam Name'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade900,
        title: const Text(
          'Student',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: exams.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: exams.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () => navigateToExamDetail(i),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          exams[i].data()['Exam Name'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Created on: ${exams[i].data()['Creation_Date'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class ExamDetailScreen extends StatefulWidget {
  final String adminEmail;
  final String examName;

  const ExamDetailScreen({
    required this.adminEmail,
    required this.examName,
    Key? key,
  }) : super(key: key);

  @override
  _ExamDetailScreenState createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List students;

  @override
  void initState() {
    super.initState();
    getStudents();
  }

  Future<void> getStudents() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Results')
          .where('Admin Email', isEqualTo: widget.adminEmail)
          .where('Exam Name', isEqualTo: widget.examName)
          .get();
      students = querySnapshot.docs;
      setState(() {});
    } catch (e) {
      print('Error getting students: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade900,
        title: Text(
          'Exam Detail',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: students == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (ctx, i) => Card(
                child: InkWell(
                  // added this
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Container(
                            width: double.maxFinite,
                            child: Image.network(
                              students[i].data()['Image_Sheet'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Roll Number:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(students[i].data()['Roll Number'] ?? 'N/A'),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exam Name:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(students[i].data()['Exam Name'] ?? 'N/A'),
                        Text(
                          'Marks Obtained:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(students[i].data()['Marks'] ?? 'N/A'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
