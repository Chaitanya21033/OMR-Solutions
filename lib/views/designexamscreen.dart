import 'mainpage.dart' as mainpage_data;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:omr_project/views/createexamscreen.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/widgets.dart' as pdfWidgets;

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
      this.marks_for_correct,
      this.marks_for_incorrect,
      this.number_of_options) {
    if (!{3, 4, 5}.contains(number_of_options)) {
      number_of_options = 3; // default value
    }
  }
}

class DesignExamScreen extends StatefulWidget {
  final int rollNumberDigits;
  final int numberOfExamSets;
  final int numberOfSubjects;
  final String examName;
  final String? adminEmail;
  final List<SubjectData> listofsubjects;

  const DesignExamScreen({
    super.key,
    required this.rollNumberDigits,
    required this.numberOfExamSets,
    required this.numberOfSubjects,
    required this.listofsubjects,
    required this.examName,
    required this.adminEmail,
  });

  @override
  _DesignExamScreenState createState() => _DesignExamScreenState();
}

class _DesignExamScreenState extends State<DesignExamScreen> {
  String? selectedQuestionType;
  // File? _imageFile;
  List<List<Sectiondata>> sectionsData = [];

  @override
  void initState() {
    super.initState();
    initializeSectionsData();
  }

  void initializeSectionsData() {
    for (var subject in widget.listofsubjects) {
      List<Sectiondata> subjectSections = [];
      for (int section = 0; section < subject.sections; section++) {
        subjectSections.add(Sectiondata('', 0, 'MCQ', 4, 4, 0));
      }
      sectionsData.add(subjectSections);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade900,
        title: const Text(
          'Design Exam',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Roll Number Digits: ${widget.rollNumberDigits}',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Number of Exam Sets: ${widget.numberOfExamSets}',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Number of Subjects: ${widget.numberOfSubjects}',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              for (var subject in widget.listofsubjects)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subject: ${subject.subject}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (int section = 1;
                        section <= subject.sections;
                        section++)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Section $section',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Section Name',
                            ),
                            onChanged: (value) {
                              int subjectIndex =
                                  widget.listofsubjects.indexOf(subject);
                              int sectionIndex = section - 1;
                              sectionsData[subjectIndex][sectionIndex]
                                  .section_name = value;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Number of Questions',
                            ),
                            onChanged: (value) {
                              int subjectIndex =
                                  widget.listofsubjects.indexOf(subject);
                              int sectionIndex = section - 1;
                              sectionsData[subjectIndex][sectionIndex]
                                  .number_of_questions = int.parse(value);
                            },
                          ),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Question Type',
                            ),
                            value: sectionsData[widget.listofsubjects
                                    .indexOf(subject)][section - 1]
                                .question_type,
                            onChanged: (newValue) {
                              setState(() {
                                int subjectIndex =
                                    widget.listofsubjects.indexOf(subject);
                                int sectionIndex = section - 1;
                                sectionsData[subjectIndex][sectionIndex]
                                    .question_type = newValue!;
                              });
                            },
                            items: const [
                              DropdownMenuItem(
                                value: 'MCQ',
                                child: Text('MCQ'),
                              ),
                              DropdownMenuItem(
                                value: 'TF',
                                child: Text('True/False'),
                              ),
                            ],
                          ),
                          if (sectionsData[widget.listofsubjects
                                      .indexOf(subject)][section - 1]
                                  .question_type ==
                              'MCQ')
                            DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Number of Options',
                              ),
                              value: sectionsData[widget.listofsubjects
                                      .indexOf(subject)][section - 1]
                                  .number_of_options,
                              onChanged: (newValue) {
                                setState(() {
                                  int subjectIndex =
                                      widget.listofsubjects.indexOf(subject);
                                  int sectionIndex = section - 1;
                                  sectionsData[subjectIndex][sectionIndex]
                                      .number_of_options = newValue!;
                                });
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: 3,
                                  child: Text('3'),
                                ),
                                DropdownMenuItem(
                                  value: 4,
                                  child: Text('4'),
                                ),
                                DropdownMenuItem(
                                  value: 5,
                                  child: Text('5'),
                                ),
                              ],
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Marks for Correct Answer',
                            ),
                            onChanged: (value) {
                              int subjectIndex =
                                  widget.listofsubjects.indexOf(subject);
                              int sectionIndex = section - 1;
                              sectionsData[subjectIndex][sectionIndex]
                                  .marks_for_correct = int.parse(value);
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Negative Marks for Wrong Answer',
                            ),
                            onChanged: (value) {
                              int subjectIndex =
                                  widget.listofsubjects.indexOf(subject);
                              int sectionIndex = section - 1;
                              sectionsData[subjectIndex][sectionIndex]
                                  .marks_for_incorrect = int.parse(value);
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: createExam,
        child: const Text('Create'),
      ),
    );
  }

  createExam() async {
    var temp = mainpage_data.httpAddress;
    var url = temp + '/create_omr_sheet';
    url = "http://192.168.1.21:5000/create_omr_sheet";
    print(url);
    var requestBody = {
      'roll_number_digits': widget.rollNumberDigits,
      'number_of_exam_set': widget.numberOfExamSets,
      'number_of_subjects': widget.numberOfSubjects,
      'name_of_exam': widget.examName,
      'admin_email': widget.adminEmail,
      'subjects': widget.listofsubjects.map((subject) {
        int subjectIndex = widget.listofsubjects.indexOf(subject);
        return {
          'name': subject.subject,
          'number_of_sections': subject.sections,
          'sections': List.generate(subject.sections, (sectionIndex) {
            var sectionData = sectionsData[subjectIndex][sectionIndex];
            return {
              'section_heading': sectionData.section_name,
              'number_of_questions': sectionData.number_of_questions,
              'number_of_options': sectionData.number_of_options,
              'question_type': sectionData.question_type,
              'height_of_section': 0,
            };
          }).toList(),
        };
      }).toList(),
    };

    var request = http.Request('POST', Uri.parse(url));
    request.headers.addAll(<String, String>{
      'Content-Type': 'application/json',
    });
    request.body = jsonEncode(requestBody);

    var client = http.Client();
    var streamedResponse = await client.send(request);
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final byteData = response.bodyBytes;
      final imageData = byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ImageDisplayScreen(imageData: imageData),
        fullscreenDialog: true,
      ));
    } else {
      // Failed to create OMR sheet
      print('Failed to create OMR sheet');
    }
  }
}

class ImageDisplayScreen extends StatefulWidget {
  final Uint8List? imageData;

  const ImageDisplayScreen({super.key, required this.imageData});

  @override
  _ImageDisplayScreenState createState() => _ImageDisplayScreenState();
}

class _ImageDisplayScreenState extends State<ImageDisplayScreen> {
  String _statusText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            widget.imageData == null
                ? const Text('No image')
                : Image.memory(widget.imageData!),
            const SizedBox(height: 20),
            Text(
              _statusText,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: () {
              _saveAsImage(widget.imageData);
            },
            tooltip: 'Save as image',
            child: const Icon(Icons.image),
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: () {
              _saveAsPdf(widget.imageData);
            },
            tooltip: 'Save as PDF',
            child: const Icon(Icons.picture_as_pdf),
          ),
        ],
      ),
    );
  }

  _saveAsImage(Uint8List? imageData) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      // Permission has not been granted, request it
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      // Permission has been granted, proceed to save the image
      final directory = await getExternalStorageDirectory();

      final filePath = await FilePicker.platform.getDirectoryPath();
      final path = directory!.path;
      final file = File('$path/omr_sheet.png');
      await file.writeAsBytes(imageData!);
      setState(() {
        _statusText = 'Image saved successfully';
      });
    } else {
      // Permission was denied, show an error message or handle accordingly
      setState(() {
        _statusText = 'Permission denied to save image';
      });
    }
  }

  _saveAsPdf(Uint8List? imageData) async {
    var status = await Permission.storage.status;
    status = await Permission.storage.request();
    // if (!status.isGranted) {
    //   // Permission has not been granted, request it
    //   status = await Permission.storage.request();
    // }
    if (true) {
      status = await Permission.storage.request();
      // Permission has been granted, proceed to save the PDF
      final pdf = pdfWidgets.Document();
      final image = img.decodeImage(imageData!);
      final pdfImage = pdfWidgets.MemoryImage(imageData);

      pdf.addPage(pdfWidgets.Page(
        build: (pdfWidgets.Context context) {
          return pdfWidgets.Center(
            child: pdfWidgets.Image(pdfImage),
          );
        },
      ));

      // Use file picker to let the user choose the save location
      final filePath = await FilePicker.platform.getDirectoryPath();

      if (filePath != null) {
        final directory = await getExternalStorageDirectory();
        // final path = directory!.path;
        final path = filePath;
        final externalDirectory = await Directory(path).create();
        final file = File('${externalDirectory.path}/omr_sheet.pdf');

        setState(() {
          _statusText = 'PDF saved successfully {$file}}';
        });
      } else {
        // User canceled file picker or an error occurred
        setState(() {
          _statusText = 'Failed to choose a save location';
        });
      }
    }
  }
}
