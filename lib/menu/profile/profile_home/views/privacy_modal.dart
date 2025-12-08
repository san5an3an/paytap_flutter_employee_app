import 'package:flutter/material.dart';
import 'package:paytap_app/common/widget/bottom_modal/bottom_modal.dart';

class PrivacyModal extends StatefulWidget {
  const PrivacyModal({super.key});

  @override
  State<PrivacyModal> createState() => _PrivacyModalState();
}

class _PrivacyModalState extends State<PrivacyModal> {
  @override
  Widget build(BuildContext context) {
    return BottomModal(content: []);
  }
}
