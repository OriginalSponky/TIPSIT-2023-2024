import 'package:flutter/material.dart';
import 'dart:async';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cronometro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Cronometro'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum Stato {
  on,
  pause,
  stop,
}

 class _MyHomePageState extends State<MyHomePage> {
  int time = 0;
  int par = 1;
  bool isRunning = false;
  Stato st = Stato.stop;
  List<int> partials = List<int>.generate(10, (index) => 0);
  late StreamSubscription<int> timerSubscription;
  String stPartials = "";


  Stream<int> timedCounter(Duration interval, [int? maxCount]) async* {
    int i = 0;
    while (true) {
      await Future.delayed(interval);
      yield i++;
      if (i == maxCount) break;
    }
  }


    void _startTimer() {
      isRunning = true;
      if(st == Stato.stop){
        st = Stato.on;
        Stream<int> timerStream = timedCounter(const Duration(seconds: 1), 9999999999);
        setState(() {
          timerSubscription = timerStream.listen((int i) async { 
            setState(() {
              time = i;
            });
          });
        });
      }else{
        st = Stato.on;
        setState(() {
          timerSubscription.resume();
        });
      }
    }
  

  void _stopTimer() {
    setState(() {
      isRunning = false;
      st = Stato.pause;
      timerSubscription.pause();
    });
  }
  

  void _resetTimer() {
    setState((){
      isRunning = false;
      time = 0;
      st = Stato.stop;
      timerSubscription.cancel();
      stPartials = "";
    });
  }
  

  int _converter( int l){
    int r=0;
        while(l>60){
            r++;
            l-=60;
        }
        return r;
  } 

  String _convertDisplay(int l){
    int ss=l%60;
    int MM = _converter(l);
    int HH = _converter(MM);
    String strss= ss.toString();
    String strMM= (MM%60).toString();
    String strHH= HH.toString();
    if(strHH.length==1) {
        strHH = "0" + strHH;
    }
    if(strss.length==1){
            strss="0"+strss;
        }
    if(strMM.length==1){
        strMM="0"+strMM;
    }
   

    return strHH+":"+strMM+":"+strss;
  }

  void _addPartial(){
    setState(() {
      if(10*10 > stPartials.length){
      partials.add(time);
      stPartials = stPartials+par.toString()+")"+ _convertDisplay(time)+"\n";
      par++;
      print(stPartials);
      }
    });        
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                  stPartials,
                  style: TextStyle(fontSize: 36),
                ),
            Text(
             _convertDisplay(time),
              style: TextStyle(fontSize: 36),
            ),
             SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (!isRunning)
                  ElevatedButton(
                    onPressed: _startTimer,
                    child: Text("Start"),
                  ),
                if (isRunning)
                  ElevatedButton(
                    onPressed: _stopTimer,
                    child: Text("Stop"),
                  ),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: Text("Reset"),

                ), ElevatedButton(
                  onPressed: _addPartial,
                  child: Text("Parziale"),
                ),
                
                SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}