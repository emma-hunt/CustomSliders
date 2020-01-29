import 'package:flutter/material.dart';

class MultiThumbSlider extends StatefulWidget {
  final ValueChanged<Map> onChanged;
  final ValueChanged<Map> onActive;
  final ValueChanged<Map> onInactive;
  final double startValue;
  final double endValue;
  final int numThumbs;

  // constructor override
  MultiThumbSlider ({
    @required this.numThumbs,
    @required this.startValue,
    @required this.endValue,
    this.onChanged,
    this.onActive,
    this.onInactive,
  });

  @override
  _MultiThumbSliderState createState() => _MultiThumbSliderState();

}

class Thumb {
  double x;
  bool isActive = false;

  Thumb({
    @required this.x,
    this.isActive
  });
}

class _MultiThumbSliderState extends State<MultiThumbSlider> {
  double fingerX = 0.0;
  double fingerY = 0.0;
  double radius = 15.0;
  bool isSliderActive = false;
  List<Thumb> thumbs = [new Thumb(x: 0, isActive: false)];

  @override
  initState() {
    super.initState();
    thumbs = new List(widget.numThumbs);
//    final RenderBox box = this.context.findRenderObject();
//    var width = box.size.width;
    var width = 255;
    double spaceing = width/(widget.numThumbs+1);
    double xLoc = spaceing;
    for (int i = 0; i < widget.numThumbs; i++){
      thumbs[i] = new Thumb(x: xLoc, isActive: false);
      xLoc = xLoc + spaceing;
    }
  }

  // interpolates from actual thumb position to value in user specified coordinate system

  double _interpolateValue(double sliderValue) {
    final RenderBox box = this.context.findRenderObject();
    var sliderMax = box.size.width;
    return (sliderValue * ((widget.endValue+1 - widget.startValue)/sliderMax)) + widget.startValue;
  }

  void _processFingerInput (int index, PointerEvent details) {
    setState(() {
      print("in process finger input");
      fingerX = details.localPosition.dx;
      fingerY = details.localPosition.dy;
      thumbs[index].x = details.localPosition.dx;

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
    print(thumbs.toString());
    setState(() {
      isSliderActive = true;
      thumbs[index].isActive = true;
      Map thumbInfo = new Map<double, bool>();
      for (Thumb thumb in thumbs){
        thumbInfo[_interpolateValue(thumb.x)] = thumb.isActive;
      }
      widget.onActive(thumbInfo);
    });
    print(thumbs.toString());
  }

  void _processFingerUp(int index) {
    setState(() {
      isSliderActive = false;
      thumbs[index].isActive = false;
      Map thumbInfo = new Map<double, bool>();
      for (Thumb thumb in thumbs){
        thumbInfo[_interpolateValue(thumb.x)] = thumb.isActive;
      }
      widget.onInactive(thumbInfo);
    });
  }

  void _fingerDown (PointerEvent details) {
    for(int i = 0; i < thumbs.length; i++) {
      if((details.localPosition.dx - thumbs[i].x).abs() < 20) {
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
          print("finger " + i.toString());
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
              painter: MultiSliderPainter(radius, thumbs),
            )
        ),
      );
  }
}

class MultiSliderPainter extends CustomPainter {
  double _radius;
  List<Thumb> _thumbs;

  MultiSliderPainter(this._radius, this._thumbs);

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
    print("PAINTING");
    var linePen = Paint();

    double middleHeight = size.height/2;
    double middleWidth = size.width/2;

    //draw line
    linePen.color = Colors.grey;
    linePen.style = PaintingStyle.fill;
    canvas.drawLine(Offset(0, middleHeight), Offset(size.width, middleHeight), linePen);

    //draw thumbs
    if(_thumbs != null) {
      for (Thumb thumb in _thumbs) {
        var backgroundPen = Paint();
        backgroundPen.style = PaintingStyle.fill;
        backgroundPen.color = Colors.white;
        canvas.drawCircle(Offset(thumb.x, middleHeight), _radius, backgroundPen);
      }
      for (Thumb thumb in _thumbs) {
        var thumbPen = Paint();
        thumbPen.style = PaintingStyle.fill;
        thumbPen.color = convertLocToCol(thumb.x, thumb.isActive, size);
        canvas.drawCircle(Offset(thumb.x, middleHeight), _radius, thumbPen);
      }
    }
    // draw the line all the way across the center of the canvas
  }

  @override
  bool shouldRepaint(MultiSliderPainter oldDelegate) {
    // returns true if field has changed from oldDelegate
    return true;
    if (oldDelegate._radius != _radius) {
      return true;
    }
    for(int i = 0; i < _thumbs.length; i++) {
      Thumb old = oldDelegate._thumbs[i];
      Thumb upd = _thumbs[i];
      if(old.isActive != upd.isActive || old.x != upd.x) {
        return true;
      }
    }
    return false;
  }

}
