import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://127.0.0.1:54093/ae_yWxs7UQA=/ws'), // Replace with the appropriate IP address and port of the Android TV
  );

  void _handleCommand(String command) {
    // Implementa la lógica para manejar el comando recibido desde la aplicación móvil
    switch (command) {
      case 'UP':
        // Lógica para el comando "Arriba"
        break;
      case 'DOWN':
        // Lógica para el comando "Abajo"
        break;
      // Agrega más casos para otros comandos según tus necesidades
      default:
        // Comando desconocido
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Android TV')),
        body: Center(
          child: StreamBuilder(
            stream: channel.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _handleCommand(snapshot.data);
              }
              return Text('Esperando comandos...');
            },
          ),
        ),
      ),
    );
  }
}
