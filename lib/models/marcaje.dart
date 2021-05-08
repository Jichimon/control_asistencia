
class Marcaje {
  int id;
  final DateTime date;
  final int userId;

  Marcaje({this.id, this.date, this.userId});

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'date' : date.toIso8601String(),
      'userId' : userId,
    };
  }


  factory Marcaje.fromMap(Map<String, dynamic> json) => new Marcaje(
    id: json["id"],
    date: DateTime.parse(json["date"]),
    userId: json["userId"],
  );

  @override
  String toString() {
    return 'Marcaje{id: $id, date: $date, userId: $userId}';
  }

}