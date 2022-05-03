import 'dart:io';

import 'package:flutter/cupertino.dart';

class MyWebSocketClient{
  late final WebSocket _ws;
  MyWebSocketClient({required String serverIp, required Function(dynamic data) onListener, required VoidCallback onConnected}){
    WebSocket.connect('ws://$serverIp:8000').then((webSocket) {
      _ws = webSocket;
      if (webSocket.readyState == WebSocket.open) {
        onConnected();

        webSocket.listen((data) {
            onListener(data);
          },
          onDone: () => print('[+]Done :)'),
          onError: (err) => print('[!]Error -- ${err.toString()}'),
          cancelOnError: true,
        );
      } else{
        print('[!]Connection Denied');
      }
      },
      onError: (err){
        print('On WebSocket Connect Error $err');
      },
    );
  }

  void sendData({required dynamic data}){
    if (_ws.readyState == WebSocket.open) {
      _ws.add(data);
    }
  }

  void close(){
    _ws.close();
  }
}