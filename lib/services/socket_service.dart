

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

enum ServerStatus {
  Online,
  Offline,
  Connecting
}

class SocketService with ChangeNotifier {

  ServerStatus _serverStatus = ServerStatus.Connecting;

  late Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;
  Socket get socket => this._socket;

  Function get emit => this._socket.emit;

  SocketService(){
    
    this._initConfig();
  }

  void _initConfig() {
    
    _socket = io(
      'http://10.0.2.2:3000',
      OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build());

    _socket.onConnect(( _ ) {
      print('Connect');
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    _socket.onDisconnect(( _ ) {
      print('Desconnect');
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    
    
  }

}