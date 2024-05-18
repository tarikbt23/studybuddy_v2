import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:provider/provider.dart';
import 'package:study_buddy/locator.dart';
import 'package:study_buddy/service/provider/auth_provider.dart';
import 'package:study_buddy/service/auth_service.dart';
import 'package:study_buddy/views/mainscreen.dart';
import 'package:study_buddy/views/welcomepage.dart';
import 'package:study_buddy/views/onBoarding.dart';

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
      ChangeNotifierProvider<AuthProvider>(
        create: (context) => locator.get<AuthProvider>(),
      )
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterSizer(
      builder: (context, orientation, deviceType) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Satoshi'),
        home: WelcomePage(), // Başlangıç sayfası WelcomePage olarak ayarlandı
      ),
    );
  }
}
