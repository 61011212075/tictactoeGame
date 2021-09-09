import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tictactoe/Screen/game_screen.dart';
import 'package:tictactoe/Screen/history_screen.dart';
import 'package:tictactoe/properties.dart';
import 'package:localstore/localstore.dart';

class MemuScreen extends StatefulWidget {
  MemuScreen({Key? key}) : super(key: key);

  @override
  _MemuScreenState createState() => _MemuScreenState();
}

class _MemuScreenState extends State<MemuScreen> {
  late double deviceWidth;
  late double sizeBox;
  final db = Localstore.instance;
  int _selectedSize = 3;
  int _size3x3 = 3;
  int _size4x4 = 4;
  int _size5x5 = 5;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    deviceWidth = MediaQuery.of(context).size.width;
    sizeBox = deviceWidth / 3 - 20;
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 50),
              Text("TIC TAC TOE",
                  style: TextStyle(
                      fontSize: 36,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 150),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  buildBoxMode(_size3x3),
                  buildBoxMode(_size4x4),
                  buildBoxMode(_size5x5),
                ],
              ),
              SizedBox(height: 60),
              Container(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 50),
                      primary: Colors.white,
                    ),
                    child: Text("2 Player",
                        style: TextStyle(fontSize: 24, color: Colors.black)),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                GameScreen(_selectedSize, mode_vsFriend)))),
              ),
              SizedBox(height: 25),
              Container(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 50),
                      primary: Colors.white,
                    ),
                    child: Text("VS Bot (Easy)",
                        style: TextStyle(fontSize: 24, color: Colors.black)),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                GameScreen(_selectedSize, mode_vsBotEasy)))),
              ),
              SizedBox(height: 25),
              Container(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 50),
                      primary: Colors.white,
                    ),
                    child: Text("History",
                        style: TextStyle(fontSize: 24, color: Colors.black)),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HistoryScreen()))),
              ),
              SizedBox(height: 25),
              Container(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 50),
                      primary: Colors.grey.shade300,
                    ),
                    child: Text("Exit",
                        style: TextStyle(fontSize: 24, color: Colors.black)),
                    onPressed: () => _showMyDialog()),
              ),
              SizedBox(height: 25),
            ],
          ),
        ),
      )),
    );
  }

  Widget buildBoxMode(int selectedMode) {
    return Container(
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(100, 50),
          primary: selectedMode == _selectedSize
              ? Colors.blue.shade400
              : Colors.blue.shade100,
        ),
        child: Text(selectedMode.toString() + "x" + selectedMode.toString(),
            style: TextStyle(fontSize: 24, color: Colors.black)),
        onPressed: () => setState(() {
          _selectedSize = selectedMode;
        }),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit Game'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Do you want to exit ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cencel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(child: const Text('Yes'), onPressed: () => exit(0)),
          ],
        );
      },
    );
  }
}
