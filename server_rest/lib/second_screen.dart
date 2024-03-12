import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final TextEditingController _controller = TextEditingController();
  String _employeeDetails = '';
  static String serverAddress = '172.29.224.1';
  Future<void> _fetchEmployeeDetails(String code) async {
   
    final response = await http.get(Uri.parse('http://${serverAddress}/serverRest.php?codice=$code'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('stato')) {
        if (data['stato'] == 'OK-1') {
          setState(() {
            _employeeDetails = 'Nome: ${data["nome"]}\nCognome: ${data["cognome"]}\nReparto: ${data["reparto"]}';
          });
        } else if (data['stato'] == 'OK-2') {
          setState(() {
            _employeeDetails = data['messaggio'];
          });
        } else {
          setState(() {
            _employeeDetails = 'Risposta non valida dal server';
          });
        }
      } else {
        setState(() {
          _employeeDetails = 'Risposta non valida dal server';
        });
      }
      
      // Pulizia del TextField dopo aver inviato la richiesta
      setState(() {
        _controller.clear();
      });
    } else {
      setState(() {
        _employeeDetails = 'Impossibile recuperare i dettagli del dipendente';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inserisci il codice dipendente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Codice dipendente'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _fetchEmployeeDetails(_controller.text);
              },
              child: Text('Fetch'),
            ),
            SizedBox(height: 16.0),
            Text(_employeeDetails),
          ],
        ),
      ),
    );
  }
}
