import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:firebase_database/firebase_database.dart";
import 'package:flutterfirebasestudy/User.dart';
import "package:cloud_firestore/cloud_firestore.dart";

import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  FirebaseStudy()
    );
  }
}

DatabaseReference ref = FirebaseDatabase.instance.ref().child("users");

class FirebaseStudy extends StatelessWidget {
   FirebaseStudy({super.key});

   void remove35plusUsers()async{
     DatabaseEvent event = await ref.once();
     DataSnapshot snapshot = event.snapshot;

     if(snapshot.exists){
       Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;

  
       users.forEach((userId, userData) {
         if (userData['user_age'] == 35) {
           print('Yaşı 35 olan kullanıcı bulundu, ID: $userId');
           ref.child(userId).remove().then((_) {
             print('Kullanıcı $userId silindi.');
           }).catchError((error) {
             print('Hata: $error');
           });
         }
       });
     }
   }

   Future<void> getUserDocumentIdByEmail(String email) async {
     try {
       
       CollectionReference users = FirebaseFirestore.instance.collection('users');

       QuerySnapshot querySnapshot = await users.where('email', isEqualTo: email).get();

       if (querySnapshot.docs.isNotEmpty) {
 
         String documentId = querySnapshot.docs.first.id;
         print('Kullanıcı Document ID: $documentId');
       } else {
         print('Kullanıcı bulunamadı.');
       }
     } catch (e) {
       print('Hata: $e');
     }
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Firebase Study"),
      ),
      body: Center(
        child: Column(
          children: [
            OutlinedButton(onPressed: ()async{
              DatabaseEvent event = await ref.once();
              DataSnapshot snapshot = event.snapshot;

            
              if (snapshot.exists) {
                snapshot.children.forEach((childSnapshot) {
         
                  Map<String, dynamic> userData = Map<String, dynamic>.from(childSnapshot.value as Map);

                 
                  print('Kullanıcı Adı: ${userData['kisi_ad']}');
                  print('Kullanıcı Yaşı: ${userData['user_age']}');
                });
              } else {
                print('Veritabanında kullanıcı bulunamadı.');
              }
            }, child: Text("Tüm Veriler")),
            OutlinedButton(onPressed: ()async{
              var user = User(user_name: "Kenan",user_age: 30,phonenumber: 344242442);
              var newUser = {
                "kisi_ad": user.user_name,
                "user_age": user.user_age,
                "user_phone":user.phonenumber
              };

              ref.push().set(newUser);  // childByAutoId() yerine push() kullanılır.

            },child: Text("Ekle"),),
            OutlinedButton(onPressed: ()async{
              //ref.child("-OLCL3fsQMG4AQwKza35").remove();
              try {
                var query = ref.orderByChild('user_age').equalTo(25);

                // Veriyi çekme
                var snapshots = await query.once();

                var users = snapshots.snapshot.value as Map;
                users.forEach((key,value)=>{
                  ref.child(key).remove()
                });

              } catch (e) {
                print('Bir hata oluştu: $e');
              }
            }, child: Text("Sil")),
            OutlinedButton(onPressed: () async {
              try {
        
                var query = ref.orderByChild('user_age').startAt(18).endAt(60);

                var snapshots = await query.once();

          
                if (snapshots.snapshot.value != null) {
     
                  var users = snapshots.snapshot.value as Map<dynamic, dynamic>;

          
                  List<User> userList = [];
                  users.forEach((key, value) {
             
                    User user = User.fromMap(value);
                    userList.add(user);
                    print('Kullanıcı ID: $key, Yaş: ${user.user_age}, Ad: ${user.user_name}, Telefon: ${user.phonenumber}');
                  });
                } else {
                  print("Yaşı 18 ile 60 arasında olan kullanıcı bulunamadı.");
                }
              } catch (e) {
                print('Bir hata oluştu: $e');
              }



            }, child: Text("Filtrele")),
            OutlinedButton(onPressed: ()async {
                  DatabaseEvent event = await ref.orderByChild("user_age").equalTo(25).once();
                  DataSnapshot snapshot = event.snapshot;

                  if(snapshot.exists){
                    snapshot.children.forEach((childSnapshot){
                      String? userId = childSnapshot.key;

                      ref.child(userId!).update({
                        "user_age":27
                      });

                    });
                  }
            }, child: Text("Güncelle")),

            OutlinedButton(onPressed: ()async{
              DatabaseEvent event = await ref
                  .orderByChild("user_age")
                  .equalTo(27)
                  .limitToFirst(1)
                  .once();

              DataSnapshot snapshot = event.snapshot;

              if(snapshot.exists){
                snapshot.children.forEach((childSnapshot){
                  String userId = childSnapshot.key!; 
                  Map<String, dynamic> userData = Map<String, dynamic>.from(childSnapshot.value as Map); 
                  //debugPrint(userData.entries.first.toString());
                  print('Kullanıcı ID: $userId');
                  print('Kullanıcı Adı: ${userData['kisi_ad']}');
                  print('Kullanıcı Yaşı: ${userData['user_age']}');
                });
              }
            }, child: Text("Query Limit"))
          ],
        ),
      ),
    );
  }
}
