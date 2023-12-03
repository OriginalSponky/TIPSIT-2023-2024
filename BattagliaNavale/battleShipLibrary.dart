library battleShipLibrary;

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
