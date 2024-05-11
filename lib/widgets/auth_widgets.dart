import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

Widget actionButton(String title, {Function()? onTap}) {
  return ElevatedButton(
    onPressed: () {
      if (onTap != null) {
        onTap();
      }
    },
    style: ElevatedButton.styleFrom(
        elevation: 0,
        textStyle: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Satoshi'),
        backgroundColor: const Color(0xff936ffc),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16)),
    child: FadeInUp(
      delay: const Duration(milliseconds: 700),
      duration: const Duration(milliseconds: 800),
      child: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
    ),
  );
}

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isFocused;
  final FocusNode focusNode;
  final String labelText;
  final IconData? suffixIcon; // Nullable hale getirildi
  final Duration fadeInDelay;
  final Duration fadeInDuration;

  const InputField({
    super.key,
    required this.controller,
    required this.isFocused,
    required this.focusNode,
    required this.labelText,
    this.suffixIcon, // Nullable
    required this.fadeInDelay,
    required this.fadeInDuration,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: fadeInDelay,
      duration: fadeInDuration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 0.8.h),
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: .3.h),
            decoration: BoxDecoration(
              color: isFocused ? Colors.white : const Color(0xFFF1F0F5),
              border: Border.all(width: 1, color: const Color(0xffd2d2d4)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (isFocused)
                  BoxShadow(
                    color: const Color(0xff936ffc).withOpacity(.3),
                    blurRadius: 4.0,
                    spreadRadius: 2.0,
                  )
              ],
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                suffixIcon: suffixIcon != null
                    ? Icon(
                        suffixIcon,
                        color: Colors.grey,
                        size: 16,
                      )
                    : null, // Nullable olduğu için kontrol ediyoruz
                border: InputBorder.none,
              ),
              focusNode: focusNode,
            ),
          ),
        ],
      ),
    );
  }
}

Widget orDivider() {
  return const Padding(
    padding: EdgeInsets.symmetric(horizontal: 130, vertical: 8),
    child: Row(
      children: [
        orDividerFlexible(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ya da',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        orDividerFlexible(),
      ],
    ),
  );
}

class orDividerFlexible extends StatelessWidget {
  const orDividerFlexible({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        height: 1,
        color: Colors.purple,
      ),
    );
  }
}

Widget myColumnWidget(List<Widget> content) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: content,
  );
}
