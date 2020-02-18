import 'package:flutter/material.dart';
import './allchats.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './add_contacts.dart';

class MainTabChat extends StatefulWidget {
  @override
  MainTabChatState createState() => MainTabChatState();
}

class MainTabChatState extends State<MainTabChat> {
  initState(){

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

   

  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        elevation: 3.0,
        actions: <Widget>[
        IconButton(icon: Icon(Icons.person_add),onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AllContacts()));
        },)
      ],
          title: Text(
            'Chats',
        style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w900,fontSize: 17),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
    ),body: ChatScreen(),);
  }
}


