import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Communication',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final username = _emailController.text;
      final password = _passwordController.text;

      // Imposta l'URL dell'endpoint
      final url = 'http://192.168.1.11/P002_SmartCommunication/sito/serverRest.php/?action=login';

      // Prepara i dati per la richiesta POST
      final data = {
        'username': username,
        'password': password,
      };

      try {
        // Codifica i dati nel formato application/x-www-form-urlencoded
        final encodedData = data.entries
            .map((entry) => '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}')
            .join('&');

        // Esegui la richiesta POST
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: encodedData,
        );

        // Stampa il codice di stato e il corpo della risposta per il debug
        print('Codice di stato della risposta: ${response.statusCode}');
        print('Corpo della risposta: ${response.body}');

        if (response.statusCode == 200) {
          // Analizza la risposta JSON
          final responseData = json.decode(response.body);
          print('Login riuscito: $responseData');

          // Estrai i dati dal JSON
          final firstName = responseData['firstName'];
          final lastName = responseData['lastName'];
          final token = responseData['token'];
          final ident = responseData['ident'].substring(1, responseData['ident'].length - 1);

          // Naviga alla home page passando i dati ottenuti
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                firstName: firstName,
                lastName: lastName,
                token: token,
                ident: ident,
              ),
            ),
          );
        } else {
          // Errore nella richiesta: mostra un messaggio di errore
          print('Errore durante il login: ${response.statusCode}');
          print('Corpo della risposta: ${response.body}');
        }
      } catch (e) {
        // Gestisci eventuali errori durante la richiesta
        print('Errore durante la richiesta: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Communication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'ID/Email',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore, inserisci il tuo ID o Email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_passwordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore, inserisci la tua password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleLogin,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String ident;

  HomePage({
    required this.firstName,
    required this.lastName,
    required this.token,
    required this.ident,
  });

  void _navigateToBacheca(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BachecaPage(
          token: token,
          ident: ident,
        ),
      ),
    );
  }

  void _navigateToModuli(BuildContext context) {
    // Implementa la navigazione alla pagina dei moduli qui
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ciao $firstName $lastName',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _navigateToBacheca(context),
                  child: Text('Bacheca'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _navigateToModuli(context),
                  child: Text('Moduli'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BachecaPage extends StatefulWidget {
  final String token;
  final String ident;

  BachecaPage({required this.token, required this.ident});

  @override
  _BachecaPageState createState() => _BachecaPageState();
}

class _BachecaPageState extends State<BachecaPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _noticeBoardData = [];

  @override
  void initState() {
    super.initState();
    _fetchNoticeBoardData();
  }

  Future<void> _fetchNoticeBoardData() async {
    final url = 'http://192.168.1.11/P002_SmartCommunication/sito/serverRest.php/?action=noticeBoard';
    final data = {
      'id': widget.ident,
      'token': widget.token,
    };

    try {
      // Codifica i dati in formato URL
      final encodedData = data.entries
          .map((entry) => '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}')
          .join('&');

      // Richiesta POST
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: encodedData,
      );

      // Stampa per il debug
      print('Codice di stato della risposta: ${response.statusCode}');
      print('Corpo della risposta: ${response.body}');

      if (response.statusCode == 200) {
        // Decodifica della risposta JSON
        final responseData = json.decode(response.body);

        // Controlla che il campo 'notices' esista nella risposta JSON
        if (responseData.containsKey('notices')) {
          final List<dynamic> notices = responseData['notices'];

          // Mappa i dati della risposta nella lista `noticeBoardData`
          List<Map<String, dynamic>> noticeBoardData = [];
          for (var notice in notices) {
            Map<String, dynamic> noticeData = {
              'nameN': notice['nameN'],
              'num': notice['num'],
              'category': notice['category'],
              'dateN': notice['dateN'],
              'evtCode': notice['evtCode'],
            };
            noticeBoardData.add(noticeData);
          }

          // Aggiorna lo stato con i dati caricati
          setState(() {
            _noticeBoardData = noticeBoardData;
            _isLoading = false;
          });
        } else {
          // Se la chiave 'notices' non esiste nella risposta JSON, gestisci l'errore
          print('Chiave "notices" non trovata nella risposta JSON');
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        // Gestisci errori di risposta HTTP
        print('Errore durante la richiesta: ${response.statusCode}');
        print('Corpo della risposta: ${response.body}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Gestisci gli errori di richiesta
      print('Errore durante la richiesta: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bacheca'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Num')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Event Code')),
                ],
                rows: _noticeBoardData.map((data) {
                  return DataRow(cells: [
                    DataCell(Text(data['nameN'] ?? '')),
                    DataCell(Text(data['num'] ?? '')),
                    DataCell(Text(data['category'] ?? '')),
                    DataCell(Text(data['dateN'] ?? '')),
                    DataCell(Text(data['evtCode'] ?? '')),
                  ]);
                }).toList(),
              ),
            ),
    );
  }
}