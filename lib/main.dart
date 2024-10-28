import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:provider/provider.dart';
import 'package:study_buddy/locator.dart';
import 'package:study_buddy/service/auth_service.dart';
import 'package:study_buddy/service/provider/auth_provider.dart';
import 'package:study_buddy/views/mentor/mtMainScreen.dart';
import 'package:study_buddy/views/student/mainscreen.dart';
import 'package:study_buddy/views/welcomepage.dart';
import 'package:study_buddy/service/provider/theme_provider.dart';
import 'package:study_buddy/views/student/onBoarding.dart';

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
              // Kullanıcı oturum açmışsa, rolünü kontrol et
              return FutureBuilder<String?>(
                future: AuthService().getUserRole(),
                builder: (context, roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (roleSnapshot.hasData) {
                    final role = roleSnapshot.data;
                    if (role == 'mentor') {
                      // Eğer kullanıcı mentor ise, MtMainScreen'e yönlendir
                      return const MtMainScreen();
                    } else if (role == 'student') {
                      // Eğer kullanıcı öğrenci ise, onboarding durumunu kontrol et
                      return FutureBuilder<bool>(
                        future: AuthService().checkIfUserCompletedOnboarding(),
                        builder: (context, onboardingSnapshot) {
                          if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (onboardingSnapshot.hasData && !onboardingSnapshot.data!) {
                            // Öğrenci onboarding'i tamamlamadıysa, OnboardingScreen göster
                            return OnboardingScreen(onCompleted: () {
                              AuthService().completeOnboarding();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const MainScreen()),
                              );
                            });
                          } else {
                            // Öğrenci onboarding'i tamamladıysa, MainScreen göster
                            return const MainScreen();
                          }
                        },
                      );
                    } else {
                      // Eğer rol bilinmiyorsa veya null ise, WelcomePage göster
                      return const WelcomePage();
                    }
                  } else {
                    // Eğer rol alınamazsa, WelcomePage göster
                    return const WelcomePage();
                  }
                },
              );
            } else {
              // Kullanıcı oturum açmamışsa, WelcomePage göster
              return const WelcomePage();
            }
          },
        ),
      ),
    );
  }
}
