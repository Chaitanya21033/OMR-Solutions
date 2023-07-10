import 'package:cloud_firestore/cloud_firestore.dart'; //Import Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:omr_project/views/designexamscreen.dart';

class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({super.key});

  @override
  _CreateExamScreenState createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController examNameController = TextEditingController();

  String adminEmail = "";
  List<String> answerKey = ["", "", "", ""];
  String examName = "";
  String organisationID = "";

  int rollNumberDigits = 5;
  int numberOfExamSets = 3;
  int numberOfSubjects = 0;
  List<SubjectData> subjects = [];

  void increaseRollNumberDigits() {
    setState(() {
      if (rollNumberDigits < 5) {
        rollNumberDigits++;
      } else {
        showMaxLimitReachedDialog();
      }
    });
  }

  void decreaseRollNumberDigits() {
    setState(() {
      if (rollNumberDigits > 0) {
        rollNumberDigits--;
      }
    });
  }

  void increaseNumberOfExamSets() {
    setState(() {
      if (numberOfExamSets < 3) {
        numberOfExamSets++;
      } else {
        showMaxLimitReachedDialog();
      }
    });
  }

  void decreaseNumberOfExamSets() {
    setState(() {
      if (numberOfExamSets > 0) {
        numberOfExamSets--;
      }
    });
  }

  void increaseNumberOfSubjects() {
    setState(() {
      if (numberOfSubjects < 5) {
        numberOfSubjects++;
        subjects.add(SubjectData(numberOfSubjects, ''));
      } else {
        showMaxLimitReachedDialog();
      }
    });
  }

  void decreaseNumberOfSubjects() {
    setState(() {
      if (numberOfSubjects > 0) {
        numberOfSubjects--;
        subjects.removeLast();
      }
    });
  }

  void showMaxLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Maximum Limit Reached'),
        content:
            const Text('You have reached the maximum limit for this value.'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade900,
        title: const Text(
          'Create Exam',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: examNameController,
              decoration: const InputDecoration(
                labelText: 'Exam Name',
                hintText: 'Enter the name of the exam',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Roll Number Digits:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.remove,
                    color: Colors.indigo,
                  ),
                  onPressed: decreaseRollNumberDigits,
                ),
                Text(
                  '$rollNumberDigits',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Colors.indigo,
                  ),
                  onPressed: increaseRollNumberDigits,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Number of Exam Sets:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.remove,
                    color: Colors.indigo,
                  ),
                  onPressed: decreaseNumberOfExamSets,
                ),
                Text(
                  '$numberOfExamSets',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Colors.indigo,
                  ),
                  onPressed: increaseNumberOfExamSets,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Number of Subjects:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.remove,
                    color: Colors.indigo,
                  ),
                  onPressed: decreaseNumberOfSubjects,
                ),
                Text(
                  '$numberOfSubjects',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Colors.indigo,
                  ),
                  onPressed: increaseNumberOfSubjects,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'S.No',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Subject',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Sections',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${subjects[index].sno}',
                        style: const TextStyle(
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Enter subject',
                        ),
                        onChanged: (value) {
                          subjects[index].subject = value;
                        },
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: DropdownButton<int>(
                        value: subjects[index].sections,
                        onChanged: (value) {
                          setState(() {
                            subjects[index].sections = value!;
                          });
                        },
                        items: List.generate(5, (index) {
                          return DropdownMenuItem<int>(
                            value: index + 1,
                            child: Text('${index + 1}'),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () async {
          Exam exam = Exam(
            adminEmail: adminEmail,
            answerKey: answerKey,
            examSets: numberOfExamSets,
            name: examName,
            rollNumberDigits: rollNumberDigits,
            subjects: numberOfSubjects,
          );
          User? user = auth.currentUser;
// Set the data for the exams document
          // final examsRef = FirebaseFirestore.instance.collection('Exams');
          // final QuerySnapshot duplicateExams = await examsRef
          //     .where('Admin_Email', isEqualTo: user?.email)
          //     .where('Name', isEqualTo: examNameController.text)
          //     .limit(1)
          //     .get();

          // TO DO: Check if the exam name already exists
          if (false) {
            // Duplicate exams found, show error message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Exam with the same name already exists'),
              ),
            );
          } else {
            // No duplicate exams found, proceed with adding the document
            // final examsDoc = examsRef.doc();
            // // Set the data for the exams document
            // await examsDoc.set({
            //   'Exam_Sets': numberOfExamSets,
            //   'Admin_Email': user?.email,
            //   'Name': examNameController.text,
            //   'Roll_Number_Digits': rollNumberDigits,
            //   'Subjects': numberOfSubjects,
              
            // });

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DesignExamScreen(
                  adminEmail: user?.email,
                  rollNumberDigits: rollNumberDigits,
                  numberOfExamSets: numberOfExamSets,
                  numberOfSubjects: numberOfSubjects,
                  listofsubjects: subjects,
                  examName: examNameController.text,
                ),
              ),
            );
          }
        },
        child: const Text(
          'Next',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class Exam {
  String adminEmail;
  List<String> answerKey;
  int examSets;
  String name;
  int rollNumberDigits;
  int subjects;

  Exam({
    required this.adminEmail,
    required this.answerKey,
    required this.examSets,
    required this.name,
    required this.rollNumberDigits,
    required this.subjects,
  });

  Map<String, dynamic> toJson() => {
        'Admin_Email': adminEmail,
        'AnswerKey': answerKey,
        'Exam_Sets': examSets,
        'Name': name,
        'Roll_Number_digits': rollNumberDigits,
        'Subjects': subjects,
      };
}

class Sectiondata {
  String section_name;
  int number_of_questions;
  String question_type;
  int number_of_options;
  int marks_for_correct;
  int marks_for_incorrect;
  Sectiondata(
    this.section_name,
    this.number_of_questions,
    this.question_type,
    this.number_of_options,
    this.marks_for_correct,
    this.marks_for_incorrect,
  );
}

class SubjectData {
  int sno;
  String subject;
  int sections;
  List<List<Sectiondata>> sectionsData = [];
  SubjectData(this.sno, this.subject, {this.sections = 1});
}
