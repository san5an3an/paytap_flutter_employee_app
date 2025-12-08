import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paytap_app/common/utils/query_state.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/textarea/textarea.dart';

class TextareaModal extends StatefulWidget {
  const TextareaModal({super.key});

  @override
  State<TextareaModal> createState() => _TextareaModalState();
}

class _TextareaModalState extends State<TextareaModal> {
  QueryState queryState = QueryState({"title": '', 'content': ''});
  int valueLength = 0;
  FocusNode textFocus = FocusNode();
  final TextEditingController _textController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleChangeContent(String? value) {
    setState(() {
      queryState.onChangeQuery('context', value);
      valueLength = value?.length ?? 0;
    });
  }

  void onTapSave() {
    // 문의하기 API 호출
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height - 40,
      padding: EdgeInsets.fromLTRB(15, 15, 15, keyboardHeight),
      decoration: BoxDecoration(
        color: GlobalColor.bk08,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xf0000000).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            '문의하기',
                            style: GlobalTextStyle.body01.copyWith(
                              color: GlobalColor.bk01,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SvgPicture.asset('assets/icons/i_close.svg'),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onTapSave,
                      child: Text(
                        '작성완료',
                        style: GlobalTextStyle.body02.copyWith(
                          color: GlobalColor.brand01,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 50,
                    height: 50,
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _textController,
                      focusNode: textFocus,
                      onTapOutside: (event) {
                        textFocus.unfocus();
                      },
                      onSubmitted: (value) {},
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '문의 제목을 입력해주세요.',
                        hintStyle: GlobalTextStyle.body01.copyWith(
                          color: GlobalColor.bk03,
                        ),
                        errorBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _textController.text = '';
                    },
                    child: SvgPicture.asset('assets/icons/i_Erase.svg'),
                  ),
                ],
              ),
              SizedBox(
                child: Container(
                  width: double.infinity,
                  height: 1,
                  decoration: BoxDecoration(color: GlobalColor.bk06),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Textarea(
                        value: queryState['content'],
                        onChange: _handleChangeContent,
                        placeholder: '문의 내용을 입력해주세요.',
                        maxLength: 1000,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width, // 화면의 전체 너비 사용
              color: Colors.white, // 배경색을 흰색으로 설정
              padding: const EdgeInsets.all(8.0), // 텍스트 주변에 약간의 패딩 추가
              child: Text(
                '$valueLength / ${1000}자',
                style: GlobalTextStyle.small01.copyWith(
                  color: GlobalColor.bk03,
                ),
                textAlign: TextAlign.right, // 텍스트를 오른쪽으로 정렬
              ),
            ),
          ),
        ],
      ),
    );
  }
}
