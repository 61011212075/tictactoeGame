import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:tictactoe/Model/history_model.dart';
import 'package:tictactoe/Screen/game_screen.dart';

class HistoryScreen extends StatefulWidget {
  HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _db = Localstore.instance;
  final _items = <String, History>{};
  StreamSubscription<Map<String, dynamic>>? _subscription;
  late List<dynamic> _board;
  late double _sizeBox;
  int _selectedIndex = 0;
  @override
  void initState() {
    _subscription = _db.collection('history').stream.listen((event) {
      setState(() {
        final item = History.fromMap(event);
        _items.putIfAbsent(item.id, () => item);
      });
    });
    if (kIsWeb) _db.collection('todos').stream.asBroadcastStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty)
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
          backgroundColor: Colors.white,
          title: Text(
            "History Game",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Center(
            child: Text(
          "No Record",
          style: TextStyle(fontSize: 24),
        )),
      );
    setBoard(_selectedIndex);
    final deviceWidth = MediaQuery.of(context).size.width;
    _sizeBox = deviceWidth / (_board.length + 3.5) - 1;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        backgroundColor: Colors.white,
        title: Text(
          "History Game",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
                child: Text("Clear History"),
                onPressed: () => setState(() {
                      _items.forEach((key, value) {
                        _db.collection("history").doc(key).delete();
                      });
                      _items.clear();
                    })),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Column(
                  children: List.generate(_items.keys.length, (index) {
                    final key =
                        _items.keys.elementAt(_items.length - index - 1);
                    final item = _items[key]!;
                    _board = jsonDecode(item.board)!;
                    return Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              "Player " + item.winner + ": Winner",
                              style:
                                  TextStyle(color: getFieldColor(item.winner)),
                            ),
                            subtitle: Text("Mode : " +
                                item.mode +
                                "(" +
                                jsonDecode(item.board).length.toString() +
                                "x" +
                                jsonDecode(item.board).length.toString() +
                                ")"),
                            leading: Container(
                              child: Icon(
                                Icons.receipt_long_rounded,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                  children: List.generate(
                                      _board.length,
                                      (x) => Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(_board.length,
                                              (y) => buildField(x, y))))),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setBoard(int index) {
    final firstKey = _items.keys.elementAt(index);
    final firstBoardJson = _items[firstKey]!.board;
    List<dynamic> firstBoard = jsonDecode(firstBoardJson);
    _board = firstBoard;
  }

  Widget buildField(int x, int y) {
    final value = _board[x][y];
    final color = getFieldColor(value);

    return Container(
      margin: EdgeInsets.all(3),
      child: AbsorbPointer(
        absorbing: true,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(_sizeBox, _sizeBox),
            // fixedSize: Size(_sizeBox, _sizeBox),
            primary: color,
          ),
          child: Text(value, style: TextStyle(fontSize: 32)),
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_subscription != null) _subscription?.cancel();
    super.dispose();
  }
}
