import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Point {
  int x;
  int y;

  Point(this.x, this.y);
}

class Ship {
  int length;
  List<Point> locations;
  bool isVertical;

  Ship(this.length) : locations = [], isVertical = false;

  bool isPlaced() {
    return locations.length == length;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('BattleShip'),
        ),
        body: BattleShipGame(),
      ),
    );
  }
}

class BattleShipGame extends StatefulWidget {
  @override
  _BattleShipGameState createState() => _BattleShipGameState();
}

class _BattleShipGameState extends State<BattleShipGame> {
  List<Point> enemyShip = [];
  List<Ship> playerShips = [];
  bool showPlayerShip = true;
  int selectedShipLength = 1;
  bool isVertical = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(showPlayerShip ? 'Player\'s BattleShip' : 'Enemy\'s BattleShip'),
        buildGameBoard(),
        ElevatedButton(
          onPressed: () {
            setState(() {
              showPlayerShip = !showPlayerShip;
            });
          },
          child: Text(showPlayerShip ? 'Show Enemy\'s Ship' : 'Show Player\'s Ship'),
        ),
        if (showPlayerShip)
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    playerShips.clear();
                  });
                  setPlayerShip();
                },
                child: Text('Set Player\'s Ship'),
              ),
              DropdownButton<int>(
                value: selectedShipLength,
                items: [1, 2, 3].map((int length) {
                  return DropdownMenuItem<int>(
                    value: length,
                    child: Text('Ship Length: $length'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedShipLength = newValue;
                    });
                  }
                },
              ),
              Row(
                children: [
                  Text('Orientation: '),
                  DropdownButton<bool>(
                    value: isVertical,
                    items: [
                      DropdownMenuItem<bool>(
                        value: false,
                        child: Text('Horizontal'),
                      ),
                      DropdownMenuItem<bool>(
                        value: true,
                        child: Text('Vertical'),
                      ),
                    ],
                    onChanged: (bool? newValue) {
                      if (newValue != null) {
                        setState(() {
                          isVertical = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget buildGameBoard() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 9,
      ),
      itemCount: 81,
      itemBuilder: (context, index) {
        int x = index % 9 + 1;
        int y = index ~/ 9 + 1;

        Point currentPoint = Point(x, y);

        // Check if the current point is part of a ship
        bool isShip = false;
        Ship? ship;
        for (Ship s in playerShips) {
          if (s.locations.contains(currentPoint)) {
            isShip = true;
            ship = s;
            break;
          }
        }

        return GestureDetector(
          onTap: () {
            if (showPlayerShip && playerShips.length < 5) {
              setPlayerShipLocation(currentPoint);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(),
              color: isShip ? Colors.blue : Colors.white,
            ),
            child: isShip ? Center(child: Text('${ship?.length}')) : null,
          ),
        );
      },
    );
  }

  void setPlayerShip() {
    // Implement the logic for setting the player's ships
    // You can use a dialog or another UI for the player to input ship coordinates
    // and then update the playerShips list accordingly.
  }

  void setPlayerShipLocation(Point selectedPoint) {
    setState(() {
      Ship currentShip = Ship(selectedShipLength);

      if (!currentShip.isPlaced() &&
          freePlace(currentShip.locations, selectedPoint.x, selectedPoint.y, selectedShipLength, isVertical)) {
        for (int i = 0; i < selectedShipLength; i++) {
          if (isVertical) {
            currentShip.locations.add(Point(selectedPoint.x, selectedPoint.y + i));
          } else {
            currentShip.locations.add(Point(selectedPoint.x + i, selectedPoint.y));
          }
        }

        if (currentShip.isPlaced()) {
          playerShips.add(currentShip);
        }
      }
    });
  }

  bool freePlace(List<Point> locations, int x, int y, int length, bool isVertical) {
    // Implement the logic to check if the place is free for the ship
    // Return true if the place is free, false otherwise.
    if (playerShips.length + 1 > 5) {
      // Check if the maximum number of ships (5) is reached
      return false;
    }

    if (isVertical) {
      if (y + length - 1 <= 9) {
        for (var i = 0; i < length; i++) {
          if (findPointInShip(locations, x, y + i) != -1) return false;
        }
      } else {
        return false;
      }
    } else {
      if (x + length - 1 <= 9) {
        for (var i = 0; i < length; i++) {
          if (findPointInShip(locations, x + i, y) != -1) return false;
        }
      } else {
        return false;
      }
    }
    return true;
  }

  int findPointInShip(List<Point> locations, int x, int y) {
    for (int i = 0; i < locations.length; i++) {
      if ((locations[i].x == x) && (locations[i].y == y)) return i;
    }

    return -1;
  }
}

