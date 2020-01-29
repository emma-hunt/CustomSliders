import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'MultiThumbSlider.dart';
import 'CurvedSlider.dart';

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
  List<Tuple2> myThumbs = List();
  bool isSliderActive = false;

  List<Tuple2> _prettifyTheValues(Map<double, bool> thumbsInfo) {
    List<Tuple2> prettied = List<Tuple2>();
    if (thumbsInfo == null || thumbsInfo.isEmpty) {
      prettied.add(Tuple2("woops", Colors.black));
      return prettied;
    }
    thumbsInfo.forEach((x, isActive) => {
      if(isActive) {
        prettied.add(Tuple2(x.floor().toString(), Colors.red))
      }
      else {
        prettied.add(Tuple2(x.floor().toString(),Colors.black))
      }
    });
    prettied.sort((a,b) => a.item1.compareTo(b.item1));
    return prettied;
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
          CurvedSlider(
            minorRad: 150,
            majorRad: 300,
            numThumbs: 1,
            startValue: 0,
            endValue: 100,
            onChanged: (Map newThumbs) {
              //print("in value callback ");
              setState(() {
                myThumbs = _prettifyTheValues(newThumbs);
              });
            },
            onActive: (Map newThumbs) {
              //print("in active callback");
              setState(() {
                isSliderActive = true;
                myThumbs = _prettifyTheValues(newThumbs);
              });
            },
            onInactive: (Map newThumbs) {
              //print("in inactive callback");
              setState(() {
                isSliderActive = false;
                myThumbs = _prettifyTheValues(newThumbs);
              });
            },
          ),
//          Container(
//            height: 100,
//            padding: EdgeInsets.all(5.0),
//            child:
//            ListView.builder(
//                itemCount: myThumbs.length,
//                itemBuilder: (BuildContext context, int index) {
//                  return Text(
//                    myThumbs[index].item1.toString(),
//                    style: TextStyle(color: myThumbs[index].item2),
//                    textAlign: TextAlign.center,
//                  );
//                }
//            )
//          ),
        ],
      ),
    );
  }
}
