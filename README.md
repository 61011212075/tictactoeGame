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
* วิธีการชนะ 4x4 "X"หรือ"O"จะต้องเรียงกัน3ตัว และถ้าตารางเต็มโดยไม่มีผู้ชนะ จะนับเป็นการเสมอกัน
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
   * การเช็คการชนะของเกม 3x3
``` dart
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
```
   * การเช็คการชนะของเกม 4x4 และ 5x5
``` dart
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
```
* การเก็บ History ของเกม
   * ใช้ localstore 1.2.0
