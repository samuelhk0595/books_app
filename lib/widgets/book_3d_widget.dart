import 'package:books_app/utils/multi_listener_util.dart';
import 'package:flutter/material.dart';

class Book3D extends StatefulWidget {
  Book3D({
    Key? key,
    required this.width,
    required this.spineWidth,
    this.coverImage,
    this.spineImage,
    this.backCoverImage,
    this.showCoverAtFirst = true,
  }) : super(key: key);

  final double width;
  final double spineWidth;
  final bool showCoverAtFirst;
  final ImageProvider? coverImage;
  final ImageProvider? spineImage;
  final ImageProvider? backCoverImage;

  @override
  _Book3DState createState() => _Book3DState();
}

class _Book3DState extends State<Book3D> with TickerProviderStateMixin {
  late AnimationController bookYAxisController;
  late Animation<double> bookYAnimation;

  late AnimationController coverYAxisController;
  late Animation<double> coverYAnimation;

  Offset bookDragStartPosition = Offset.zero;
  double bookDragStartAnimationValue = 0.0;
  double coverDragStartAnimationValue = 0.0;

  @override
  void initState() {
    super.initState();
    bookYAxisController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));

    bookYAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: bookYAxisController, curve: Curves.easeInOutCirc),
    );
    if (widget.showCoverAtFirst) bookYAxisController.value = 1.0;

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
    return GestureDetector(
      onTap: () {
        if (bookYAnimation.isDismissed) {
          bookYAxisController.forward();
        } else {
          bookYAxisController.reverse();
        }
      },
      onHorizontalDragStart: onHorizontalDragStart,
      onHorizontalDragEnd: onHorizontalDragEnd,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
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
                  coverImage: widget.coverImage,
                  spineImage: widget.spineImage,
                  backCoverImage: widget.backCoverImage,
                ),
                scrollDirection: Axis.horizontal,
                physics: NeverScrollableScrollPhysics(),
              ),
            );
          }),
    );
  }

  EdgeInsets marginCenterFixer() {
    return EdgeInsets.only(
        right: spineWidth * bookYAnimation.value,
        left: coverWidth * coverYAnimation.value);
  }

  void handleBookDrag(bool isDraggingRight, double dragValue) {
    if (isDraggingRight) {
      bookYAxisController.value = bookDragStartAnimationValue - dragValue;
    } else {
      bookYAxisController.value = bookDragStartAnimationValue + dragValue;
    }
  }

  void handleCoverDrag(bool isDraggingRight, double dragValue) {
    if (isDraggingRight) {
      coverYAxisController.value = coverDragStartAnimationValue - dragValue;
    } else {
      coverYAxisController.value = coverDragStartAnimationValue + dragValue;
    }
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    double dragValue;
    double distance;
    bool isDraggingRight;

    if (bookDragStartPosition.dx < details.localPosition.dx) {
      isDraggingRight = true;
      distance = details.localPosition.dx - bookDragStartPosition.dx;
    } else {
      isDraggingRight = false;
      distance = bookDragStartPosition.dx - details.localPosition.dx;
    }

    dragValue = distance / coverWidth;

    if (isDraggingRight) {
      if (coverYAnimation.value == 0.0) {
        handleBookDrag(isDraggingRight, dragValue);
      } else {
        handleCoverDrag(isDraggingRight, dragValue);
      }
    } else {
      if (bookYAnimation.value == 1.0) {
        handleCoverDrag(isDraggingRight, dragValue);
      } else {
        handleBookDrag(isDraggingRight, dragValue);
      }
    }
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    if (coverYAnimation.value != 0.0 && coverYAnimation.value != 1.0) {
      if (coverYAnimation.value < 0.5) {
        coverYAxisController.reverse();
      } else {
        coverYAxisController.forward();
      }
    } else if (bookYAnimation.value != 0.0 && bookYAnimation.value != 1.0) {
      if (bookYAnimation.value < 0.5) {
        bookYAxisController.reverse();
      } else {
        bookYAxisController.forward();
      }
    }
  }

  void onHorizontalDragStart(DragStartDetails details) {
    bookDragStartPosition = details.localPosition;
    bookDragStartAnimationValue = bookYAnimation.value;
    coverDragStartAnimationValue = coverYAnimation.value;
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
    this.coverImage,
    this.spineImage,
    this.backCoverImage,
  }) : super(key: key);

  final double spineWidth;
  final double coverWidth;
  final double aspectRatio;
  final double bookAnimationValue;
  final double coverAnimationValue;
  final ImageProvider? coverImage;
  final ImageProvider? spineImage;
  final ImageProvider? backCoverImage;

  double get bookHeight => coverWidth * aspectRatio;

  double get bookYAngleAplitude => 1.57;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        transformYAxis(
          alignment: Alignment.centerRight,
          axisValue: computeSpineYAxisValue(),
          child: _BookSpine(
            spineWidth: spineWidth,
            bookHeight: bookHeight,
            spineImage: spineImage,
          ),
        ),
        Stack(
          fit: StackFit.loose,
          children: [
            Offstage(
              offstage: coverAnimationValue == 0.0,
              child: _BookPages(
                coverWidth: coverWidth,
                bookHeight: bookHeight,
                backCoverImage: backCoverImage,
              ),
            ),
            transformYAxis(
                alignment: Alignment.centerLeft,
                axisValue:
                    computeCoverYAxisValue() + computeCoverOpenAnimation(),
                child: _BookCover(
                  coverWidth: coverWidth,
                  bookHeight: bookHeight,
                  coverImage: coverImage,
                )),
          ],
        )
      ],
      mainAxisSize: MainAxisSize.min,
    );
  }

  EdgeInsets marginCenterFixer() {
    return EdgeInsets.only(
        right: spineWidth * bookAnimationValue,
        left: coverWidth * coverAnimationValue);
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
    this.backCoverImage,
  }) : super(key: key);

  final double coverWidth;
  final double bookHeight;
  final ImageProvider? backCoverImage;

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
          image: backCoverImage == null
              ? null
              : DecorationImage(fit: BoxFit.fill, image: backCoverImage!),
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
    this.spineImage,
  }) : super(key: key);

  final double spineWidth;
  final double bookHeight;
  final ImageProvider? spineImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: spineWidth,
      height: bookHeight,
      decoration: BoxDecoration(
          color: Colors.blue,
          image: spineImage == null
              ? null
              : DecorationImage(fit: BoxFit.fill, image: spineImage!)),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({
    Key? key,
    required this.coverWidth,
    required this.bookHeight,
    this.coverImage,
  }) : super(key: key);

  final double coverWidth;
  final double bookHeight;
  final ImageProvider? coverImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: coverWidth,
      height: bookHeight,
      decoration: BoxDecoration(
          color: Colors.lightBlue,
          image: coverImage == null
              ? null
              : DecorationImage(fit: BoxFit.fill, image: coverImage!),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(2.5),
            bottomRight: Radius.circular(2.5),
          )),
    );
  }
}
