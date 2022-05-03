import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:test_client/d_web_socket/my_web_socket_client.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final MyWebSocketClient _myWebSocketClient;

  String _statusMessage = 'Not Connected';
  String _messageToSend = 'Hello From Client';
  String _responseMessage = 'Message';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();

  late String _serverIP;

  String _currentIP = '';

  @override
  void initState() {
    super.initState();

    _displayIP();
  }

  void _displayIP() async{
    _currentIP = await _getCurrentIp();
    setState(() {

    });
  }

  Future<String> _getCurrentIp() async {
    final List<NetworkInterface> connectedIps = await NetworkInterface.list();
    return connectedIps.first.addresses.first.address;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Current IP : $_currentIP', style: Theme.of(context).textTheme.headline4,),
                const Divider(),
                SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_statusMessage),
                      ElevatedButton(onPressed: (){
                        _showMyDialog();
                      }, child: const Text('Connect'),),
                    ],
                  ),
                ),
                const Divider(),
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text('Message')
                            ),
                            initialValue: _messageToSend,
                            onSaved: (value){
                              if(value == null){
                                return;
                              }
                              _messageToSend = value;
                            },
                            validator: (value){
                              if(value == null || value.isEmpty){
                                return 'Please Input Message';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const VerticalDivider(color: Colors.transparent,),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: SizedBox(
                          height: double.infinity,
                          width: 100,
                          child: ElevatedButton(
                            onPressed: (){
                              final FormState? form = _formKey.currentState;
                              if(form == null){
                                return;
                              }
                              if(form.validate()){
                                form.save();
                                _myWebSocketClient.sendData(data: json.encode(
                                    {
                                      'code': 3,
                                      'data': _messageToSend
                                    }));
                              }
                            },
                            child: const Text('Send'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.transparent,),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_responseMessage),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: (){
                    _myWebSocketClient.close();
                  },
                  child: const Text('Disconnect'),
                ),
                ElevatedButton(
                  onPressed: (){
                    _myWebSocketClient.sendData(data: json.encode({
                      'code': 2,
                      'data': 'Hello world',
                    }));
                  },
                  child: const Text('Print'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _connectToServer(){
    _myWebSocketClient = MyWebSocketClient(
        serverIp: _serverIP,
        onListener: (data){
          print(data);
          setState(() {
            _responseMessage = data;
          });
          //print('\t\t -- ${Map<String, String>.from(json.decode(data))}'); // listen for incoming data and show when it arrives
        },
        onConnected: (){
          _myWebSocketClient.sendData(data: json.encode({
            'code': 1,
            'data': 'Connected To Client 1',
          }));

          setState(() {
            _statusMessage = 'Connected';
          });
        }
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connect Printing Service'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey1,
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Server IP')
                    ),
                    initialValue: '192.168.0.137',
                    onSaved: (value){
                      if(value == null){
                        return;
                      }
                      _serverIP = value;
                    },
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Please Input Server IP';
                      }
                      return null;
                    },
                  ),
                  const Divider(color: Colors.transparent,),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (){
                        final FormState? form = _formKey1.currentState;
                        if(form == null){
                          return;
                        }
                        if(form.validate()){
                          form.save();
                          _connectToServer();
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Connect'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
