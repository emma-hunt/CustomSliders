import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

enum Side {
  left,
  right
}

class CurvedSlider extends StatefulWidget {
  final ValueChanged<Map> onChanged;
  final ValueChanged<Map> onActive;
  final ValueChanged<Map> onInactive;
  final double startValue;
  final double endValue;
  final double minorRad;
  final double majorRad;
  final int numThumbs;
  final Side side;


  // constructor override
  CurvedSlider ({
    @required this.minorRad,
    @required this.majorRad,
    @required this.startValue,
    @required this.endValue,
    @required this.side,
    this.numThumbs,
    this.onChanged,
    this.onActive,
    this.onInactive,
  });

  @override
  _CurvedSliderState createState() => _CurvedSliderState();

}

class Thumb {
  double x;
  double y;
  bool isActive = false;

  Thumb({
    @required this.x,
    @required this.y,
    this.isActive
  });
}

class _CurvedSliderState extends State<CurvedSlider> {
  double fingerX = 0.0;
  double fingerY = 0.0;
  double thumbRadius = 15.0;
  bool isSliderActive = false;
  List<Thumb> thumbs = [new Thumb(x: 0, y: 0, isActive: false)];

  @override
  initState() {
    super.initState();
    thumbs = new List(widget.numThumbs);

    //just gunna start at 45 degrees
    double r = (widget.minorRad * widget.majorRad) / sqrt(pow(widget.minorRad,2)*pow(sin(pi/4),2) + pow(widget.majorRad,2)*pow(cos(pi/4),2));
    double xLoc = r * cos(pi/4);
    if(widget.side == Side.right) {
      //flip it
      xLoc = 240 - xLoc;
    }
    double yLoc = r * sin(pi/4) + Scaffold.of(this.context).appBarMaxHeight;
    //double yLoc = MediaQuery.of(this.context).size.height;
    //double xLoc = widget.minorRad;
    for (int i = 0; i < widget.numThumbs; i++){
      thumbs[i] = new Thumb(x: xLoc, y: yLoc, isActive: false);
      //print(yLoc);
      //xLoc = xLoc + spaceing;
    }
  }

  void _placeThumbs() {
    for (int i = 0; i < widget.numThumbs; i++){
      if(thumbs[i].x == 0 && thumbs[i].y == 0) {
        print("HERE");
        double r = (widget.minorRad * widget.majorRad) / sqrt(pow(widget.minorRad,2)*pow(sin(pi/4),2) + pow(widget.majorRad,2)*pow(cos(pi/4),2));
        double xLoc = r * cos(pi/4);
        if(widget.side == Side.right) {
          //flip it
          xLoc = xLoc - MediaQuery.of(this.context).size.width;
        }
        double yLoc = r * sin(pi/4);
        thumbs[i].x = xLoc;
        thumbs[i].y = yLoc;
      }
    }
  }

  // interpolates from actual thumb position to value in user specified coordinate system

  double _interpolateValue(double sliderValue) {
    final RenderBox box = this.context.findRenderObject();
    var sliderMax = box.size.width;
    return (sliderValue * ((widget.endValue+1 - widget.startValue)/sliderMax)) + widget.startValue;
  }

  double _convertXtoEllipse(double screenX){
    //left
    if (widget.side == Side.left) {
      return screenX;
    }
    else {
      final RenderBox box = this.context.findRenderObject();
      var width = box.size.width;
      return width - screenX;
    }
  }

  double _convertYtoEllipse(double screenY) {
    //left
    final RenderBox box = this.context.findRenderObject();
    var height = box.size.height;
    return height - screenY;
  }

  double _convertXtoScreen(double ellipseX) {
    if (widget.side == Side.left) {
      return ellipseX;
    }
    else {
      final RenderBox box = this.context.findRenderObject();
      var width = box.size.width;
      return width - ellipseX;
    }
  }

  double _convertYtoScreen(double ellipseY) {
    //left or right
    final RenderBox box = this.context.findRenderObject();
    var height = box.size.height;
    return height - ellipseY;
  }

  Tuple2 calculateThumbCoordinates(double screenX, double screenY) {
    double x = _convertXtoEllipse(screenX);
    double y = _convertYtoEllipse(screenY);
    double angle = atan(y/x);
    double radius = (widget.minorRad * widget.majorRad) / sqrt(pow(widget.minorRad,2)*pow(sin(angle),2) + pow(widget.majorRad,2)*pow(cos(angle),2));
    double xThumb = radius * cos(angle);
    double yThumb = radius * sin(angle);
    return Tuple2(_convertXtoScreen(xThumb), _convertYtoScreen(yThumb));
  }

  void _processFingerInput (int index, PointerEvent details) {
    setState(() {
      //print("in process finger input");
      fingerX = details.localPosition.dx;
      fingerY = details.localPosition.dy;

      // math to keep your thumb on the line
      Tuple2 thumbXY = calculateThumbCoordinates(fingerX, fingerY);
      thumbs[index].x = thumbXY.item1;
      thumbs[index].y = thumbXY.item2;

      //reporting
      Map thumbInfo = new Map<double, bool>();
      for (Thumb thumb in thumbs){
        thumbInfo[_interpolateValue(thumb.x)] = thumb.isActive;
      }
      // sort the map??
      widget.onChanged(thumbInfo); // this is how we report
    });
  }

  void _processFingerDown(int index) {
    //print(thumbs.toString());
    setState(() {
      isSliderActive = true;
      thumbs[index].isActive = true;
      Map thumbInfo = new Map<double, bool>();
      for (Thumb thumb in thumbs){
        thumbInfo[_interpolateValue(thumb.x)] = thumb.isActive;
      }
      widget.onActive(thumbInfo);
    });
    //print(thumbs.toString());
  }

  void _processFingerUp(int index) {
    setState(() {
      isSliderActive = false;
      thumbs[index].isActive = false;
      print(thumbs[index].x);
      Map thumbInfo = new Map<double, bool>();
      for (Thumb thumb in thumbs){
        thumbInfo[_interpolateValue(thumb.x)] = thumb.isActive;
      }
      widget.onInactive(thumbInfo);
    });
  }

  void _fingerDown (PointerEvent details) {
    for(int i = 0; i < thumbs.length; i++) {
      if((details.localPosition.dx - thumbs[i].x).abs() < 10) {
        //there was a collision
        _processFingerDown(i);
        _processFingerInput (i, details);
        return;
      }
    }
  }

  void _fingerMove (PointerEvent details) {
    if(isSliderActive){
      for (int i = 0; i < thumbs.length; i++) {
        if (thumbs[i].isActive) {
          //print("finger " + i.toString());
          _processFingerInput (i, details);
          return;
        }
      }
    }
  }

  void _fingerUp (PointerEvent details) {
    if (isSliderActive) {
      for (int i = 0; i < thumbs.length; i++) {
        if (thumbs[i].isActive) {
          _processFingerUp(i);
          return;
        }
      }
    }
  }

  // build is called every time setState is
  Widget build(BuildContext context) {
    //_placeThumbs();
    return
      Container (
        width: double.infinity,
        height: 346,
        color: Colors.white,
        child: Listener ( // custom listeners
            onPointerDown: _fingerDown,
            onPointerMove: _fingerMove,
            onPointerUp: _fingerUp,
            child: CustomPaint ( // custom painter
              painter: CurvedSliderPainter(widget.minorRad, widget.majorRad, thumbRadius, thumbs, widget.side),
            )
        ),
      );
  }
}

class CurvedSliderPainter extends CustomPainter {
  double _thumbRad;
  double _minorRad;
  double _majorRad;
  List<Thumb> _thumbs;
  Side _side;

  CurvedSliderPainter(this._minorRad, this._majorRad, this._thumbRad, this._thumbs, this._side);

  Color _convertLocToCol(double position, bool isActive, Size size) {
    double p = position/size.width;
    Color rawColor = Color.lerp(Colors.deepPurple, Colors.cyan, p);
    if (isActive) {
      return Color.fromRGBO(rawColor.red, rawColor.green, rawColor.blue, 1.0);
    }
    else {
      return Color.fromRGBO(rawColor.red, rawColor.green, rawColor.blue, 0.5);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    //print("PAINTING");
    var linePen = Paint();

    double middleLocation = size.height/2;
    double centerLocation = size.width/2;

    Paint paint = Paint();
    paint.color = Colors.grey;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;

    Path path = Path();

    if(_side == Side.left){
      path.moveTo(-_minorRad, 0);
      path.arcTo(Rect.fromLTWH(-_minorRad, size.height-_majorRad, _minorRad*2, _majorRad*2), 0, -pi/2, true);

    }
    else {
      //right
      path.moveTo(size.width - _minorRad, size.height);
      path.arcTo(Rect.fromLTWH(size.width-_minorRad, size.height-_majorRad, _minorRad*2, _majorRad*2), 2*pi/2, pi/2, true);
    }
    canvas.drawPath(path, paint);

    //draw thumbs
    if(_thumbs != null) {
      for (Thumb thumb in _thumbs) {
        var backgroundPen = Paint();
        backgroundPen.style = PaintingStyle.fill;
        backgroundPen.color = Colors.white;
        canvas.drawCircle(Offset(thumb.x, thumb.y), _thumbRad, backgroundPen);
      }
      for (Thumb thumb in _thumbs) {
        var thumbPen = Paint();
        thumbPen.style = PaintingStyle.fill;
        thumbPen.color = _convertLocToCol(thumb.x, thumb.isActive, size);
        canvas.drawCircle(Offset(thumb.x, thumb.y), _thumbRad, thumbPen);
      }
    }
  }

  @override
  bool shouldRepaint(CurvedSliderPainter oldDelegate) {
    // returns true if field has changed from oldDelegate
    if(oldDelegate._minorRad != _minorRad || oldDelegate._majorRad != _majorRad || oldDelegate._side != _side) {
      //arch has changed, recalculate thumb positions
    }
    return true;
//    if (oldDelegate._radius != _radius) {
//      return true;
//    }
//    for(int i = 0; i < _thumbs.length; i++) {
//      Thumb old = oldDelegate._thumbs[i];
//      Thumb upd = _thumbs[i];
//      if(old.isActive != upd.isActive || old.x != upd.x) {
//        return true;
//      }
//    }
//    return false;
  }

}
