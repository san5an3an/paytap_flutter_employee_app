import 'package:flutter/material.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class Textarea extends StatefulWidget {
  final String value;
  final String name;
  final String placeholder;
  final int maxLength;
  final void Function(String? text) onChange;

  const Textarea({
    super.key,
    this.name = '',
    this.value = '',
    this.placeholder = '',
    required this.onChange,
    this.maxLength = 1000,
  });

  @override
  State<Textarea> createState() => _TextareaState();
}

class _TextareaState extends State<Textarea> {
  late TextEditingController _textController;
  FocusNode textFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.value);
    _textController.addListener(() {
      widget.onChange(_textController.text); // 부모 위젯으로 변경된 값을 전달
      setState(() {}); // 글자 수 갱신을 위해 setState 호출
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    textFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      color: GlobalColor.bk08, // 안보여서 색상 변경함 작업끝나고 bk08로 변경
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: GlobalTextStyle.body02.copyWith(
                    color: GlobalColor.bk01,
                  ),
                  controller: _textController,
                  focusNode: textFocus,
                  onTapOutside: (event) {
                    textFocus.unfocus();
                  },
                  maxLength: widget.maxLength,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: GlobalTextStyle.body02.copyWith(
                      color: GlobalColor.bk03,
                    ),
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
