import 'dart:io';
import 'dart:typed_data';
import '../battleShipLibrary.dart';
import 'dart:convert';

late ServerSocket server;

void main() {
  ServerSocket.bind(InternetAddress.anyIPv4, 4567).then((ServerSocket socket) {
    server = socket;
    server.listen((client) {
      handlePlayerConnection(client);
    });
  });
}

int playersReady = 0;
List<Player> players = [];

void handlePlayerConnection(Socket socket) {
  print('Connection from '
      '${socket.remoteAddress.address}:${socket.remotePort}');

  if (players.length == 2) {
    var command = new GameCommand(serverIsBusy, -1, -1);
    String commandAsJson = jsonEncode(command);

    socket.write(commandAsJson);
    return;
  }

  players.add(new Player(socket));
  print('Number of active players : ' + players.length.toString());

  if (players.length == 1) {
    var command = new GameCommand(waitForPlayers, -1, -1);
    String commandAsJson = jsonEncode(command);
    socket.write(commandAsJson);
    return;
  }

  var command = new GameCommand(startGame, -1, -1);
  String commandAsJson = jsonEncode(command);

  // 2 players
  for (Player player in players) {
    player.write(commandAsJson);
  }
}

void sendCommandToOtherPlayer(Player player, GameCommand gameCommand) {
  var otherPlayer;
  for (Player p in players) {
    if (p != player) otherPlayer = p;
  }

  String commandAsJson = jsonEncode(gameCommand);
  otherPlayer.write(commandAsJson);
}

void removeClient(Player client) {
  players.remove(client);
}

void addPlayerReady() {
  playersReady++;
  if (playersReady == 2) {
    print("Let the game begin ");
    var command = new GameCommand(hitEnemyShip, -1, -1);
    String commandAsJson = jsonEncode(command);
    players[0].write(commandAsJson);
  }
}

class Player {
  late Socket _socket;
  late String _address;
  late int _port;

  Player(Socket s) {
    _socket = s;
    _address = _socket.remoteAddress.address;
    _port = _socket.remotePort;

    _socket.listen(handleCommand,
        onError: errorHandler, onDone: finishedHandler);
  }

  void handleCommand(Uint8List data) {
    String message = new String.fromCharCodes(data).trim();
    print(message);

    Map<String, dynamic> valueMap = json.decode(message);
    GameCommand command = GameCommand.fromJson(valueMap);

    // init ship
    if (command.commandId == playerReady) {
      addPlayerReady();
      return;
    }

    if (command.commandId == changePlayer) {
      var hitCommand = new GameCommand(hitEnemyShip, -1, -1);
      sendCommandToOtherPlayer(this, hitCommand);
      return;
    }
    // other commands
    sendCommandToOtherPlayer(this, command);
  }

  void errorHandler(error) {
    print('${_address}:${_port} Error: $error');
    removeClient(this);
    _socket.close();
  }

  void finishedHandler() {
    print('${_address}:${_port} Disconnected');
    removeClient(this);
    _socket.close();
  }

  void write(String message) {
    _socket.write(message);
  }
}
