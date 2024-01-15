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

  void setPlayerShip() async {
    for (int i = 0; i < 5; i++) {
      print("Select the starting point for Ship ${i + 1}");
      Point selectedPoint = await getPlayerInput();

      Map<String, dynamic> shipParams = await getShipParameters();

      setState(() {
        Ship currentShip = Ship(shipParams['length']);
        bool isVertical = shipParams['isVertical'];

        if (!currentShip.isPlaced() &&
            freePlace(currentShip.locations, selectedPoint.x, selectedPoint.y, currentShip.length, isVertical)) {
          for (int i = 0; i < currentShip.length; i++) {
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
  }

  Future<Map<String, dynamic>> getShipParameters() async {
    bool isVertical = false;
    int selectedLength = 1;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Ship Parameters'),
          content: Column(
            children: [
              Text('Select the orientation and length for the ship.'),
              Row(
                children: [
                  Radio<bool>(
                    value: false,
                    groupValue: isVertical,
                    onChanged: (value) {
                      isVertical = value ?? false;
                    },
                  ),
                  Text('Horizontal'),
                ],
              ),
              Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: isVertical,
                    onChanged: (value) {
                      isVertical = value ?? false;
                    },
                  ),
                  Text('Vertical'),
                ],
              ),
              DropdownButton<int>(
                value: selectedLength,
                items: [1, 2, 3].map((int length) {
                  return DropdownMenuItem<int>(
                    value: length,
                    child: Text('Length: $length'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    selectedLength = newValue;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({'isVertical': isVertical, 'length': selectedLength});
              },
              child: Text('Select'),
            ),
          ],
        );
      },
    );

    return {'isVertical': isVertical, 'length': selectedLength};
  }


  Future<Map<String, dynamic>> getOrientationAndLengthInput() async {
    bool isVertical = false;
    int selectedLength = 1;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Orientation and Length'),
          content: Column(
            children: [
              Text('Select the orientation and length for the ship.'),
              Row(
                children: [
                  Radio<bool>(
                    value: false,
                    groupValue: isVertical,
                    onChanged: (value) {
                      isVertical = value ?? false;
                    },
                  ),
                  Text('Horizontal'),
                ],
              ),
              Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: isVertical,
                    onChanged: (value) {
                      isVertical = value ?? false;
                    },
                  ),
                  Text('Vertical'),
                ],
              ),
              DropdownButton<int>(
                value: selectedLength,
                items: [1, 2, 3].map((int length) {
                  return DropdownMenuItem<int>(
                    value: length,
                    child: Text('Length: $length'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    selectedLength = newValue;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({'isVertical': isVertical, 'length': selectedLength});
              },
              child: Text('Select'),
            ),
          ],
        );
      },
    );

    return {'isVertical': isVertical, 'length': selectedLength};
  }

  Future<bool> getOrientationInput() async {
    bool isVertical = false; // Default to horizontal

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Orientation'),
          content: Column(
            children: [
              Text('Select the orientation for the ship.'),
              Row(
                children: [
                  Radio<bool>(
                    value: false,
                    groupValue: isVertical,
                    onChanged: (value) {
                      isVertical = value ?? false;
                    },
                  ),
                  Text('Horizontal'),
                ],
              ),
              Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: isVertical,
                    onChanged: (value) {
                      isVertical = value ?? false;
                    },
                  ),
                  Text('Vertical'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(isVertical);
              },
              child: Text('Select'),
            ),
          ],
        );
      },
    );

    return isVertical;
  }

  Future<Point> getPlayerInput() async {
    // Implement the logic to get player input for ship placement
    // You can use a dialog or another UI to get the coordinates from the player
    // For simplicity, I'll use a basic dialog for demonstration purposes

    Point selectedPoint = Point(0, 0); // Initialize with invalid values

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Starting Point'),
          content: Column(
            children: [
              Text('Select the starting point for the ship.'),
              TextField(
                decoration: InputDecoration(labelText: 'X Coordinate'),
                onChanged: (value) {
                  selectedPoint.x = int.tryParse(value) ?? 0;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Y Coordinate'),
                onChanged: (value) {
                  selectedPoint.y = int.tryParse(value) ?? 0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(selectedPoint);
              },
              child: Text('Select'),
            ),
          ],
        );
      },
    );

    return selectedPoint;
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

