// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:omr_project/views/login_view.dart';
// import 'package:omr_project/views/register_view.dart';
// import 'package:omr_project/views/verifyemailview.dart';
// import 'package:omr_project/views/mainpage.dart';
// import 'firebase_options.dart';

// void main() {
//   runApp(
//     MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       // home: const RegisterView(),
//       home: const HomePage(),
//       routes: {
//         '/login/': (context) => const LoginView(),
//         '/register/': (context) => const RegisterView(),
//         '/verifyemail/': (context) => const VerifyEmailView(),
//         '/mainpage/': (context) => const MainPage(),

//       },
//     ),
//   );
// }

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future: Firebase.initializeApp(
//             options: DefaultFirebaseOptions.currentPlatform),
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.done:
//               final user = FirebaseAuth.instance.currentUser;
//               if (user != null) {
//                 if (user.emailVerified) {
//                   return const MainPage();
//                   // return const Text("Email is verified!");
//                 } else {
//                   return const MainPage();

//                   // return const VerifyEmailView();
//                 }
//               } else {
//                 return const LoginView();
//               }
//             default:
//               return const CircularProgressIndicator();
//           }
//         });
//   }
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:omr_project/views/login_view.dart';
import 'package:omr_project/views/register_view.dart';
import 'package:omr_project/views/verifyemailview.dart';
import 'package:omr_project/views/mainpage.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const RegisterView(),
      home: const HomePage(),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
        '/verifyemail/': (context) => const VerifyEmailView(),
        '/mainpage/': (context) => MainPage(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.value(true),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                if (user.emailVerified) {
                  return MainPage();
                } else {
                  return MainPage();
                }
              } else {
                return const LoginView();
              }
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}
