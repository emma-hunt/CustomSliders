import 'package:flutter/material.dart';

class MultiThumbSlider extends StatefulWidget {
  final ValueChanged<double> onChanged;
  final VoidCallback onActive;
  final VoidCallback onInactive;
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
  List<Thumb> thumbs;

  @override
  initState() {
    super.initState();
    thumbs = new List(widget.numThumbs);
    final RenderBox box = this.context.findRenderObject();
    var width = box.size.width;
    double spaceing = width/(widget.numThumbs+1);
    double xLoc = spaceing;
    for (int i = 0; i < widget.numThumbs; i++){
      thumbs[i] = new Thumb(x: xLoc, isActive: false);
      xLoc = xLoc + spaceing;
    }
  }

  // interpolates from actual thumb position to value in user specified coordinate system
  double _interpolateValue(double sliderValue, double sliderMax) {
    return (sliderValue * ((widget.endValue+1 - widget.startValue)/sliderMax)) + widget.startValue;
  }

  void _processFingerInput (PointerEvent details) {
    setState(() {
      fingerX = details.localPosition.dx;
      fingerY = details.localPosition.dy;
      final RenderBox box = this.context.findRenderObject();
      var size = box.size;
      widget.onChanged(_interpolateValue(fingerX, size.width)); // this is how we report
      // actually figure out the max x value
    });
  }

  void _processFingerDown() {
    setState(() {
      isSliderActive = true;
      widget.onActive();
    });
  }

  void _processFingerUp() {
    setState(() {
      isSliderActive = false;
      widget.onInactive();
    });
  }

  void _fingerDown (PointerEvent details) {
    _processFingerDown();
    _processFingerInput (details);
  }

  void _fingerMove (PointerEvent details) {
    _processFingerInput (details);
  }

  void _fingerUp (PointerEvent details) {
    _processFingerUp();
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
    var linePen = Paint();
    var thumbPen = Paint();
    double middleLocation = size.height/2;
    double centerLocation = size.width/2;

    //draw line
    linePen.color = Colors.grey;
    linePen.style = PaintingStyle.fill;
    canvas.drawLine(Offset(0, middleLocation), Offset(size.width, middleLocation), linePen);

    //draw thumbs
    thumbPen.style = PaintingStyle.fill;
    if(_thumbs != null) {
      for (Thumb thumb in _thumbs) {
        thumbPen.color = convertLocToCol(thumb.x, thumb.isActive, size);
        canvas.drawCircle(Offset(thumb.x, middleLocation), _radius, thumbPen);
      }
    }
    // draw the line all the way across the center of the canvas
  }

  @override
  bool shouldRepaint(MultiSliderPainter oldDelegate) {
    // returns true if field has changed from oldDelegate
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
