import 'package:books_app/utils/device_util.dart';
import 'package:flutter/material.dart';

class BookWidget extends StatefulWidget {
  BookWidget({Key? key}) : super(key: key);

  @override
  _BookWidgetState createState() => _BookWidgetState();
}

class _BookWidgetState extends State<BookWidget> with TickerProviderStateMixin {
  late AnimationController bookYAxisController;
  late Animation<double> bookYAnimation;

  @override
  void initState() {
    super.initState();
    bookYAxisController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));

    bookYAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: bookYAxisController, curve: Curves.easeInOutCirc),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (bookYAnimation.isDismissed) {
          bookYAxisController.forward();
        } else {
          bookYAxisController.reverse();
        }
      },
      child: Container(
          child: AnimatedBuilder(
              animation: bookYAnimation,
              builder: (context, snapshot) {
                return _BookWidget(
                  coverWidth: Device.width * 0.5,
                  spineWidth: 50,
                  coverAnimationValue: bookYAnimation.value,
                );
              })),
    );
  }
}

class _BookWidget extends StatelessWidget {
  const _BookWidget({
    Key? key,
    required this.spineWidth,
    required this.coverWidth,
    this.aspectRatio = 1.5,
    this.coverAnimationValue = 0.0,
  }) : super(key: key);

  final double spineWidth;
  final double coverWidth;
  final double aspectRatio;
  final double coverAnimationValue;

  double get bookHeight => coverWidth * 1.5;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        transformYAxis(
          alignment: Alignment.centerRight,
          axisValue: computeSpineYAxisValue(),
          child: _BookSpine(spineWidth: spineWidth, bookHeight: bookHeight),
        ),
        transformYAxis(
            alignment: Alignment.centerLeft,
            axisValue: computeCoverYAxisValue(),
            child: _BookCover(coverWidth: coverWidth, bookHeight: bookHeight))
      ],
      mainAxisSize: MainAxisSize.min,
    );
  }

  double computeSpineYAxisValue() {
    return coverAnimationValue * 1.57;
  }

  double computeCoverYAxisValue() {
    return -1.57 - (coverAnimationValue * -1.57);
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
