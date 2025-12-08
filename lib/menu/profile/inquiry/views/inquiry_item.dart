import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class InquiryItem extends StatefulWidget {
  final bool isRead;
  final bool isAnswer;

  const InquiryItem({super.key, this.isRead = false, this.isAnswer = true});

  @override
  State<InquiryItem> createState() => _InquiryItemState();
}

class _InquiryItemState extends State<InquiryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;
  bool isTap = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // 애니메이션 시간 조정
    );

    _sizeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut, // 부드러운 애니메이션
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onIconPressed() {
    setState(() {
      isTap = !isTap;
      if (isTap) {
        _animationController.forward(); // 펼쳐짐
      } else {
        _animationController.reverse(); // 닫힘
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onIconPressed, // 클릭 시 애니메이션 트리거
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), // Border 애니메이션 시간
        decoration: BoxDecoration(
          border: isTap
              ? Border.symmetric(
                  horizontal: BorderSide(color: GlobalColor.bk03, width: 1),
                )
              : Border.symmetric(
                  horizontal: BorderSide(color: Colors.transparent, width: 1),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _questionItem(),
            SizeTransition(
              sizeFactor: _sizeAnimation, // 위에서 아래로 펼쳐지는 애니메이션
              axisAlignment: -1.0, // 축 기준: 위에서 아래
              child: contentItem(), // 항상 child를 렌더링하고 애니메이션만 제어
            ),
          ],
        ),
      ),
    );
  }

  Widget _questionItem() {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: Row(
            children: [
              SvgPicture.asset('assets/icons/i_Question.svg'),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '문의 제목 (가나다라 마바사아) ',
                  overflow: TextOverflow.ellipsis,
                  style: GlobalTextStyle.body02.copyWith(
                    color: widget.isAnswer
                        ? GlobalColor.brand01
                        : GlobalColor.bk01,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 50,
                alignment: Alignment.centerRight,
                child: Text(
                  '1일 전',
                  style: GlobalTextStyle.small01.copyWith(
                    color: widget.isRead ? GlobalColor.bk03 : GlobalColor.bk01,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              AnimatedBuilder(
                animation: _sizeAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _sizeAnimation.value * 3.14159, // 0에서 180도 회전
                    child: SvgPicture.asset('assets/icons/i_Accordion.svg'),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget contentItem() {
    return Column(
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                '함께 타다 이제 때문 우수한, 자기다 있다. 것 있어 라디에이터를 되려 응 맺읍시다.',
                style: GlobalTextStyle.body02.copyWith(color: GlobalColor.bk03),
              ),
            ),
            const SizedBox(width: 30),
          ],
        ),
        SizedBox(
          height: 50,
          child: Row(
            children: [
              SvgPicture.asset('assets/icons/i_Answer.svg'),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '문의 제목 (가나다라 마바사아)',
                  overflow: TextOverflow.ellipsis,
                  style: GlobalTextStyle.body02.copyWith(
                    color: GlobalColor.bk01,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 50,
                alignment: Alignment.centerRight,
                child: Text(
                  '10일 전',
                  style: GlobalTextStyle.small01.copyWith(
                    color: widget.isRead ? GlobalColor.bk03 : GlobalColor.bk01,
                  ),
                ),
              ),
              const SizedBox(width: 30),
            ],
          ),
        ),
        Row(
          children: [
            Flexible(
              child: Text(
                '함께 타다 이제 때문 우수한, 자기다 있다. 것 있어 라디에이터를 되려 응 맺읍시다.',
                style: GlobalTextStyle.body02.copyWith(color: GlobalColor.bk03),
              ),
            ),
            const SizedBox(width: 30),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
