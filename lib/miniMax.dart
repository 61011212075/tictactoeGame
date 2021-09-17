import 'dart:math';

import 'package:tictactoe/Model/player_model.dart';

class MiniMax {
  int _miniMax(
      List<List<String>> board, int dept, bool isMaximizing, int x, int y) {
    //check winer;
    if (isWinner(x, y, board)) {
      return board[x][y] == Player.O ? 100 : -100;
    } else if (isEnd(board)) return 0;

    int bestScore;
    if (isMaximizing) {
      bestScore = -1000;
      for (int i = 0; i < board.length; i++) {
        for (int j = 0; j < board.length; j++) {
          if (board[i][j] == Player.none) {
            board[i][j] = Player.O;
            int score = _miniMax(board, dept + 1, false, i, j);
            board[i][j] = Player.none;
            bestScore = max(score, bestScore);
          }
        }
      }
      return bestScore;
    } else {
      bestScore = 1000;
      for (int i = 0; i < board.length; i++) {
        for (int j = 0; j < board.length; j++) {
          if (board[i][j] == Player.none) {
            board[i][j] = Player.X;
            int score = _miniMax(board, dept + 1, true, i, j);
            board[i][j] = Player.none;
            bestScore = min(score, bestScore);
          }
        }
      }
      return bestScore;
    }
  }

  List<int> move(List<List<String>> board) {
    int bestScore = -1000;
    List<int> bestMove = [];

    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board.length; j++) {
        if (board[i][j] == Player.none) {
          board[i][j] = Player.O;

          int score = _miniMax(board, 0, false, i, j);
          board[i][j] = Player.none;
          if (score > bestScore) {
            bestScore = score;
            bestMove = [i, j];
          }
        }
      }
    }
    return bestMove;
  }

  bool isWinner(int x, int y, List<List<String>> board) {
    final player = board[x][y];
    int slop = 0, rslop = 0, col = 0, row = 0;

    if (board.length == 3) {
      for (int i = 0; i < board.length; i++) {
        if (board[x][i] == player) row++; //แนวนอน
        if (board[i][y] == player) col++; // แนวตั้ง
        if (board[i][i] == player) slop++; //แนวทะแยงจากซ้ายบนลงขวาล่าง
        if (board[i][3 - i - 1] == player) rslop++; //แนวทะแยงจากขวาบนลงล่างซ้าย
      }
      return row == 3 || col == 3 || slop == 3 || rslop == 3;
    }

    //4x4 -> NxN
    for (int i = 0; i < board.length; i++) {
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

  bool isEnd(List<List<String>> board) =>
      board.every((values) => values.every((value) => value != Player.none));
}
