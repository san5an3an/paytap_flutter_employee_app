import 'package:flutter/material.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/menu/profile/inquiry/views/inquiry_item.dart';

class Inquiry extends StatefulWidget {
  const Inquiry({super.key});

  @override
  State<Inquiry> createState() => _InquiryState();
}

class _InquiryState extends State<Inquiry> {
  @override
  Widget build(BuildContext context) {
    return Layout(
      title: '문의 내역',
      currentIdx: 2,
      children: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 10),
              InquiryItem(),
              InquiryItem(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
