import 'dart:math';

import 'package:flutter/material.dart';

class UnusableSlider extends StatefulWidget {
  final ValueChanged<Map> onChanged;
  final ValueChanged<Map> onActive;
  final ValueChanged<Map> onInactive;
  final double startValue;
  final double endValue;
  final int numThumbs = 1;

  // constructor override
  UnusableSlider ({
    @required this.startValue,
    @required this.endValue,
    this.onChanged,
    this.onActive,
    this.onInactive,
  });

  @override
  _UnusableSliderState createState() => _UnusableSliderState();

}

class Thumb {
  double current;
  double origin;
  double goal;
  bool isActive = false;

  Thumb({
    @required this.current,
    this.origin,
    this.goal,
    this.isActive,
  });
}

class _UnusableSliderState extends State<UnusableSlider> with TickerProviderStateMixin {
  double fingerX = 0.0;
  double fingerY = 0.0;
  double radius = 15.0;
  bool isSliderActive = false;
  Thumb thumb = new Thumb(current: 0, origin: 0, goal: 0, isActive: false);
  Animation<double> _animation;
  AnimationController controller;

  @override
  initState() {
    super.initState();
    //thumb = new List(widget.numThumbs);
//    final RenderBox box = this.context.findRenderObject();
//    var width = box.size.width;
    var width = 255;
    double xLoc = width/(widget.numThumbs+1);
    thumb = new Thumb(current: xLoc, origin: xLoc, goal: xLoc, isActive: false);

  }

  // interpolates from actual thumb position to value in user specified coordinate system

  double _interpolateValue(double sliderValue) {
    final RenderBox box = this.context.findRenderObject();
    var sliderMax = box.size.width;
    var correctValue = (sliderValue * ((widget.endValue+1 - widget.startValue)/sliderMax)) + widget.startValue;
    //reverse it
    return widget.endValue - correctValue;
  }

  void _processFingerInput (PointerEvent details) {
    setState(() {
      fingerX = details.localPosition.dx;
      fingerY = details.localPosition.dy;
      thumb.current = details.localPosition.dx;

      //reporting
      Map thumbInfo = new Map<double, bool>();
      thumbInfo[_interpolateValue(thumb.current)] = thumb.isActive;
      // sort the map??
      widget.onChanged(thumbInfo); // this is how we report
    });
  }

  void _processFingerDown() {
    print(thumb.toString());
    setState(() {
      isSliderActive = true;
      //thumbs[index].isActive = true;
      var rand = Random();
      // randomly choose to move right or left by a random amount
      var offset = 40 + rand.nextInt(60);
      thumb.origin = thumb.current;
      print("original position: " + thumb.origin.toString());
      print("rand offset: " + offset.toString());
      final RenderBox box = this.context.findRenderObject();
      var sliderMax = box.size.width;
      //move the thumb
      if (thumb.origin -offset < 0) {
        //must move right
        thumb.goal = thumb.origin + offset;
      }
      else if (thumb.origin + offset > sliderMax) {
        // must move left
        thumb.goal = thumb.origin - offset;
      }
      else {
        // move the direction of goRight boolean
        var goRight = rand.nextBool();
        if (goRight){
          thumb.goal = thumb.origin + offset;
        }
        else {
          thumb.goal = thumb.origin - offset;
        }
      }
      print("final position: " + thumb.goal.toString());
      controller = AnimationController(duration: Duration(milliseconds: 250), vsync: this);
      //controller.fling(velocity: 2);
      controller.forward();
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          //reset origin and goal
          //controller.reset();
          print("complete animation");
        }
//        else if (status == AnimationStatus.dismissed) {
//          print("animate!");
//          controller.forward();
//        }
      });
      //report only actual current value
      Map thumbInfo = new Map<double, bool>();
      thumbInfo[_interpolateValue(thumb.current)] = thumb.isActive;
      widget.onActive(thumbInfo);
    });
  }

  void _processFingerUp() {
    setState(() {
      isSliderActive = false;
      thumb.isActive = false;
      Map thumbInfo = new Map<double, bool>();
      thumbInfo[_interpolateValue(thumb.current)] = thumb.isActive;
      widget.onInactive(thumbInfo);
    });
  }

  void _fingerDown (PointerEvent details) {
    if((details.localPosition.dx - thumb.current).abs() < 10) {
      //there was a collision
      _processFingerDown();
      //_processFingerInput (i, details);
      return;
    }
  }

  void _fingerMove (PointerEvent details) {
    if(isSliderActive){
      if (thumb.isActive) {
        _processFingerInput (details);
        return;
      }
    }
  }

  void _fingerUp (PointerEvent details) {
    if (isSliderActive) {
      if (thumb.isActive) {
        _processFingerUp();
        return;
      }
    }
  }

  // build is called every time setState is
  Widget build(BuildContext context) {
    if(thumb.current != thumb.goal) {
      _animation = Tween(begin: thumb.origin, end: thumb.goal).chain(CurveTween(curve:Curves.ease))
          .animate(controller)
        ..addListener(() {
          setState(() {
            thumb.current = _animation.value;
            Map thumbInfo = new Map<double, bool>();
            thumbInfo[_interpolateValue(thumb.current)] = thumb.isActive;
            widget.onChanged(thumbInfo);
          });
        });
    }

    return
      Container (
        width: double.infinity,
        height: 100,
        color: Colors.white,
        child: Listener ( // custom listeners
            onPointerDown: _fingerDown,
            onPointerMove: _fingerMove,
            onPointerUp: _fingerUp,
            child: CustomPaint ( // custom painter
              painter: UnusableSliderPainter(radius, thumb),
            )
        ),
      );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class UnusableSliderPainter extends CustomPainter {
  double _radius;
  Thumb _thumb;

  UnusableSliderPainter(this._radius, this._thumb);

  Color convertLocToCol(double position, bool isActive, Size size) {
    double p = position/size.width;
    Color rawColor = Color.lerp(Colors.cyan, Colors.deepPurple, p);
    if (isActive) {
      return Color.fromRGBO(rawColor.red, rawColor.green, rawColor.blue, 1.0);
    }
    else {
      return Color.fromRGBO(rawColor.red, rawColor.green, rawColor.blue, 0.5);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    var linePen = Paint();

    double middleHeight = size.height/2;
    double middleWidth = size.width/2;

    //draw line
    linePen.color = Colors.grey;
    linePen.style = PaintingStyle.fill;
    canvas.drawLine(Offset(0, middleHeight), Offset(size.width, middleHeight), linePen);

    //draw thumbs
    if(_thumb != null) {
      var backgroundPen = Paint();
      backgroundPen.style = PaintingStyle.fill;
      backgroundPen.color = Colors.white;
      canvas.drawCircle(Offset(_thumb.current, middleHeight), _radius, backgroundPen);
      var thumbPen = Paint();
      thumbPen.style = PaintingStyle.fill;
      thumbPen.color = convertLocToCol(_thumb.current, _thumb.isActive, size);
      canvas.drawCircle(Offset(_thumb.current, middleHeight), _radius, thumbPen);
    }
    // draw the line all the way across the center of the canvas
  }

  @override
  bool shouldRepaint(UnusableSliderPainter oldDelegate) {
    // returns true if field has changed from oldDelegate
    return true;
    if (oldDelegate._radius != _radius) {
      return true;
    }
    if(oldDelegate._thumb.isActive != _thumb.isActive || oldDelegate._thumb.current != _thumb.current) {
      return true;
    }
    return false;
  }

}
