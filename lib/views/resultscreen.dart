import 'mainpage.dart' as mainpage_data;
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  runApp(MainPage());
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Page',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Main Page'),
        ),
        body: Center(
          child: Text('This is the main page'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ResultScreen()),
            );
          },
          child: Icon(Icons.assignment),
        ),
      ),
    );
  }
}

class ResultScreen extends StatefulWidget {
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
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
          'Results',
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScanSheet(
                            examName: exams[i].data()['Exam Name'] ?? 'N/A')),
                  );
                },
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          exams[i].data()['Exam Name'] ??
                              'N/A', // Replace with your actual exam name fiel
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
            ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => ScanSheet()),
      //     );
      //   },
      //   child: Icon(Icons.scanner),
      // ),
    );
  }
}

class ScanSheet extends StatefulWidget {
  final String examName;
  ScanSheet({required this.examName});
  @override
  _ScanSheetState createState() => _ScanSheetState();
}

class _ScanSheetState extends State<ScanSheet> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final cameraPermissionStatus = await Permission.camera.request();

    if (cameraPermissionStatus.isGranted) {
      _initializeCamera();
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Camera Permission'),
          content: Text(
              'Camera permissions have been denied. Please enable them in settings.'),
          actions: <Widget>[
            FloatingActionButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(ctx).pop();
              },
              child: Text('Open Settings'),
            ),
            FloatingActionButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    setState(() {
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.max,
      );

      _initializeControllerFuture = _controller!.initialize();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

Future<void> _captureImage() async {
  if (_controller != null && _controller!.value.isInitialized) {
    final image = await _controller!.takePicture();

    // Use the image package for image manipulation
    final originalImage = img.decodeImage(await File(image.path).readAsBytes());

    if (originalImage != null) {
      // Define the area you want to crop using your viewfinder's bounds
      final x = (originalImage.width * 0.10).toInt();  // Replace these with your actual viewfinder bounds
      final y = (originalImage.height * 0.18).toInt();
      final width = (originalImage.width * 0.82).toInt();
      final height = (originalImage.height * 0.68).toInt();

      // Crop the image according to the defined area
      final croppedImage = img.copyCrop(originalImage, x, y, width, height);

      // Save the cropped image to the disk
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch;
      final capturedImageFile = File('${appDir.path}/captured_image_$fileName.jpg');
      await capturedImageFile.writeAsBytes(img.encodeJpg(croppedImage));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageDisplayPage(
            imagePath: capturedImageFile.path,
            examName: widget.examName,
          ),
        ),
      );
    } else {
      print('Failed to decode the image');
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Sheet'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.previewSize!.height,
                    height: _controller!.value.previewSize!.width,
                    child: CameraPreview(_controller!),
                  ),
                ),
                Image.asset(
                  'assets/viewfinder.png',
                  width: MediaQuery.of(context).size.width * 1.25,
                  height: MediaQuery.of(context).size.width * 1.25,
                  // print thesse values
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: _captureImage,
      ),
    );
  }
}

class ImageDisplayPage extends StatefulWidget {
  final String imagePath;
  final String examName;

  const ImageDisplayPage({required this.imagePath, required this.examName});

  @override
  _ImageDisplayPageState createState() => _ImageDisplayPageState();
}

class _ImageDisplayPageState extends State<ImageDisplayPage> {
  bool _isProcessing = false;

  Future<void> _generateResult() async {
    setState(() {
      _isProcessing = true;
    });
    print('Exam name at ImageDisplayPage: ${widget.examName}'); // Add this line

    var temp = mainpage_data.httpAddress;
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$temp/receive_omr_sheet'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', widget.imagePath),
      );
      request.fields['examName'] = widget.examName;
      request.fields['adminEmail'] = FirebaseAuth.instance.currentUser!.email!;

      final response = await request.send();

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Grading Done Successfully'),
              content: Text(
                  'Your results are ready. Please check the results page.'),
              actions: <Widget>[
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Add code to navigate back to the live camera preview here
                  },
                ),
              ],
            );
          },
        );
      } else if (response.statusCode == 400) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Image Not Received Successfully'),
              content: Text(
                  'Please retake the image and ensure all 4 corners of the sheet are visible.'),
              actions: <Widget>[
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Handle other status codes if needed
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _retakeImage() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Captured Image'),
      ),
      body: Center(
        child: Image.file(File(widget.imagePath)),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _isProcessing ? null : _generateResult,
            child: _isProcessing
                ? CircularProgressIndicator(color: Colors.white)
                : Icon(Icons.check),
            heroTag: "btn1",
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _isProcessing ? null : _retakeImage,
            child: Icon(Icons.camera_alt),
            heroTag: "btn2",
          ),
        ],
      ),
    );
  }
}
