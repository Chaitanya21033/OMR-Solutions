import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _adminName;
  late final TextEditingController _adminEmail;
  late final TextEditingController _adminPassword;
  late final TextEditingController _id;
  late final TextEditingController _location;
  late final TextEditingController _name;

  @override
  void initState() {
    _adminName = TextEditingController();
    _adminEmail = TextEditingController();
    _adminPassword = TextEditingController();
    _id = TextEditingController();
    _location = TextEditingController();
    _name = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _adminName.dispose();
    _adminEmail.dispose();
    _adminPassword.dispose();
    _id.dispose();
    _location.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.indigo.shade900,
            title: const Text(
              'REGISTER',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _adminName,
                  decoration: const InputDecoration(
                    labelText: 'Admin Name',
                  ),
                ),
                TextField(
                  controller: _adminEmail,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Admin Email',
                  ),
                ),
                TextField(
                  controller: _adminPassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                TextField(
                  controller: _id,
                  decoration: const InputDecoration(
                    labelText: 'ID',
                  ),
                ),
                TextField(
                  controller: _location,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                  ),
                ),
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Name of Organisation',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final adminName = _adminName.text;
                    final adminEmail = _adminEmail.text;
                    final adminPassword = _adminPassword.text;
                    final id = _id.text;
                    final location = _location.text;
                    final name = _name.text;

                    try {
                      final userCredential = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: adminEmail,
                        password: adminPassword,
                      );

                      final user = userCredential.user;
                      if (user != null) {
                        // Send email verification
                        await user.sendEmailVerification();

                        // ignore: use_build_context_synchronously
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Verify your email'),
                              content: const Text(
                                'A verification email has been sent to your email. Please verify your email before continuing.',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Email Verified'),
                                  onPressed: () async {
                                    await user.reload();
                                    if (true) {
                                      // Create a reference to the Firestore collection 'Organisations'
                                      final organisationRef = FirebaseFirestore
                                          .instance
                                          .collection('Organisations');

                                      // Create a new document in the 'Organisations' collection with the user's UID as the document ID
                                      final organisationDoc =
                                          organisationRef.doc(user.uid);

                                      // Set the data for the organisation document
                                      await organisationDoc.set({
                                        'Admin_Name': adminName,
                                        'Admin_Email': adminEmail,
                                        'ID': id,
                                        'Location': location,
                                        'Name': name,
                                      });

                                      Navigator.of(context)
                                          .pop(); // Close the verification dialog

                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Registration Successful'),
                                            content: const Text(
                                                'You have been successfully registered.'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('OK'),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Close the registration success dialog
                                                  // Navigator.of(context).pushNamedAndRemoveUntil(
                                                  //   '/main/',
                                                  //   (route) => false,
                                                  // );
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      // ignore: dead_code
                                    } else {}
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      String errorMessage =
                          'An error occurred, please try again.';
                      if (e.code == 'email-already-in-use') {
                        errorMessage =
                            'The account already exists for that email.\n'
                            'Please try logging in instead.';
                      } else if (e.code == 'invalid-email') {
                        errorMessage = 'The email address is not valid.';
                      }

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Registration Error'),
                            content: Text(errorMessage),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text('Register'),
                ),
                TextButton(
                  onPressed: () {
                    // Navigator.of(context).pop();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login/',
                      (route) => false,
                    );
                  },
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
