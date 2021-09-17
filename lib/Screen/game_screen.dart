import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:tictactoe/Model/history_model.dart';
import 'package:tictactoe/Model/player_model.dart';
import 'package:tictactoe/miniMax.dart';
import 'package:tictactoe/properties.dart';

class GameScreen extends StatefulWidget {
  late int selectedSize;
  late String mode;
  GameScreen(this.selectedSize, this.mode, {Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<List<String>> board;
  String currentPlayer = Player.O;
  late double sizeBox;
  bool _disable = false;
  late double deviceWidth;
  final _db = Localstore.instance;
  int playerX_score = 0, playerO_score = 0, draw_score = 0;
  @override
  void initState() {
    super.initState();

    setEmptyFields();
  }

  void setEmptyFields() => setState(() => board = List.generate(
      widget.selectedSize,
      (index) => List.generate(widget.selectedSize, (index) => Player.none)));

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    sizeBox = deviceWidth / widget.selectedSize - 20; // 20 is space between box
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  showScore(Player.X, playerX_score),
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Text(
                          "Draw",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(draw_score.toString())
                      ],
                    ),
                  ),
                  showScore(Player.O, playerO_score)
                ],
              ),
              SizedBox(height: 60),
              Column(
                children: List.generate(board.length, (x) => buildRowBox(x)),
              ),
              Container(
                margin: const EdgeInsets.all(10.0),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: RichText(
                    text: TextSpan(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                      TextSpan(text: "Turn : "),
                      TextSpan(
                          text: nextPlayer(currentPlayer),
                          style: TextStyle(
                              color: getFieldColor(nextPlayer(currentPlayer))))
                    ])),
              ),
              SizedBox(height: 10),
              Container(
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 50),
                      primary: Colors.blue,
                    ),
                    onPressed: () => setState(() {
                          setEmptyFields();
                          if (currentPlayer == Player.X &&
                              widget.mode == mode_vsBotEasy)
                            setState(() {
                              Random random = new Random();
                              board[random.nextInt(widget.selectedSize)]
                                      [random.nextInt(widget.selectedSize)] =
                                  Player.O;
                              currentPlayer = Player.O;
                            });
                          _disable = false;
                        }),
                    icon: Icon(Icons.restart_alt),
                    label: Text("Reset",
                        style: TextStyle(fontSize: 24, color: Colors.white))),
              ),
              SizedBox(height: 10),
              Container(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(80, 40),
                    primary: Colors.white,
                  ),
                  child: Text("Home",
                      style: TextStyle(fontSize: 20, color: Colors.black)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRowBox(int x) {
    return Wrap(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(board.length, (y) => buildField(x, y)),
        ),
      ],
    );
  }

  Widget buildField(int x, int y) {
    final value = board[x][y];
    final color = getFieldColor(value);

    return Container(
      margin: EdgeInsets.all(5),
      child: AbsorbPointer(
        absorbing: _disable,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(sizeBox, sizeBox),
            primary: color,
          ),
          child: Text(value, style: TextStyle(fontSize: 32)),
          onPressed: () => selectField(value, x, y),
        ),
      ),
    );
  }

  void selectField(String value, int x, int y) async {
    if (value == Player.none) {
      String newValue = currentPlayer == Player.X ? Player.O : Player.X;

      setState(() {
        currentPlayer = newValue;
        board[x][y] = newValue;
      });

      if (isWinnerMai(x, y)) {
        if (currentPlayer == Player.X)
          playerX_score++;
        else
          playerO_score++;

        final id = Localstore.instance.collection('history').doc().id;
        final item = History(
            id: id,
            board: jsonEncode(board),
            winner: currentPlayer,
            mode: widget.mode);
        item.save();

        showEndDialog('Player $newValue Won');
        return;
      } else if (isEnd()) {
        draw_score++;
        showEndDialog('Undecided Game');
        return;
      }

      if (widget.mode == mode_vsBotEasy) {
        setState(() {
          // while (newValue == Player.X && !isEnd()) {
          //   Random random = new Random();
          //   x = random.nextInt(widget.selectedSize);
          //   y = random.nextInt(widget.selectedSize);
          //   if (board[x][y] == Player.none) {
          //     board[x][y] = Player.O;
          //     newValue = currentPlayer = Player.O;
          //     break;
          //   }
          // }
          List<List<String>> newBoard = new List<List<String>>.from(board);
          List<int> result = MiniMax().move(newBoard);
          x = result[0];
          y = result[1];
          board[x][y] = Player.O;
          newValue = currentPlayer = Player.O;
        });

        if (isWinnerMai(x, y)) {
          if (currentPlayer == Player.X)
            playerX_score++;
          else
            playerO_score++;

          final id = Localstore.instance.collection('history').doc().id;
          final item = History(
              id: id,
              board: jsonEncode(board),
              winner: currentPlayer,
              mode: widget.mode);
          item.save();
          showEndDialog('Player $newValue Won');
        } else if (isEnd()) {
          draw_score++;
          showEndDialog('Undecided Game');
        }
      }
    }
  }

  bool isEnd() =>
      board.every((values) => values.every((value) => value != Player.none));

  bool isWinner(int x, int y) {
    var col = 0, row = 0, slop = 0, rslop = 0;
    var brslop = 0, arslop = 0, bslop = 0, aslop = 0;
    final player = board[x][y];
    final sizeBoard = widget.selectedSize;
    final targetWin = sizeBoard <= 4 ? 3 : 4;

    if (sizeBoard == 3) {
      for (int i = 0; i < sizeBoard; i++) {
        if (board[x][i] == player) row++; //แนวนอน
        if (board[i][y] == player) col++; // แนวตั้ง
        if (board[i][i] == player) slop++; //แนวทะแยงจากซ้ายบนลงขวาล่าง
        if (board[i][sizeBoard - i - 1] == player)
          rslop++; //แนวทะแยงจากขวาบนลงล่างซ้าย
      }
      // ถ้านับอันใดอัน เท่ากับ targetWin จะ return true
      return row == targetWin ||
          col == targetWin ||
          slop == targetWin ||
          rslop == targetWin;
    } else {
      for (int i = 0; i < sizeBoard; i++) {
        //แนวนอน
        if (board[x][i] == player)
          row++;
        else {
          row = (row == targetWin)
              ? row
              : 0; //ถ้านับแล้วไม่ต่อเนื่องเริ่ม 0 ใหม่ ถ้าเท่ากับ targetWin แล้วจะไม่เปลี่ยนค่า
        }
        // แนวตั้ง
        if (board[i][y] == player)
          col++;
        else {
          col = (col == targetWin)
              ? col
              : 0; //ถ้านับแล้วไม่ต่อเนื่องเริ่ม 0 ใหม่ ถ้าเท่ากับ targetWin แล้วจะไม่เปลี่ยนค่า
        }
        //แนวทะแยงจากซ้ายบนลงขวาล่าง
        if (board[i][i] == player) {
          slop++;
        } else if (i < sizeBoard - 1) {
          if (board[i + 1][i] == player)
            bslop++; //แนวทะแยงจากซ้ายบนลงขวาล่าง ด้านสั้น
          if (board[i][i + 1] == player)
            aslop++; //แนวทะแยงจากซ้ายบนลงขวาล่าง ด้านสั้น
        } else {
          slop = (slop == targetWin)
              ? slop
              : 0; //ถ้านับแล้วไม่ต่อเนื่องเริ่ม 0 ใหม่ ถ้าเท่ากับ targetWin แล้วจะไม่เปลี่ยนค่า
        }
        //แนวทะแยงจากขวาบนลงล่างซ้าย
        if (board[i][sizeBoard - i - 1] == player) {
          rslop++;
        } else if (i < sizeBoard - 1) {
          if (board[i][sizeBoard - i - 2] == player)
            brslop++; //แนวทะแยงจากขวาบนลงล่างซ้าย ด้านสั้น
          if (board[i + 1][sizeBoard - i - 1] == player)
            arslop++; //แนวทะแยงจากขวาบนลงล่างซ้าย ด้านสั้น
        } else {
          rslop = (rslop == targetWin)
              ? rslop
              : 0; //ถ้านับแล้วไม่ต่อเนื่องเริ่ม 0 ใหม่ ถ้าเท่ากับ targetWin แล้วจะไม่เปลี่ยนค่า
        }
      }
      // ถ้านับอันใดอัน เท่ากับ targetWin จะ return true
      return row >= targetWin ||
          col >= targetWin ||
          slop >= targetWin ||
          rslop >= targetWin ||
          brslop >= targetWin ||
          arslop >= targetWin ||
          bslop >= targetWin ||
          aslop >= targetWin;
    }
  }

  bool isWinnerMai(int x, int y) {
    final player = board[x][y];
    int slop = 0, rslop = 0, col = 0, row = 0;
    final sizeBoard = widget.selectedSize;
    if (sizeBoard == 3) {
      for (int i = 0; i < sizeBoard; i++) {
        if (board[x][i] == player) row++; //แนวนอน
        if (board[i][y] == player) col++; // แนวตั้ง
        if (board[i][i] == player) slop++; //แนวทะแยงจากซ้ายบนลงขวาล่าง
        if (board[i][3 - i - 1] == player) rslop++; //แนวทะแยงจากขวาบนลงล่างซ้าย
      }
      return row == 3 || col == 3 || slop == 3 || rslop == 3;
    }

    //4x4 -> NxN
    for (int i = 0; i < sizeBoard; i++) {
      if (board[x][i] == player) row++; //แนวนอน
      if (board[i][y] == player) col++; // แนวตั้ง
    }
    //แนวทะแยงจากซ้ายบนลงขวาล่าง
    for (int i = 0; i < 4; i++) {
      if (x + i < board.length && y + i < board.length) {
        if (board[x + i][y + i] == player) {
          slop++;
        }
      } else {
        break;
      }
    }
    for (int i = 1; i < 4; i++) {
      if (x - i >= 0 && y - i >= 0) {
        if (board[x - i][y - i] == player) {
          slop++;
        }
      } else {
        break;
      }
    }

    //แนวทะแยงจากขวาบนลงล่างซ้าย
    for (int i = 0; i < 4; i++) {
      if (x + i < board.length && y - i >= 0) {
        if (board[x + i][y - i] == player) {
          rslop++;
        }
      } else {
        break;
      }
    }
    for (int i = 1; i < 4; i++) {
      if (x - i >= 0 && y + i < board.length) {
        if (board[x - i][y + i] == player) {
          rslop++;
        }
      } else {
        break;
      }
    }
    return row >= 4 || col >= 4 || slop >= 4 || rslop >= 4;
  }

  Future showEndDialog(String title) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: (title == "Undecided Game")
              ? Text('Press to Restart the Game')
              : Image.asset("assets/trophy.gif"),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _disable = true;
                });
                Navigator.of(context).pop();
              },
              child: Text('View Board'),
            ),
            ElevatedButton(
              onPressed: () {
                setEmptyFields();

                if (currentPlayer == Player.X && widget.mode == mode_vsBotEasy)
                  setState(() {
                    Random random = new Random();
                    board[random.nextInt(widget.selectedSize)]
                        [random.nextInt(widget.selectedSize)] = Player.O;
                    currentPlayer = Player.O;
                  });

                Navigator.of(context).pop();
              },
              child: Text('Restart'),
            )
          ],
        ),
      );

  String nextPlayer(String value) {
    switch (value) {
      case Player.O:
        return Player.X;
      case Player.X:
        return Player.O;
      default:
        return Player.X;
    }
  }

  Container showScore(String player, int score) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: RichText(
          text: TextSpan(
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              children: [
            TextSpan(text: "Player "),
            TextSpan(
                text: player + " \n",
                style: TextStyle(color: getFieldColor(player))),
            TextSpan(text: "Score : " + score.toString()),
          ])),
    );
  }
}

Color getFieldColor(String value) {
  switch (value) {
    case Player.O:
      return Colors.blue;
    case Player.X:
      return Colors.red;
    default:
      return Colors.white;
  }
}
