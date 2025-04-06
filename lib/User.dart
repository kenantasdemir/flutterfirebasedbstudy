

class User{
  late int user_id;
  late String user_name;
  late int user_age;
  late int phonenumber;

  User({required user_age, required user_name, required phonenumber}){
    this.user_name = user_name;
    this.user_age = user_age;
    this.phonenumber = phonenumber;
  }



  factory User.fromMap(Map<dynamic, dynamic> map) {
    return User(
      user_age: map['user_age'] ?? 0,
      user_name: map['user_name'] ?? '',
      phonenumber: map['user_phone'] ?? '',
    );
  }


}
