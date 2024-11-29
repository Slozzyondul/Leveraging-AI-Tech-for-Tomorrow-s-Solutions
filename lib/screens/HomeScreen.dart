import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> disasterAlerts = [];

  Future<void> fetchAlerts() async {
    //final response = await http.get(Uri.parse('http://localhost:5000/alerts'));
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/alerts'));
    if (response.statusCode == 200) {
      setState(() {
        disasterAlerts = json.decode(response.body);
      });
    } else {
      print('Failed to load alerts');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAlerts();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Disaster Alerts')),
        backgroundColor: Colors.blue.shade500,
      ),
      body: disasterAlerts.isEmpty
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade500, Colors.black12],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
              ),
              child: const Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )))
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade500, Colors.black12],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
              ),
              child: ListView.builder(
                itemCount: disasterAlerts.length,
                itemBuilder: (context, index) {
                  final alert = disasterAlerts[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text(alert['type']),
                      subtitle: Text(
                          'Location: ${alert['location']}\nSeverity: ${alert['severity']}'),
                      trailing: Text(alert['date']),
                    ),
                  );
                },
              ),
            ),
    ));
  }
}
