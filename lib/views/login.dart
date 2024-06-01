import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:iconly/iconly.dart';
import 'package:study_buddy/service/auth_service.dart';
import 'package:study_buddy/views/register.dart';
import '../../widgets/auth_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _tEmail = TextEditingController();
  final _tPassword = TextEditingController();
  var focusNodeEmail = FocusNode();
  var focusNodePassword = FocusNode();
  bool isFocusedEmail = false;
  bool isFocusedPassword = false;

  @override
  void initState() {
    focusNodeEmail.addListener(() {
      setState(() {
        isFocusedEmail = focusNodeEmail.hasFocus;
      });
    });
    focusNodePassword.addListener(() {
      setState(() {
        isFocusedPassword = focusNodePassword.hasFocus;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              height: 100.h,
              decoration: const BoxDecoration(color: Colors.white),
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 5.h,
                  ),
                  FadeInDown(
                    delay: const Duration(milliseconds: 900),
                    duration: const Duration(milliseconds: 1000),
                    child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          IconlyBroken.arrow_left,
                          size: 3.6.h,
                        )),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInDown(
                        delay: const Duration(milliseconds: 800),
                        duration: const Duration(milliseconds: 900),
                        child: Text(
                          'Seni Görmek Güzel',
                          style: TextStyle(
                              fontSize: 25.sp, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      FadeInDown(
                        delay: const Duration(milliseconds: 700),
                        duration: const Duration(milliseconds: 800),
                        child: Text(
                          'StudyBuddy ile Buluşmak İçin Giriş Yap :)',
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  InputField(
                    controller: _tEmail,
                    isFocused: isFocusedEmail,
                    focusNode: focusNodeEmail,
                    labelText: 'Email',
                    fadeInDelay: const Duration(milliseconds: 600),
                    fadeInDuration: const Duration(milliseconds: 700),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  InputField(
                    controller: _tPassword,
                    isFocused: isFocusedPassword,
                    focusNode: focusNodePassword,
                    labelText: 'Şifre',
                    suffixIcon: Icons.visibility_off_outlined,
                    fadeInDelay: const Duration(milliseconds: 400),
                    fadeInDuration: const Duration(milliseconds: 500),
                  ),
                  const Expanded(
                      child: SizedBox(
                    height: 10,
                  )),
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    duration: const Duration(milliseconds: 700),
                    child: Row(
                      children: [
                        Expanded(
                            child: actionButton('Giriş Yap',
                                onTap: () => AuthService().signIn(context,
                                    email: _tEmail.text,
                                    password: _tPassword.text)))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    duration: const Duration(milliseconds: 700),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // OnPressed Logic
                            },
                            icon: Image.asset('assets/images/google.png'),
                            label: const Text("Google İle Giriş Yap"),
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Satoshi'),
                                backgroundColor: const Color(0xFFF1F0F5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10)),
                          ),
                        )
                      ],
                    ),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    duration: const Duration(milliseconds: 900),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Bir hesabın yok mu ?',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const RegisterPage()));
                            },
                            child: const Text('Kayıt ol',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 147, 111, 252),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }
}
