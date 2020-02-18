import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';



class ViewProfile extends StatefulWidget{
  final String phoneNumber;
  final String fullName;
  ViewProfile({this.phoneNumber, this.fullName});
  @override
  ViewProfileState createState() => ViewProfileState();
}

class ViewProfileState extends State<ViewProfile> {
String phoneNumber = '';
String fullName;
  @override
  initState() {
    // Timer.periodic(Duration.millisecondsPerSecond(29) , () {
    //  localStorage();
    // });
    phoneNumber = widget.phoneNumber;
    fullName = widget.fullName;
    print('>>>>>>>>_+++++');
    print(phoneNumber);
    super.initState();

  }
 




  Widget build(BuildContext context){
    return Scaffold(
      appBar:  AppBar(
          title: Text(
            '${phoneNumber}',
    style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w900,fontSize: 17),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
      ),
        body: StreamBuilder(builder: (context,snapshot){
          print('Axrvis*****');
          if(!snapshot.hasData){
            return Center(child: CircularProgressIndicator(),);
          }

          return Column(
           mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
          children: <Widget>[
          Flexible(
fit: FlexFit.tight,
 flex: 280,
 child: Image.network(
"${snapshot.data['profilePicture']}", // ${snapshot.data['profilePicture']}
  fit: BoxFit.cover
)),
SizedBox(height: 20.0,),// changed here
Card(
  elevation: 5.0,
  child: Padding(padding: EdgeInsets.all(5.0),child: Container(
  height: 190.0,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
  Padding(
  child:SizedBox(child:  
  Text('About and phone number',style: 
  TextStyle(fontWeight: FontWeight.w900,
  fontSize: 19.0,
  fontFamily: 'Rukie',wordSpacing: -1),),
  width: 200.0,),
  padding: EdgeInsets.only(top:6.0,left: 17.0,bottom: 6.0),),
ListTile(
    leading: Icon(Icons.person),
    title: Text('${snapshot.data['fullName']}',style: TextStyle(fontSize: 14.8),),
),
Divider(),
ListTile(
        leading: Icon(Icons.info),
        title: Text('${snapshot.data['about'] ?? 'Status not available'}',
        style: TextStyle(fontSize: 14.8)),
)

],),),),)
        ]
,);
        },stream: Firestore.instance.collection('users').document('${phoneNumber}').snapshots(),)
);

  }
}
