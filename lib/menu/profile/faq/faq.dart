import 'package:flutter/material.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';

class Faq extends StatefulWidget {
  const Faq({super.key});

  @override
  State<Faq> createState() => _FaqState();
}

class _FaqState extends State<Faq> {
  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'FAQ',
      currentIdx: 2,
      children: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(children: []),
        ),
      ),
    );
  }
}
