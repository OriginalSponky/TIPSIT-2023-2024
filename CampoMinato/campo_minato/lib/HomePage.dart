import 'package:campo_minato/MyBomb.dart';
import 'package:campo_minato/MyNumberBox.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //variables
  int numberOfSquares = 9 * 9;
  int numberInEachRow = 9;
  // [number of bombs around, revealed = true/false ]
  var squareStatus = [];

  //bomb locations
  final List<int> bombLocation = [
    4,
    5,
    7,
    41,
    42,
    43,
    61,
  ];
  bool bombsRevealed = false;
  @override
  void initState() {
    super.initState();

    for (int i = 0; i < numberOfSquares; i++) {
      squareStatus.add([0, false]);
    }
    scanBombs();
  }

  void restartGame() {
    setState(() {
      bombsRevealed = false;
      for (int i = 0; i < numberOfSquares; i++) {
        squareStatus[i][1] = false;
      }
    });
  }

// Mostra il gender della casella
  void revealBoxNumbers(int index) {
    //reveal current box if it is a number : 1,2,3 etc
    if (squareStatus[index][0] != 0) {
      setState(() {
        squareStatus[index][1] = true;
      });
    }
    //if current box is 0
    else if (squareStatus[index][0] == 0) {
      //reveal current box, and the 8 surrounding boxes, unless you're on a wall
      setState(() {
        //reveal current box
        squareStatus[index][1] = true;
        //reveal left box (unless we are currently on the left wall)
        if (index % numberInEachRow != 0) {
          //if next box isn't revealed yet and it is a 0, then recurse
          if (squareStatus[index - 1][0] == 0 &&
              squareStatus[index - 1][1] == false) {
            revealBoxNumbers(index - 1);
          }
          //reveal left box
          squareStatus[index - 1][1] = true;
        }

        //reveal top left box (unless we are currently on the top row or left wall)
        if (index % numberInEachRow != 0 && index >= numberInEachRow) {
          //if next box isn't revealed yet and is a 0, then recurse
          if (squareStatus[index - 1 - numberInEachRow][0] == 0 &&
              squareStatus[index - 1 - numberInEachRow][1] == false) {
            revealBoxNumbers(index - 1 - numberInEachRow);
          }

          squareStatus[index - 1 - numberInEachRow][1] = true;
        }

        //reveal top box (unless we are on the top row)
        if (index >= numberInEachRow) {
          //if next box isn't revealed yet and it is a 0, then recurse
          if (squareStatus[index - numberInEachRow][0] == 0 &&
              squareStatus[index - numberInEachRow][1] == false) {
            revealBoxNumbers(index - numberInEachRow);
          }

          squareStatus[index - numberInEachRow][1] = true;
        }

        //reveal top right box (unless we are on the top row or the right wall)
        if (index >= numberInEachRow &&
            index % numberInEachRow != numberInEachRow - 1) {
          //if next box isn't revealed yet and it is a 0, then recurse
          if (squareStatus[index + 1 - numberInEachRow][0] == 0 &&
              squareStatus[index + 1 - numberInEachRow][1] == false) {
            revealBoxNumbers(index + 1 - numberInEachRow);
          }
          squareStatus[index + 1 - numberInEachRow][1] = true;
        }

        //reveal right box (unless we are on the right wall)
        if (index % numberInEachRow != numberInEachRow - 1) {
          //if next box isn't revealed yet and it is a 0, then recurse
          if (squareStatus[index + 1][0] == 0 &&
              squareStatus[index + 1][1] == false) {
            revealBoxNumbers(index + 1);
          }
          squareStatus[index + 1][1] = true;
        }

        //reveal bottom right box (unless we are on the bottom or the right wall)
        if (index < numberOfSquares - numberInEachRow &&
            index % numberInEachRow != numberInEachRow - 1) {
          //if next box isn't revealed yet and it is a 0, then recurse
          if (squareStatus[index + 1 + numberInEachRow][0] == 0 &&
              squareStatus[index + 1 + numberInEachRow][1] == false) {
            revealBoxNumbers(index + 1 + numberInEachRow);
          }
          squareStatus[index + 1 + numberInEachRow][1] = true;
        }

        //reveal bottom box (unless we are on the bottom row)
        if (index < numberOfSquares - numberInEachRow) {
          //if next box isn't revealed yet and it is a 0, then recurse
          if (squareStatus[index + numberInEachRow][0] == 0 &&
              squareStatus[index + numberInEachRow][1] == false) {
            revealBoxNumbers(index + numberInEachRow);
          }
          squareStatus[index + numberInEachRow][1] = true;
        }

        //reveal bottom left box (unless we are on the bottom row or the left wall)
        if (index < numberOfSquares - numberInEachRow &&
            index % numberInEachRow != 0) {
          //if next box isn't revealed yet and it is a 0, then recurse
          if (squareStatus[index - 1 + numberInEachRow][0] == 0 &&
              squareStatus[index - 1 + numberInEachRow][1] == false) {
            revealBoxNumbers(index - 1 + numberInEachRow);
          }
          squareStatus[index - 1 + numberInEachRow][1] = true;
        }
      });
    }
  }

  //Per ogni cella si va a contare il numero di celle preseneti attorno ad essa
  void scanBombs() {
    for (int i = 0; i < numberOfSquares; i++) {
      // non ci sono bombe inizialmente
      int numberOfBombsAround = 0;
      /*
      
      
    check each square to see if it has bombs surrounding it
    there are 8 surrounding boxes to check
      
      */

      //check square to the left, unless it is in the first column
      if (bombLocation.contains(i - 1) && i % numberInEachRow != 0) {
        numberOfBombsAround++;
      }

      //check square to the top left, unless it is in the first column or first row
      if (bombLocation.contains(i - 1 - numberInEachRow) &&
          i % numberInEachRow != 0 &&
          i >= numberInEachRow) {
        numberOfBombsAround++;
      }

      //check square to the top, unless it is in the first row
      if (bombLocation.contains(i - numberInEachRow) && i >= numberInEachRow) {
        numberOfBombsAround++;
      }

      //check square to the top right, unless it is in the first row or last column
      if (bombLocation.contains(i + 1 - numberInEachRow) &&
          i >= numberInEachRow &&
          i % numberInEachRow != numberInEachRow - 1) {
        numberOfBombsAround++;
      }

      //check square to the right, unless it is in the last column
      if (bombLocation.contains(i + 1) &&
          i % numberInEachRow != numberInEachRow - 1) {
        numberOfBombsAround++;
      }

      //check square to the bottom right, unless it is in the last column or last row
      if (bombLocation.contains(i + 1 + numberInEachRow) &&
          i % numberInEachRow != numberInEachRow - 1 &&
          i < numberOfSquares - numberInEachRow) {
        numberOfBombsAround++;
      }

      //check square to the bottom, unless it is in the last row
      if (bombLocation.contains(i + numberInEachRow) &&
          i < numberOfSquares - numberInEachRow) {
        numberOfBombsAround++;
      }

      //check square to the bottom left, unless it is in the last row or first column
      if (bombLocation.contains(i - 1 + numberInEachRow) &&
          i < numberOfSquares - numberInEachRow &&
          i % numberInEachRow != 0) {
        numberOfBombsAround++;
      }

      //add total number of bombs around to square status
      //La casella di pos. i avrÃ  come valore associato la quantita di bombe attorno ad essa
      setState(() {
        squareStatus[i][0] = numberOfBombsAround;
      });
    }
  }

  void playerLost() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.blue[800],
            title: Center(
                child: Text(
              'HAI PERSO!',
              style: TextStyle(color: Colors.white),
            )),
            actions: [
              MaterialButton(
                color: Colors.red,
                onPressed: () {
                  restartGame();
                  Navigator.pop(context);
                },
                child: Icon(Icons.refresh),
              ),
            ],
          );
        });
  }

  void playerWon() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.blue[700],
            title: Center(
                child: Text(
              'HAI VINTO!',
              style: TextStyle(color: Colors.white),
              ),
            ),
            actions: [
              Center(
                child: MaterialButton(
                  onPressed: () {
                    restartGame();
                    Navigator.pop(context);
                  },
                  child : ClipRRect(
                    borderRadius : BorderRadius.circular(10),
                    child : Container(
                      color : Colors.blue[300],
                      child : Padding(
                        padding : const EdgeInsets.all(10.0), // grandezza del pulsante restart
                        child : Icon(Icons.refresh, size : 30),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
      });
  }

  void checkWinner() {
    //check how many box to reveal
    int unrevealedBoxes = 0;
    for (int i = 0; i < numberOfSquares; i++) {
      if (squareStatus[i][1] == false) {
        unrevealedBoxes++;
      }
    }

    //if this number is the same as the number of bombs, then player WINS!
    if (unrevealedBoxes == bombLocation.length) {
      playerWon();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: Column(children: [
        //game stats and menu
        Container(
            height: 150,
            color: Colors.blue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // display number of bombs
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(bombLocation.length.toString(),
                        style: TextStyle(fontSize: 40)),
                    Text('B O M B'),
                  ],
                ),

                //button to refresh the game
                GestureDetector(
                  onTap: restartGame,
                  child: Card(
                      child: Icon(Icons.refresh, color: Colors.white, size: 40),
                      color: Colors.blue[700]),
                ),

                //display time taken
                
                Column(
                  
                )
              ],
            )),

        //grid
        Expanded(
          child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: numberOfSquares,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: numberInEachRow),
              itemBuilder: (context, index) {
                if (bombLocation.contains(index)) {
                  return MyBomb(
                    revealed: bombsRevealed,
                    function: () {
                      //utente che tocca la bomba, quindi perde
                      setState(() {
                        bombsRevealed = true;
                      });
                      playerLost();
                    },
                  );
                } else {
                  return MyNumberBox(
                    child: squareStatus[index][0],
                    revealed: squareStatus[index][1],
                    function: () {
                      //mostrare a casella vuoto
                      revealBoxNumbers(index);
                      checkWinner();
                    },
                  );
                }
              }),
        ),

        //branding Scrive la parte in basso del telefono
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: Text("Campo Minato"),
        )
      ]),
    );
  }
}