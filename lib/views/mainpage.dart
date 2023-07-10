import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:omr_project/views/resultscreen.dart';
import 'package:omr_project/views/examscreen.dart';
import 'package:omr_project/views/studentcreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String httpAddress = '';
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController httpAddressController = TextEditingController();

  @override
  void dispose() {
    httpAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Organisations')
          .where('Admin_Email', isEqualTo: currentUser?.email)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While data is being fetched, show a loading indicator
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          // If an error occurs, display an error message
          return const Text("Something went wrong");
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // If there is no data available, display a message
          return const Text("No data found");
        }

        if (snapshot.connectionState == ConnectionState.active) {
          final DocumentSnapshot document = snapshot.data!.docs.first;
          final Map<String, dynamic> data =
              document.data() as Map<String, dynamic>;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.indigo.shade900,
              title: const Text(
                'Main Page',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    color: Colors.white,
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                },
              ),
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade900,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['Admin_Name'] ?? 'No name',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          data['Admin_Email'] ?? 'No email',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.assignment),
                    title: const Text('Exams'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExamsScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.school),
                    title: const Text('Teacher'),
                    onTap: () {
                      Navigator.of(context).pop(); // Closes the drawer
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Students'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: const Text('Results'),
                    onTap: () {
                      Navigator.pop(context); // Closes the drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.mail),
                    title: const Text('Contact Us'),
                    onTap: () {
                      Navigator.of(context).pop(); // Closes the drawer
                    },
                  ),
                  const Divider(), // Adds a horizontal line separator
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.of(context).pop(); // Closes the drawer
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Log Out'),
                    onTap: () {
                      Navigator.pop(context); // Closes the drawer
                      showLogoutConfirmationDialog(
                          context); // Show log out confirmation dialog
                    },
                  ),
                ],
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: httpAddressController,
                    decoration: InputDecoration(
                      labelText: 'Enter HTTP Server Address',
                    ),
                  ),
                  ElevatedButton(
                    child: Text('Save'),
                    onPressed: () {
                      setState(() {
                        httpAddress = httpAddressController.text;
                      });
                      print('Saved HTTP address: $httpAddress');
                    },
                  ),
                  Text('Welcome to the main page!'),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ); // Show loading indicator while fetching data
      },
    );
  }

  void showLogoutConfirmationDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Log Out'),
              onPressed: () async {
                Navigator.of(context).pop();
                logout();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login/',
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void logout() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      await auth.signOut();
      print('User logged out successfully');
    } catch (e) {
      print('Error occurred while logging out: $e');
    }
  }
}
