import 'package:localstore/localstore.dart';

class History {
  final String id;
  String board;
  String winner;
  String mode;
  History({
    required this.id,
    required this.board,
    required this.winner,
    required this.mode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'board': board,
      'winner': winner,
      'mode': mode,
    };
  }

  factory History.fromMap(Map<String, dynamic> map) {
    return History(
      id: map['id'],
      board: map['board'],
      winner: map['winner'],
      mode: map['mode'],
    );
  }
}

extension ExtHistory on History {
  Future save() async {
    final _db = Localstore.instance;
    return _db.collection('history').doc(id).set(toMap());
  }

  Future delete() async {
    final _db = Localstore.instance;
    return _db.collection('history').doc(id).delete();
  }
}
