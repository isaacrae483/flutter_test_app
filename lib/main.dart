import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Flutter Practice Home Page'),
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
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Container(
          child: Column(
            children: <Widget>[
              Slider(                             //initiate slider,  pass in callbacks and parameters
                onChanged: (double x){            //change value callback
                  setState((){
                    String finalText = "";
                    for(int i = 0; i < SliderValues.thumbCount; i++){
                      finalText = finalText + SliderValues.textPos[i].round().toString() + " ";
                    }
                    SliderValues.textValue = finalText;
                  });},
                minRange: 1,                      //range values
                maxRange: 100,
                thumbs: 5,
              ),
              Text(SliderValues.textValue,
              style: TextStyle(color: SliderValues.textColor, fontSize: 40)
              ),
            ],
        ),
      ),
    );
  }
}

class Slider extends StatefulWidget{

  //callbacks for when values change
  final ValueChanged<double> onChanged;
  //range for slidervalues
  double minRange = 0;
  double maxRange = double.infinity;
  int thumbs = 1;

  //constructor for Slider
  Slider({
    this.onChanged,
    this.minRange,
    this.maxRange,
    this.thumbs,
  }){
    if (this.thumbs == null){
      this.thumbs = 5;
    }
    SliderValues.thumbCount = this.thumbs;
    for(int i = 0; i < SliderValues.thumbCount; i++){
      //double value = (50*i+25).toDouble();
      SliderValues.xPositions.add(25);
      SliderValues.yPositions.add((50 + (100 * i)).toDouble());
      SliderValues.textPos.add(this.minRange);

    }
  }

  @override
  State<StatefulWidget> createState() => _SliderState();

}

class _SliderState extends State<Slider>{
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.blue,
        child: Listener(                    //add listener on slider
          onPointerDown: _fingerDown,
          onPointerMove: _fingerMove,
          onPointerUp: _fingerUp,
          child: Center(
            child: Container(
              height: 500,
              width: double.infinity,
              color: Colors.deepPurple,
              child: CustomPaint(
                painter: SliderPainter()    //add custom painter to slider
              ),
            ),
          ),
        ),
      ),
    );

  }

  void _findThumb(double xfinger){//determine which thumb to activate

    Random rnd = new Random();
    SliderValues.activeThumb = rnd.nextInt(SliderValues.thumbCount);
    return;
    double finalDist = double.infinity;
    double tempXDist = 0;
    for(int i = 0; i < SliderValues.thumbCount; i++ ){
      tempXDist = (SliderValues.xPositions[i] - xfinger).abs();
      if(tempXDist < finalDist){
        SliderValues.activeThumb = (i + 1) % SliderValues.thumbCount;
        finalDist = tempXDist;
      }
    }
  }

  void _fingerDown(PointerEvent details){         //response on finger press

    SliderValues.xDown = details.position.dx;
    _findThumb(SliderValues.xDown);
    _bounds();
    double newValue = _calculate(SliderValues.xDown);
    SliderValues.textPos[SliderValues.activeThumb] = newValue;

    if (widget.onChanged != null){
      widget.onChanged(newValue);
    }

    setState((){
      SliderValues.xPositions[SliderValues.activeThumb] = SliderValues.xDown;
    });
  }

  void _fingerMove(PointerEvent details){         //response on finger move
    SliderValues.xDown = details.position.dx;
    _bounds();
    double newValue = _calculate(SliderValues.xDown);
    SliderValues.textPos[SliderValues.activeThumb] = newValue;

    if (widget.onChanged != null){
      widget.onChanged(newValue);
    }

    setState((){
      SliderValues.xPositions[SliderValues.activeThumb] = SliderValues.xDown;
    });
  }

  void _fingerUp(PointerEvent details){

  }

  double _calculate(double r){           //linear interpolation for values
    double actRange = SliderValues.actMaxY - SliderValues.actMaxX;
    double displayRange = widget.maxRange - widget.minRange;
    double actDist = r - SliderValues.actMaxX;
    double value = (actDist/(actRange/displayRange)) + widget.minRange;
    return value;
  }

  void _bounds(){               //bound for the x value to keep on slider

    if(SliderValues.xDown <= 25){
      SliderValues.xDown = 25;
    }
    else if(SliderValues.xDown > SliderValues.actMaxX){
      SliderValues.xDown = SliderValues.actMaxX;
    }

  }

}



// public class to hold values allowing global access
class SliderValues extends Object {
  static String textValue = "0";
  static List<double> textPos = new List();
  static List<double> xPositions = new List();
  static List<double> yPositions = new List();
  static double xDown = 0;
  static Color activeThumbColor = Colors.white;
  static Color textColor = Colors.blue;

  static double actMaxY = 300;
  static double actMaxX = 150;

  static int thumbCount = 1;
  static int activeThumb = -1;
}

class SliderPainter extends CustomPainter{    //customPainter for the slider

  @override
  void paint(Canvas canvas, Size size) {

    SliderValues.actMaxX = size.width - 25;

    Paint pen = Paint () ..color = Colors.orange ..style = PaintingStyle.stroke ..strokeWidth = 5;
    canvas.drawLine(Offset(25, 50), Offset(size.width - 25, 50), pen);
    canvas.drawLine(Offset(25, 150), Offset(size.width - 25, 150), pen);
    canvas.drawLine(Offset(25, 250), Offset(size.width - 25, 250), pen);
    canvas.drawLine(Offset(25, 350), Offset(size.width - 25, 350), pen);
    canvas.drawLine(Offset(25, 450), Offset(size.width - 25, 450), pen);


    //draw the circle on the slider
    for(int i = 0; i < SliderValues.thumbCount; i++){
      Paint pen = Paint() ..color = Colors.red;
      canvas.drawCircle(Offset(SliderValues.xPositions[i], SliderValues.yPositions[i]), 25, pen);
      Paint outline = Paint() ..color = Colors.green ..style = PaintingStyle.stroke ..strokeWidth = 2;
      canvas.drawCircle(Offset(SliderValues.xPositions[i], SliderValues.yPositions[i]), 25, outline);
    }

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}
