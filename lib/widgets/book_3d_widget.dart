import 'package:books_app/utils/multi_listener_util.dart';
import 'package:flutter/material.dart';

class Book3D extends StatefulWidget {
  Book3D({Key? key, required this.width, required this.spineWidth})
      : super(key: key);

  final double width;
  final double spineWidth;

  @override
  _Book3DState createState() => _Book3DState();
}

class _Book3DState extends State<Book3D> with TickerProviderStateMixin {
  late AnimationController bookYAxisController;
  late Animation<double> bookYAnimation;

  late AnimationController coverYAxisController;
  late Animation<double> coverYAnimation;

  @override
  void initState() {
    super.initState();
    bookYAxisController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));

    bookYAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: bookYAxisController, curve: Curves.easeInOutCirc),
    );

    coverYAxisController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));

    coverYAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: coverYAxisController, curve: Curves.easeInOutCirc),
    );
  }

  double get coverWidth => widget.width;
  double get spineWidth => widget.spineWidth;
  double get containerWidth => spineWidth + (coverWidth * bookYAnimation.value);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        if (coverYAnimation.isDismissed) {
          coverYAxisController.forward();
        } else {
          coverYAxisController.reverse();
        }
      },
      onTap: () {
        if (bookYAnimation.isDismissed) {
          bookYAxisController.forward();
        } else {
          bookYAxisController.reverse();
        }
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: AnimatedBuilder(
          animation: MultiListener(
            firstListener: bookYAnimation,
            secondListener: coverYAnimation,
          ),
          builder: (context, snapshot) {
            return Container(
              margin: marginCenterFixer(),
              width: containerWidth,
              child: SingleChildScrollView(
                child: _BookWidget(
                  coverWidth: coverWidth,
                  spineWidth: spineWidth,
                  bookAnimationValue: bookYAnimation.value,
                  coverAnimationValue: coverYAnimation.value,
                ),
                scrollDirection: Axis.horizontal,
                physics: NeverScrollableScrollPhysics(),
              ),
            );
          }),
    );
  }

  EdgeInsets marginCenterFixer() {
    return EdgeInsets.only(right: spineWidth * bookYAnimation.value);
  }
}

class _BookWidget extends StatelessWidget {
  const _BookWidget({
    Key? key,
    required this.spineWidth,
    required this.coverWidth,
    this.aspectRatio = 1.5,
    this.bookAnimationValue = 0.0,
    this.coverAnimationValue = 0.0,
  }) : super(key: key);

  final double spineWidth;
  final double coverWidth;
  final double aspectRatio;
  final double bookAnimationValue;
  final double coverAnimationValue;

  double get bookHeight => coverWidth * aspectRatio;

  double get bookYAngleAplitude => 1.57;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        transformYAxis(
          alignment: Alignment.centerRight,
          axisValue: computeSpineYAxisValue(),
          child: _BookSpine(spineWidth: spineWidth, bookHeight: bookHeight),
        ),
        Stack(
          fit: StackFit.loose,
          children: [
            Offstage(
              offstage: coverAnimationValue == 0.0,
              child: _BookPages(coverWidth: coverWidth, bookHeight: bookHeight),
            ),
            transformYAxis(
                alignment: Alignment.centerLeft,
                axisValue:
                    computeCoverYAxisValue() + computeCoverOpenAnimation(),
                child:
                    _BookCover(coverWidth: coverWidth, bookHeight: bookHeight)),
          ],
        )
      ],
      mainAxisSize: MainAxisSize.min,
    );
  }

  double computeSpineYAxisValue() {
    return bookAnimationValue * bookYAngleAplitude;
  }

  double computeCoverYAxisValue() {
    final coverAngleValue = (0.0 - bookYAngleAplitude);
    return coverAngleValue - (bookAnimationValue * coverAngleValue);
  }

  double computeCoverOpenAnimation() {
    final openCoverValue = bookYAngleAplitude * 2;
    return openCoverValue * coverAnimationValue;
  }

  Widget transformYAxis({
    required double axisValue,
    required Widget child,
    AlignmentGeometry alignment = Alignment.center,
  }) {
    return Transform(
      alignment: alignment,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(axisValue),
      child: child,
    );
  }
}

class _BookPages extends StatelessWidget {
  const _BookPages({
    Key? key,
    required this.coverWidth,
    required this.bookHeight,
  }) : super(key: key);

  final double coverWidth;
  final double bookHeight;

  double get pageWidth => coverWidth * 0.97;
  double get pageHeight => bookHeight * 0.98;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        width: pageWidth,
        height: pageHeight,
        color: Colors.white,
      ),
      alignment: Alignment.centerLeft,
      width: coverWidth,
      height: bookHeight,
      decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(2.5),
            bottomRight: Radius.circular(2.5),
          )),
    );
  }
}

class _BookSpine extends StatelessWidget {
  const _BookSpine({
    Key? key,
    required this.spineWidth,
    required this.bookHeight,
  }) : super(key: key);

  final double spineWidth;
  final double bookHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: spineWidth,
      height: bookHeight,
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({
    Key? key,
    required this.coverWidth,
    required this.bookHeight,
  }) : super(key: key);

  final double coverWidth;
  final double bookHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: coverWidth,
      height: bookHeight,
      decoration: BoxDecoration(
          color: Colors.lightBlue,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(2.5),
            bottomRight: Radius.circular(2.5),
          )),
    );
  }
}
