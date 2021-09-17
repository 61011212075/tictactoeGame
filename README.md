# Tic-Tac-Toe-Game
## วิธีการ Setup และ Run โปรแกรม 
* การ Run สามารถดาวน์โหลดไปแล้ว Run ได้เลย
* การติดตั้งไฟล์ apk สำหรับมือถือ android หรือ simulator android ให้ดาวน์โหลดไฟล์ชื่อ app-release.apk ไปติดตั้งบนมือถือ android หรือ simulator android ได้เลย
## วิธีการเล่น 
* ภายในเกมจะมีให้เลือกเล่น2โหมดด้วยกัน
    * ผู้เล่น 2 คน
      - 3x3
      - 4x4
      - 5x5
    * เล่นกับ bot
      - 3x3
      - 4x4
      - 5x5
* เลือกโหมดไดโหมดหนึ่ง แล้วกดเริ่มเล่น
* วิธีการชนะ 3x3 "X"หรือ"O"จะต้องเรียงกัน3ตัว และถ้าตารางเต็มโดยไม่มีผู้ชนะ จะนับเป็นการเสมอกัน
* วิธีการชนะ 4x4 "X"หรือ"O"จะต้องเรียงกัน4ตัว และถ้าตารางเต็มโดยไม่มีผู้ชนะ จะนับเป็นการเสมอกัน
* วิธีการชนะ 5x5 "X"หรือ"O"จะต้องเรียงกัน4ตัว และถ้าตารางเต็มโดยไม่มีผู้ชนะ จะนับเป็นการเสมอกัน
* ถ้ามีการชนะ จะมีการเก็บคะแนน +1 เพิ่มขึ้นเลื่อยๆ เสมอก็เช่นกัน และผู้แพ้จะได้เริ่มก่อน
## วิธีการออกแบบ และ Algorithm ที่ใช้
* ใช้ Flutter Framework และใช้ภาษา Dart ในการพัฒนา
* สร้าง Player Model เพื่อให้ง่ายต่อการเรียกใช้
``` dart
    class Player {
     static const none = 'N';
     static const X = 'X';
     static const O = 'O';
   }
```
* สร้าง Matrix ตามขนาดที่ได้รับมา ``` widget.selectedSize  ``` คือ ขนาดที่ได้รับมา
``` dart
    void setEmptyFields() => setState(() => board = List.generate(
      widget.selectedSize,
      (index) => List.generate(widget.selectedSize, (index) => Player.none)));
```
* การเช็คเสมอ ถ้าทุกตัวนั้นไม่มีค่า Player.none(ค่าว่าง)แสดงว่ามีการเสมอ
``` dart
      bool isEnd() =>
      board.every((values) => values.every((value) => value != Player.none));
```
* การเช็คการชนะของเกม
   * การเช็คการชนะของเกม 3x3 โดยเช็คเฉพาะ row และ column ที่ ```player``` กด ```x``` = row และ ```y``` = column
 ```player``` คือผู้ที่กด โดยจะวน loop นับว่าเรียงกันเท่ากันกับ ```3``` หรือไม่ ถ้าเท่าก็จะ return true(ชนะ) ส่วนแนวทะแยงเช็คทุกแนว
``` dart
for (int i = 0; i < sizeBoard; i++) {
        if (board[x][i] == player) row++; //แนวนอน
        if (board[i][y] == player) col++; // แนวตั้ง
        if (board[i][i] == player) slop++; //แนวทะแยงจากซ้ายบนลงขวาล่าง
        if (board[i][3 - i - 1] == player) rslop++; //แนวทะแยงจากขวาบนลงล่างซ้าย
      }
      return row == 3 || col == 3 || slop == 3 || rslop == 3;
```
* การเช็คการชนะของเกม 4x4 และ 5x5 -> NxN
   *   การเช็คการชนะเหมือนกับของเกม 3x3 แต่แนวทะแยงจะเช็คเฉพาะแนวทะแยงที่ ```player``` กด
``` dart
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
```
* การเก็บ History ของเกม
   * ใช้ localstore 1.2.0
   * https://pub.dev/packages/localstore
