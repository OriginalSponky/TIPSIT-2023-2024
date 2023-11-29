import 'dart:io';

late Socket socket;

void main() {
  Socket.connect("localhost", 50676).then((Socket sock) {
    socket = sock;
    socket.listen(dataHandler,
        onError: errorHandler, onDone: doneHandler, cancelOnError: false);
  }, onError: (e) {
    print("Unable to connect: $e");
    exit(1);
  });
  int n = 5;
   List<List<int>> matrix = List.generate(9, (row) => List.generate(9, (col) => 0));
  String co = "|   |   |   |   |   |   |   |   |   |";
  print("   A   B   C   D   E   F   G   H   I   ");
  print("1$co\n--\n2$co\n--\n3$co\n--\n4$co\n--\n5$co\n--\n6$co\n--\n7$co\n--\n8$co\n--\n9$co\n--");
  while(n>0){
  stdout.write('\nInserisci la posizione della barca n.$n: ');
    String? inputString = stdin.readLineSync();
    String str = posizione(inputString!);
    matrix[int.tryParse(str[0])!][int.tryParse(str[1])!] = 1;
    n--;
  }
  for (int i = 0; i < matrix.length; i++) {
    for (int j = 0; j < matrix[i].length; j++) {
      print(matrix[i][j]);
    }
    print('');
  }

  // connect standard in to the socket
  stdin
      .listen((data) => socket.write(String.fromCharCodes(data).trim() + '\n'));

  

}

void dataHandler(data) {
  print(String.fromCharCodes(data).trim());
}

void errorHandler(error, StackTrace trace) {
  print(error);
}

void doneHandler() {
  socket.destroy();
  exit(0);
}

String posizione(String xy) {
  String re = "";
  if(xy[0].toLowerCase() == "a"){
    re = "0";
  }else if(xy[0].toLowerCase() == "b"){
    re = "1";
  }else if(xy[0].toLowerCase() == "c"){
    re = "2";
  }else if(xy[0].toLowerCase() == "d"){
    re = "3";
  }else if(xy[0].toLowerCase() == "e"){
    re = "4";
  }else if(xy[0].toLowerCase() == "f"){
    re = "5";
  }else if(xy[0].toLowerCase() == "g"){
    re = "6";
  }else if(xy[0].toLowerCase() == "h"){
    re = "7";
  }else if(xy[0].toLowerCase() == "i"){
    re = "8";
  }
  int i = int.tryParse(xy[1])!;
  i--;
  re += i.toString();
  return re;
}