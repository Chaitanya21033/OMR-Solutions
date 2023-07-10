import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:omr_project/views/createexamscreen.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({Key? key}) : super(key: key);

  @override
  _ExamsScreenState createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User currentUser;
  List exams = []; // Initialize the exams variable as an empty list

  @override
  void initState() {
    super.initState();
    currentUser =
        FirebaseAuth.instance.currentUser!; // Get currently logged in user
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade900,
        title: const Text(
          'Exams',
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
              itemBuilder: (ctx, i) => Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Wrap(
                              children: [
                                Text(
                                  exams[i].data()['Exam Name'] ??
                                      'N/A', // Replace with your actual exam name field
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Delete Exam'),
                                content: Text(
                                    'Are you sure you want to delete this exam and all its occurences in your database?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Agree'),
                                    onPressed: () async {
                                      String adminEmail = FirebaseAuth
                                          .instance
                                          .currentUser!
                                          .email!; // Get currently logged in user's email
                                      String examName = exams[i].data()[
                                          'Exam Name']; // Get exam name from current exam
                                      final response = await http.post(
                                        Uri.parse(
                                            'http://192.168.1.18:5000/delete_exam'),
                                        headers: <String, String>{
                                          'Content-Type':
                                              'application/json; charset=UTF-8',
                                        },
                                        body: jsonEncode(<String, String>{
                                          'Admin_Email': adminEmail,
                                          'Exam_Name': examName,
                                        }),
                                      );
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Created on: ${exams[i].data()['Creation_Date'] ?? 'N/A'}', // Replace with your actual creation date field
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
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigo,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateExamScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
