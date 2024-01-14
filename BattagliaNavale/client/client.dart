//import 'dart:html';
import 'dart:io';
import 'dart:convert';
import '../battleShipLibrary.dart';

late Socket socket;

late List<Point> ship = [];

late int nOfship = 0;

late List<Point> shipEnemy = [];


void setShip() {
  
  var lengthOfship;
  var xCoordinate;
  var yCoordinate;
  var orientation;

  while(nOfship < 5){
    printGame(ship,shipEnemy);
    print("Add a new ship");
    do{
      print("Length of ship (1 or 2 or 3): ");
      var lengthOfshipAsString = stdin.readLineSync();
      lengthOfship = int.tryParse(lengthOfshipAsString ?? "") ?? 1;
    }while(lengthOfship < 1 || lengthOfship > 3);

    do{
      print("X (1-9): ");
      var xCoordinateAsString = stdin.readLineSync();
      xCoordinate = int.tryParse(xCoordinateAsString ?? "") ?? 1; //Error: The argument type 'String?' can't be assigned to the parameter type 'String' because 'String?' is nullable and 'String' isn't.
    }while(xCoordinate < 1 || xCoordinate > 9);

    do{
      print("Y (1-9): ");
      var yCoordinateAsString = stdin.readLineSync();
      yCoordinate = int.tryParse(yCoordinateAsString ?? "") ?? -1;
    }while(xCoordinate < 1 || xCoordinate > 9);

    do{
      print("Orientation(Vertical[V] or Horizontal[H]): ");
      orientation = stdin.readLineSync();
    }while(!(orientation?.toUpperCase() == "V" || orientation?.toUpperCase() == "H"));
    
    if(freePlace(ship, xCoordinate, yCoordinate, lengthOfship, orientation)){
      try{
        if(orientation?.toUpperCase() == "V"){
            for (var i = 0; i < lengthOfship; i++) {
              ship.add(new Point(xCoordinate, yCoordinate + i));
            }
          }else{
            for (var i = 0; i < lengthOfship; i++) {
              ship.add(new Point(xCoordinate + i, yCoordinate));
            }
          }
      }catch(Error){
        print("Error entering the boat, please try again.");
        setShip();
      }
      nOfship++;
      print("ship n.$nOfship added");
    }else{
            print("The ship cannot be placed there, please try again");
            setShip();
          }
  }
  printGame(ship,shipEnemy);
}

void main() {
  Socket.connect("localhost", 4567).then((Socket sock) {
    socket = sock;
    socket.listen(dataHandler,
        onError: errorHandler, onDone: doneHandler, cancelOnError: false);
  }).catchError((e) {
    print("Unable to connect: $e");
    exit(1);
  });

//   stdin.listen((data) =>
//       socket.write(
//         new String.fromCharCodes(data).trim() + '\n'));
}

void sendServerMessage(commandId, xCoordinate, yCoordinate) {
  var command =
      new GameCommand(commandId, xCoordinate ?? -1, yCoordinate ?? -1);

  String commandAsJson = jsonEncode(command);
  socket.write(commandAsJson);
}

void dataHandler(data) {
  var serverMessageAsString = new String.fromCharCodes(data).trim();
  // command = int.tryParse(serverMessageAsString)!;
  Map<String, dynamic> valueMap = json.decode(serverMessageAsString);
  GameCommand gameCommand = GameCommand.fromJson(valueMap);

  if (gameCommand.commandId == serverIsBusy) {
    print("Server is busy, please comeback.");
    socket.destroy();
    exit(0);
  }
  if (gameCommand.commandId == waitForPlayers) {
    print("waiting for players ...");
    return;
  }

  if (gameCommand.commandId == startGame) {
    print("Please enter your ship coordinates");
    setShip();

    sendServerMessage(playerReady, -1, -1);
    return;
  }

  if (gameCommand.commandId == hitEnemyShip) {
    printGame(ship,shipEnemy);
    print("Hit enemy ship: ");
    print("X: ");
    var xCoordinateAsString = stdin.readLineSync();
    var xCoordinate = int.tryParse(xCoordinateAsString ??
        ""); //Error: The argument type 'String?' can't be assigned to the parameter type 'String' because 'String?' is nullable and 'String' isn't.

    print("Y: ");
    var yCoordinateAsString = stdin.readLineSync();
    var yCoordinate = int.tryParse(yCoordinateAsString ?? "");

    sendServerMessage(receiveHit, xCoordinate, yCoordinate);
    return;
  }

  if (gameCommand.commandId == receiveHit) {
    var pointIndex = findPointInShip(ship, gameCommand.X, gameCommand.Y);
    if (pointIndex != -1) {
      ship.removeAt(pointIndex);
      sendServerMessage(notifyPlayerShipHit, gameCommand.X, gameCommand.Y);
      printGame(ship,shipEnemy);
      if (ship.length == 0) {
        print("Game over, you lost.");
        sendServerMessage(notifyPlayerWin, gameCommand.X, gameCommand.Y);
      }
    } else {
      sendServerMessage(notifyPlayerShipMiss, -1, -1);
    }
    return;
  }

  if (gameCommand.commandId == notifyPlayerShipHit) {
    print("ship was hit");
    shipEnemy.add(new Point(gameCommand.X, gameCommand.Y));
    sendServerMessage(changePlayer, -1, -1);
    return;
  }

  if (gameCommand.commandId == notifyPlayerShipMiss) {
    print("ship was missed");

    sendServerMessage(changePlayer, -1, -1);
  }
  if (gameCommand.commandId == notifyPlayerWin) {
    print("Congrats, you won !!!!!");
    //socket.destroy();
  }
}

bool freePlace(List<Point> ship, int x, int y,int length,String orientation){
  if(orientation.toUpperCase() == "V"){
        if(y+length-1 <= 9){
          for (var i = 0; i < length; i++) {
            if(findPointInShip(ship, x, y+i) != -1) return false;
          }
        }else{
          return false;
        }
      }else{
        if(x+length-1 <= 9){
          for (var i = 0; i < length; i++) {
            if(findPointInShip(ship, x+i, y) != -1) return false;
          }
        }else{
          return false;
        }
      }
  return true;
}

int findPointInShip(List<Point> ship, int x, int y) {
  for (int i = 0; i < ship.length; i++) {
    if ((ship[i].X == x) && (ship[i].Y == y)) return i;
  }

  return -1;
}

void errorHandler(error, StackTrace trace) {
  print(error);
}

void doneHandler() {
  socket.destroy();
  exit(0);
}
