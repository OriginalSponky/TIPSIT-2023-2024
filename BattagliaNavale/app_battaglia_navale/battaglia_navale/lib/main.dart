// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, use_key_in_widget_constructors, curly_braces_in_flow_control_structures


import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class Point {
  late int X;
  late int Y;

  Point(this.X, this.Y);
}

void printGame(List<Point> myShips,List<Point> enemyShips){
    List<List<int>> myMap = List.generate(9, (row) => List.generate(9, (col) => 0));
    List<List<int>> enemyMap = List.generate(9, (row) => List.generate(9, (col) => 0));

    for (var ship in myShips) {
      myMap[ship.Y-1][ship.X-1]=1;
    }

    for (var ship in enemyShips) {
      enemyMap[ship.Y-1][ship.X-1]=1;
    }

    String co = "   1   2   3   4   5   6   7   8   9   ";
    String line="";
    print(co+co);
    for(int i = 0;i<9;i++){
      //print("1$co\n--\n2$co\n--\n3$co\n--\n4$co\n--\n5$co\n--\n6$co\n--\n7$co\n--\n8$co\n--\n9$co\n--");
      String n =(i+1).toString();
      line=n+"  ";
      for(int j = 0;j<9;j++){
        if(myMap[i][j] == 1)
          line=line+"█   ";
        else
          line=line+"    ";
      }
      line = line+n+" ";
      for(int j = 0;j<9;j++){
        if(enemyMap[i][j] == 1)
          line=line+"█   ";
        else
          line=line+"    ";
      }
      print(line);
    }
}

class GameCommand {
  late int X;
  late int Y;
  late int commandId;

  GameCommand(this.commandId, this.X, this.Y);

  GameCommand.fromJson(Map<String, dynamic> json) {
    commandId = json['commandId'] ?? -1;
    X = json['x'] ?? "" ?? -1;
    Y = json['y'] ?? "" ?? -1;
  }

  Map toJson() => {
        'commandId': commandId,
        'x': X,
        'y': Y,
      };
}

//client commands ids
int serverIsBusy = 0;
int waitForPlayers = 1;
int startGame = 2;
int hitEnemyShip = 3;
int receiveHit = 4;
int notifyPlayerShipHit = 5;
int notifyPlayerShipMiss = 6;
int changePlayer = 7;
int notifyPlayerWin = 8;
int gameOver = 9;

// server comands ids
int playerReady = 10;


  int numberOfSquares = 9 * 9;
  int numberInEachRow = 9;
  const size = [1,1,2,3,4];
  int shipp = 5;
  int Nship = 10; 
  String info2 = "waiting for enemy response";
  bool pos = true;
  int attackSquare = -1;

List<Point> ship = [];
List<Point> shipEnemy = [];

  //[destroyed = true / false]
  var squareStatus = [];

  //[destroyed = true / false]
  var attacksquareStatus = [];

  var boatLocation = [];
  
  late Socket socket;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TCP Client',
      home: MyHomePage(),
      routes: {
        '/secondPage': (context) => SecondPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();

    Socket.connect("localhost", 4567).then((Socket sock) {
    socket = sock;
    socket.listen(dataHandler,
        onError: errorHandler, onDone: doneHandler, cancelOnError: false);
  }).catchError((e) {
    print("Unable to connect: $e");
    exit(1);
  });

    for (int i = 0; i < numberOfSquares; i++) {
      squareStatus.add([false]);
      attacksquareStatus.add([false, false, false]);
      boatLocation.add([false]);
    }
  }
  
  void sendServerMessage(commandId, xCoordinate, yCoordinate) {
  var command =
      GameCommand(commandId, xCoordinate ?? -1, yCoordinate ?? -1);

  String commandAsJson = jsonEncode(command);
  socket.write(commandAsJson);
}

Future<void> dataHandler(data) async {
  var serverMessageAsString = String.fromCharCodes(data).trim();
  Map<String, dynamic> valueMap = json.decode(serverMessageAsString);
  GameCommand gameCommand = GameCommand.fromJson(valueMap);
  print(gameCommand.commandId);
  if (gameCommand.commandId == serverIsBusy) {
    setState(() {
      info2 = "ci sono già 2 giocatori";
    });
    socket.destroy();
    exit(0);
  }

  if (gameCommand.commandId == waitForPlayers) {
    setState(() {
      info2 = "waiting for players ...";
    });
    return;
  }

  if (gameCommand.commandId == startGame) {
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100)); 
      return shipp != 0;
    });
  
    sendServerMessage(playerReady, -1, -1);
    return;
  }

   if (gameCommand.commandId == hitEnemyShip) {
    setState(() {
      info2 = "attacca prova 1 hitEnemyShip";
    });
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return attackSquare == -1;
    });
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return attacksquareStatus[attackSquare][0];
    });
      int xCoordinate = attackSquare%10;
      int yCoordinate = (attackSquare-attackSquare%9)~/9;
      setState(() {
        attacksquareStatus[attackSquare][0] = true;
      });
      sendServerMessage(receiveHit, xCoordinate, yCoordinate);
      return;
  }

  if (gameCommand.commandId == receiveHit) {
    var pointIndex = findPointInShip(gameCommand.X, gameCommand.Y);
    print("coordinate x");
    print(gameCommand.X);
    print("coordinate y");
    print(gameCommand.Y);
    setState(() {
        squareStatus[gameCommand.X + gameCommand.Y*9][0] = true;
    });
    if (pointIndex != -1) {
      setState(() {
        Nship--;
      });
      sendServerMessage(notifyPlayerShipHit, gameCommand.X, gameCommand.Y);
      //printGame(ship,shipEnemy);
      if (Nship == 0) {
            
        sendServerMessage(notifyPlayerWin, gameCommand.X, gameCommand.Y);
        playerLost();
      }
    } else {
      sendServerMessage(notifyPlayerShipMiss, -1, -1);
    }
    return;
  }

  if (gameCommand.commandId == notifyPlayerShipHit) {
    print("change player 1");
          setState(() {
            info2 = "you managed to hit the enemy boat";
            attacksquareStatus[attackSquare][1] = true;
          attackSquare = -1;
      });
    sendServerMessage(changePlayer, -1, -1);
    return;
  }

  if (gameCommand.commandId == notifyPlayerShipMiss) {
    print("change player 2");
    sendServerMessage(changePlayer, -1, -1);
      setState(() {
            info2 = "ship was missed";
            attackSquare = -1;
      });
    return;
  }

  if (gameCommand.commandId == notifyPlayerWin) {
    playerWon();
  }
}

int findPointInShip(int x, int y) {
  int loc = x+y*9;
  print(loc);
  return boatLocation[loc][0] ? loc : -1;
}

void errorHandler(error, StackTrace trace) {
  print(error);
}

void doneHandler() {
  socket.destroy();
  exit(0);
}

  void restartGame() {
    setState(() {
      for (int i = 0; i < numberOfSquares; i++) {
        squareStatus[i] = false;
      }
    });
    socket.destroy();

     Socket.connect("10.0.2.2", 8000).then((Socket sock) {
    socket = sock;
    socket.listen(dataHandler,
        onError: errorHandler, onDone: doneHandler, cancelOnError: false);
  }).catchError((e) {
    print("Unable to connect: $e");
    exit(1);
  });

  }

 void playerLost(){
    showDialog(
    context: context, 
    builder: (context){
      return AlertDialog(
        backgroundColor: Colors.grey[700],
        title: Center(
          child: Text(
            'YOU LOST',
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          Center(
            child: MaterialButton(
            onPressed: (){
              restartGame();
              Navigator.pop(context);
            },
            child: ClipRRect(borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Colors.grey[300],
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(Icons.refresh, size: 30)))
                ),
            ),
          )
          ],
      );
    });
  }

 void check(index){
  //verticale
  if(!pos && shipp != 0){ 
    if(size[size.length-shipp] == 1 && boatLocation[index][0] == false){
    setState(() {
      boatLocation[index][0] = true;
      shipp--;
    });
  } else if (index%9 != 0 && size[size.length-shipp] == 2 && boatLocation[index][0] == false && boatLocation[index-1][0] == false ){
    setState(() {
    boatLocation[index][0] = true;
    boatLocation[index-1][0] = true;
    shipp--;
    });
  } else if (index%9 != 0 && (index-1)%9 != 0
  && size[size.length-shipp] == 3
  && boatLocation[index][0] == false 
  && boatLocation[index-1][0] == false
  && boatLocation[index-2][0] == false){
    setState(() {
    boatLocation[index][0] = true;
    boatLocation[index-1][0] = true;
    boatLocation[index-2][0] = true;
    shipp--;
    });
  } else if(index%9 != 0 && (index-1)%9 != 0 && (index-2)%9 != 0
  && boatLocation[index][0] == false 
  && boatLocation[index-1][0] == false
  && boatLocation[index-2][0] == false
  && boatLocation[index-3][0] == false){
    setState(() {
    boatLocation[index][0] = true;
    boatLocation[index-1][0] = true;
    boatLocation[index-2][0] = true;
    boatLocation[index-3][0] = true;
    shipp--;
    });
  }
  } else if(pos && shipp != 0){  //orizzontale
    if(size[size.length-shipp] == 1 && boatLocation[index][0] == false){
    setState(() {
      boatLocation[index][0] = true;
      shipp--;
    });
  } else if (index<90 && size[size.length-shipp] == 2 && boatLocation[index][0] == false && boatLocation[index+numberInEachRow][0] == false ){
    setState(() {
    boatLocation[index][0] = true;
    boatLocation[index+numberInEachRow][0] = true;
    shipp--;
    });
  } else if (index<80
  && size[size.length-shipp] == 3
  && boatLocation[index][0] == false 
  && boatLocation[index+numberInEachRow][0] == false
  && boatLocation[index+numberInEachRow+numberInEachRow][0] == false){
    setState(() {
    boatLocation[index][0] = true;
    boatLocation[index+numberInEachRow][0] = true;
    boatLocation[index+numberInEachRow+numberInEachRow][0] = true;
    shipp--;
    });
  } else if(index<70
  && boatLocation[index][0] == false 
  && boatLocation[index+numberInEachRow][0] == false
  && boatLocation[index+numberInEachRow+numberInEachRow][0] == false
  && boatLocation[index+numberInEachRow+numberInEachRow+numberInEachRow][0] == false
  ){
    setState(() {
    boatLocation[index][0] = true;
    boatLocation[index+numberInEachRow][0] = true;
    boatLocation[index+numberInEachRow+numberInEachRow][0] = true;
    boatLocation[index+numberInEachRow+numberInEachRow+numberInEachRow][0] = true;
    shipp--;
    });
  }
  }
  
 }

void playerWon(){
    showDialog(
    context: context, 
    builder: (context){
      return AlertDialog(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            'YOU WIN',
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          Center(
            child: MaterialButton(
            onPressed: (){
              restartGame();
              Navigator.pop(context);
            },
            child: ClipRRect(borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Colors.grey[500],
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(Icons.refresh, size: 30)))
                ),
            ),
          )
          ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: (){
                    if(pos){
                      setState(() {
                        pos = false;
                      });
                    } else {
                      setState(() {
                        pos = true;
                      });
                    }
                  },
                  child: Text(pos ? "Verticale ↓" : "Orizzontale ←"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green,),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: numberOfSquares,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 1.1,
                    crossAxisCount: numberInEachRow),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: (){
                        check(index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Container(
                        alignment: Alignment.center,
                        color: squareStatus[index][0]? Colors.red[400] : Colors.purple[400],
                        child: Text(
                          boatLocation[index][0] ? "X" : index.toString(),
                          style: TextStyle(fontSize: 30.0),
                          ),
                      ),
                    ),
                  );
                }),
          ), 
          Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            if(shipp <= 0)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecondPage()),
            );
          },
          child: Text(shipp != 0 ? "piazza le barche" : "campo di battaglia"),
        ),
      ),
        ],
      ),
    );
  }
  }




  
class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('I Tuoi Attacchi'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [ 
          Expanded(
            child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: numberOfSquares,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 1.1,
                    crossAxisCount: numberInEachRow),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: (){
                        setState(() {
                        attackSquare = index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Container(
                        alignment: Alignment.center,
                        color: attacksquareStatus[index][1] ? Colors.green : attacksquareStatus[index][0]? Colors.red[400] : Colors.blue[400],
                        child: Text(
                          attackSquare.toString(),
                          style: TextStyle(fontSize: 30.0),
                          ),
                      ),
                    ),
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: info2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}