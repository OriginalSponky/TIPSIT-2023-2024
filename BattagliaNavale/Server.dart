import 'dart:io';

// USE also netcat 127.0.0.1 3000

// global variable must be initialized later (null safety)
late Client client;

void main() {
  ServerSocket.bind(InternetAddress.anyIPv4, 50676).then((ServerSocket server) {
    print("server start");
    server.listen((socket) {
      handleConnection(socket);
    });
  });
}

void handleConnection(Socket socket) {
  client = Client(socket);
  print('client ' +
      Client.N.toString() +
      ' connected from ' +
      '${socket.remoteAddress.address}:${socket.remotePort}');
}

void messageHandler(data) {
  String message = String.fromCharCodes(data).trim();
  writeMessage(client, message);
}

void errorHandler(error) {
  print(' Error: $error');
  client.finishedHandler();
}

void finishedHandler() {
  client.finishedHandler();
}

void writeMessage(Client client, String message) {
  String str = message.toUpperCase();
  print('[' + client._n.toString() + ']: ' + str);
  client.write(str + '\n');
}

// the client

class Client {
  static int N = 0;

  late Socket _socket;
  String get _address => _socket.remoteAddress.address;
  int get _port => _socket.remotePort;
  late int _n;

  Client(Socket s) {
    _n = ++N;
    _socket = s;
    _socket.listen(messageHandler,
        onError: errorHandler, onDone: finishedHandler);
  }

  void messageHandler(data) {
    String message = String.fromCharCodes(data).trim();
    writeMessage(this, message);
  }

  void errorHandler(error) {
    print('${_address}:${_port} Error: $error');
    _socket.close();
  }

  void finishedHandler() {
    print('${_address}:${_port} Disconnected');
    _socket.close();
  }

  void write(String message) {
    _socket.write(message);
  }
}

