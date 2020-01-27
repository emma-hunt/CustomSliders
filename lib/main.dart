import 'package:flutter/material.dart';
import 'MultiThumbSlider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Simple App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(title: 'Simple Slider'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color textColor = Colors.black;
  double mySliderValue = 0.0;
  bool isSliderActive = false;

  String _prettifyTheValues(double sliderValue) {
    if (sliderValue.isNaN) {
      return "bugger";
    }
    return sliderValue.floor().toString();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        // Here we use mainAxisAlignment to center the children vertically;
        // the cross axis would be horizontal
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          MultiThumbSlider(
            numThumbs: 3,
            startValue: 0,
            endValue: 100,
            onChanged: (double newValue) {
              print("in value callback ");
              setState(() {
                mySliderValue = newValue;
              });
            },
            onActive: () {
              print("in active callback");
              setState(() {
                isSliderActive = true;
                textColor = Colors.red;
              });
            },
            onInactive: () {
              print("in inactive callback");
              setState(() {
                isSliderActive = false;
                textColor = Colors.black;
                print(textColor);
              });
            },
          ),
          Container(
            height: 50,
            padding: EdgeInsets.all(5.0),
            child: Text(
              _prettifyTheValues(mySliderValue),
              style: TextStyle(color: textColor),
              textAlign: TextAlign.left,
            ),
          ),

        ],
      ),
    );
  }
}

