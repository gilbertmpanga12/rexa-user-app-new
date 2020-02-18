import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './chat_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  @override
  ChatScreenState createState() {
    return new ChatScreenState();
  }
}

class ChatScreenState extends State<ChatScreen> {
String mainFirebaseUID;

String defaultPicture = 'https://firebasestorage.googleapis.com/v0/b/esalonbusiness-d3f3d.appspot.com/o/avatar.png?alt=media&token=53503121-c01f-4450-a5cc-cf25e76f0697';
localStorage() async{
 SharedPreferences prefs = await SharedPreferences.getInstance();
 setState(() {
   mainFirebaseUID = prefs.getString('uid');
 });
}

String textClipper(String word){

  if(word.length > 40){
    return word.substring(0,35) + ' ....';
  }
  return word;
}

@override
  void initState() {
    localStorage();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
     
      body: StreamBuilder(builder: (context,snapshot){
         if(!snapshot.hasData){
            return Center(child: CircularProgressIndicator(),);
         }
  
        return ListView.builder(
      itemCount: snapshot.data.documents.length,
      itemBuilder: (context, index) {
        return new Container(height: 87.0,child: Column(
            children: <Widget>[
                SizedBox(height: 5.0),
              StreamBuilder(builder: (context,snapshotx){
                  if(!snapshotx.hasData){
                    return CircleAvatar(
                  radius: 22, // http://via.placeholder.com/350x150;
                  backgroundImage: NetworkImage('$defaultPicture'),
                );
                  }
                  return
              new ListTile(
                trailing: StreamBuilder(builder: (BuildContext context, scone){
                  if(!scone.hasData){
                    return SizedBox.shrink();
                  }
                  return Column(children: <Widget>[
                  SizedBox(height: 9.0,),
                  scone.data['date'] != null ? Text(DateFormat('jm')
                          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(scone.data['date']))),
                          style: TextStyle(color: scone.data['chatCount'] > 0 ? Colors.redAccent: Colors.grey,
                
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400),): SizedBox.shrink(),
                SizedBox(height: 4.0,),
                 scone.data['chatCount'] > 0 ? Container(
                    padding: EdgeInsets.all(2),
                    decoration: new BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${scone.data['chatCount']}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ): SizedBox.shrink(),
       
                ],);
                },stream: Firestore.instance.collection('LatestNotifications')
.document('${snapshotx.data['phoneNumber']}')
 .collection('new_nots').document('$mainFirebaseUID').snapshots(),),
                onTap: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context) => Chat(peerAvatar: '${snapshotx.data['profilePicture']}'
                  ,peerId: '${snapshotx.data['phoneNumber']}',fullName: '${snapshotx.data['fullName']}',
                  phoneNumber: '${snapshotx.data['phoneNumber']}',fcmToken: '${snapshotx.data['fcm_token']}',
                  status:  '${snapshot.data.documents[index]['current_status']}',currentStatus: snapshot.data.documents[index]['current_status'] == 'Online' ? ChatBarState.ACTIVE :ChatBarState.LASTSEEN
                  )));
                },
                leading:  CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage('${snapshotx.data['profilePicture'] ?? defaultPicture}'),
                )
                ,
                title: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                  
                   Padding(child:  new Text(
                      '${snapshotx.data['fullName']}',
                      style: new TextStyle(fontWeight: FontWeight.w700,fontSize: 17.0,
                      letterSpacing: .3,
                      color: Color(0xFF0a244d)),
                    ),padding: EdgeInsets.all(2.0)),
                    // Padding(child: new Text(
                    //   '${snapshotx.data['phoneNumber']}',
                    //   style: new TextStyle(color: Colors.grey, fontSize: 15.0),
                    // ),padding: EdgeInsets.all(2.0),),
                  ],
                ),
                subtitle: new Container(
                  padding: const EdgeInsets.only(top: 2.0,left: 3.0),
                  child: new Row(
                    children: <Widget>[
                    snapshot.data.documents[index]['last_message'] == 'Sent media' ? Icon(FontAwesomeIcons.image,size: 16.0,): SizedBox.shrink(),
                    Text(
                    '${snapshot.data.documents[index]['last_message'] == 'Sent media' ? ' ' + snapshot.data.documents[index]['last_message'] :  textClipper(snapshot.data.documents[index]['last_message'])}',
                    style: new TextStyle(color: snapshot.data.documents[index]['last_message'] == 'Typing...' ? Colors.green[700]: Colors.grey[700], fontSize: 15.0),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false
                  )
                    ],
                  ),
                ),
            );
              },
stream: Firestore.instance.collection('users')
                .document('${snapshot.data.documents[index]['phoneNumber']}').snapshots(),),
                 new Divider(
                height: 10.0,indent: 74.0,endIndent: 15.0,
              ),
            ],
          ),);
      }
    );
      },stream: Firestore.instance.collection('users').document('$mainFirebaseUID').collection('verified_contacts')
      .where('isChatted',isEqualTo: true).orderBy('date', descending: true).snapshots())
    );
  }
}