
class User {
  int id;
  final String name;
  final String phoneNumber;

  User({this.id, this.name, this.phoneNumber});

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'name' : name,
      'phoneNumber' : phoneNumber,
    };
  }

  factory User.fromMap(Map<String, dynamic> json) => new User(
    id: json["id"],
    name: json["name"],
    phoneNumber: json["phoneNumber"],
  );

  @override
  String toString() {
    return 'User{id: $id, name: $name, phoneNumber: $phoneNumber}';
  }

}