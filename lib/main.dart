import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:provider/provider.dart';
import 'package:study_buddy/locator.dart';
import 'package:study_buddy/service/auth_service.dart';
import 'package:study_buddy/service/provider/auth_provider.dart';
import 'package:study_buddy/views/mainscreen.dart';
import 'package:study_buddy/views/welcomepage.dart';
import 'package:study_buddy/service/provider/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAbROYqdRJOnjis5nCQaZPh5NJlrDLTGNU",
          appId: "1:296037056963:android:ca4d28f19c1ce086d2bd76",
          messagingSenderId: "296037056963",
          projectId: "study-buddy-58b99"));
  setupLocator();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<SBAuthProvider>(
        create: (context) => locator.get<SBAuthProvider>(),
      ),
      ChangeNotifierProvider<ThemeProvider>(
        create: (context) => ThemeProvider(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    final themeProvider = Provider.of<ThemeProvider>(context);

    return FlutterSizer(
      builder: (context, orientation, deviceType) => MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: themeProvider.currentTheme,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: FutureBuilder<User?>(
          future: AuthService().getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              return const MainScreen();
            } else {
              return const WelcomePage();
            }
          },),
      ),
    );
  }
}