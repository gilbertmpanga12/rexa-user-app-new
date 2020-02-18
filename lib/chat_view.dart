import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Elyte/watchvideo.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_utils/file_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';
import 'package:url_launcher/url_launcher.dart';
import './const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './view_contant_profile.dart';
import './viewfull_image.dart';
import './clip_r_thread.dart';
import 'package:http/http.dart' as http;

enum ChatBarState { ONLINE, OFFLINE, TYPING,ACTIVE,LASTSEEN }

 class Chat extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String fullName;
  final String phoneNumber;
  final String fcmToken;
  final String status;
  final ChatBarState currentStatus;
  Chat({Key key, @required this.peerId, @required this.peerAvatar,
  @required this.fullName,@required this.phoneNumber, this.fcmToken, this.status,
  this.currentStatus}) : super(key: key);
  
  @override
  ChatState createState() => new ChatState();
}


class ChatState extends State<Chat> {
  String phoneNumber;
  String fullName;
  String status = ' Yesterday';
  String peerAvatar;
  String peerId;
  String fcmToken;
  ChatBarState currentStatus = ChatBarState.LASTSEEN;
  Stream<DocumentSnapshot> statusListener;
  Stream<DocumentSnapshot> typingListener;
  SharedPreferences prefs;
  String userPhoneNumber;

  String getstatus(current_status) {
    String retdata = "";
    switch (current_status) {
      case ChatBarState.ONLINE:
        retdata = "Online";
        break;
      case ChatBarState.OFFLINE:
        retdata = "";
        break;
      case ChatBarState.TYPING:
        retdata = "Typing";
        break;
      case ChatBarState.ACTIVE:
        retdata = "Active";
        break;
      case ChatBarState.LASTSEEN:
        retdata = "Last Seen "+status;
        break;
    }
    return retdata;
  }
  @override
  initState(){
    activateMyStatus();
    phoneNumber = widget.phoneNumber;
    fullName = widget.fullName;
    // status = widget.status;
    peerAvatar = widget.peerAvatar;
    peerId = widget.peerId;
    fcmToken = widget.fcmToken;
    statusListener = Firestore.instance.collection('users').
document('$phoneNumber').snapshots();
typingListener = Firestore.instance.collection('users').
document(userPhoneNumber).collection('verified_contacts')
.document(phoneNumber).snapshots();
    OneSignal.shared.setNotificationReceivedHandler((OSNotification result) {
      if(result.payload.additionalData['peerAvatar'].toString().isNotEmpty){
setState(() {
          currentStatus = ChatBarState.ACTIVE;
       });
      }
      /*
      else{
        setState(() {
  currentStatus = ChatBarState.LASTSEEN;
  status = onData.data['current_status'];
   });
      }
      */

});



    super.initState();
    // checkTypingStatus();
    changeStatus();
  }

  checkTypingStatus(){
    typingListener.listen((onData){
      if(onData.data['current_status']== 'Typing...'){
        setState(() {

          currentStatus =  ChatBarState.ACTIVE; // changed from typing
        });
      }
    });
  }
  changeStatus() async {
    statusListener.listen((onData){
 if(onData.data['current_status'] == 'Online'){
  setState(() {
          currentStatus = ChatBarState.ACTIVE;
          // peerAvatar = onData.data['current_status'];
       }); 
 }else if(onData.data['current_status'] == null){
setState(() {
  //status =  onData.data['current_status'].toString();
  currentStatus = ChatBarState.OFFLINE;
    
   });
 }else {
   setState(() {
  status =  onData.data['current_status'].toString();
  currentStatus = ChatBarState.LASTSEEN;
    
   });
 }
});
  }

  activateMyStatus() async {
    prefs = await SharedPreferences.getInstance();
    // userPhoneNumber = '+256778845794';
  await Firestore.instance.collection('users').
document('${prefs.getString('uid')}').setData({'current_status': 'Online'}, merge: true);
  }

   Widget dropdownWidget(context) {
    return PopupMenuButton(itemBuilder: (BuildContext context){
      return [
    PopupMenuItem(child: Text('View Profile', style: TextStyle(fontFamily: 'NunitoSans',fontWeight: FontWeight.w500)),value: 'View Profile',),
  
      ];
    },onSelected: (val){
      if(val == 'View Profile'){
        print(phoneNumber);
Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfile(phoneNumber:phoneNumber,fullName: fullName,)));
      }else{
Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfile(phoneNumber:phoneNumber,fullName: fullName,)));
      }
    },);
  }

 show(BuildContext context){
   Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfile(phoneNumber:phoneNumber,fullName: fullName,)));
 }

 void call(String phone){
   launch("tel:$phone");
 }
@override
void dispose() {
  statusListener = null;
  typingListener = null;
  super.dispose();
  }
 Size get preferredSize => Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    // print('my profile pictyre $peerAvatar');
    return new Scaffold(backgroundColor: Colors.white,
      appBar: new PreferredSize(
        preferredSize: preferredSize,
        child: Container(
      decoration: new BoxDecoration(
        color: Colors.white,
        // gradient: null,
        boxShadow: [BoxShadow(color:Colors.grey,blurRadius:2.0)]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          BackButton(
            color: Colors.black,
          ),

          GestureDetector(child:ClipRRect(
              borderRadius: new BorderRadius.circular(30.0),
              child: CachedNetworkImage(
        imageUrl: "$peerAvatar",height: 45,width: 45,fit: BoxFit.cover,
        placeholder: (context, url) => Image.asset('assets/images/blah.png',height: 45,width: 45,),
        errorWidget: (context, url, error) => Image.asset('assets/images/blah.png',height: 45,width: 45,),
     )),onTap: (){
       show(context);
     },),

          SizedBox(
            width: 7.0,
          ),
          Expanded(
              flex:4,
              child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                '$fullName',
                style:  TextStyle(color: Colors.black, fontSize: 17,fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  getstatus(currentStatus), // getstatus(status)
                 style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                  textAlign: TextAlign.start,
                ),
              )
            ],
          )),
         
        ],
      ),

      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top: 25),
    ),),
      body: new ChatScreen(
        peerId: peerId,
        peerAvatar: peerAvatar,fullName: fullName,
phoneNumber: phoneNumber,
fcmToken: fcmToken,
      ),
    );
  }
}






class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String  fullName;
  final String phoneNumber;
  String _photoUrl;
  final String fcmToken;

  

  ChatScreen({Key key, @required this.peerId, @required this.peerAvatar,this.fullName,this.phoneNumber,this.fcmToken}) : super(key: key);

  @override
  State createState() => new ChatScreenState(peerId: peerId, peerAvatar: peerAvatar,fullName: fullName,phoneNumber: phoneNumber);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key, @required this.peerId, @required this.peerAvatar,@required this.fullName,@required this.phoneNumber});

  String peerId;
  String peerAvatar;
  String id;
  String fullName;
  String phoneNumber;
  

  var listMessage;
  String groupChatId;
  SharedPreferences prefs;
final isAlreadyDownloading = new Set();
  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;
  String actual_to;
  String actual_from;
  String _photoUrl;
  String uid;
  final r = 2.5;
  String defaultPicture = 'https://firebasestorage.googleapis.com/v0/b/esalonbusiness-d3f3d.appspot.com/o/avatar.png?alt=media&token=53503121-c01f-4450-a5cc-cf25e76f0697';
  String transactionalID;
  final TextEditingController textEditingController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();
  String actual_picture;
  String full_namer;
  String fcm_token;
  String targetFcm;
  final shouldTogglePlay = new Set();
    bool downloading = false;
    var progress = "";
    var path = "No Data";
    var platformVersion = "Unknown";
  @override
  void initState() {

    focusNode.addListener(onFocusChange);
    groupChatId = '';
    isLoading = false;
    isShowSticker = false;
    imageUrl = '';
    readLocal();
    deleteCount();
    textEditingController.addListener(() async {
      if(textEditingController.text.length > 0){
print('I am typing');
// await Firestore.instance.collection('users').document(actual_to).setData({
//   'current_status': 'Typing...'
// });
//     await Firestore.instance.collection('users').
// document(actual_from).collection('verified_contacts')
// .document(actual_to).setData({
//   'last_message':'Typing...'
// },merge: true);
      }
    });
    super.initState();
    
  }

  @override
  dispose(){
    textEditingController.dispose();
    super.dispose();
  }

 void deleteCount() async {
  prefs = await SharedPreferences.getInstance();

  await Firestore.instance.collection('LatestNotifications').document(phoneNumber)
 .collection('new_nots').document(prefs.getString('uid')).setData({
   'chatCount': 0,
 },merge: true);

  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  


  readLocal() async {
    targetFcm = '';
    prefs = await SharedPreferences.getInstance();
    actual_from = prefs.getString('phoneNumber');
    actual_to = phoneNumber;
    full_namer = prefs.getString('fullName');
    String _mergedIds = actual_from.substring(1,) + actual_to.substring(1,);
    List<String> splitted = _mergedIds.split('')..sort();
    transactionalID = splitted.join('');
    uid =  prefs.getString('uid');
    id = prefs.getString('uid');
    groupChatId = 'all_messages';
    fcm_token = prefs.getString('fcm_token');
    _photoUrl = prefs.getString('profilePicture') ?? defaultPicture;
   // Left (peer message)
      print('actual_to*********** ${actual_to}');
    // id = prefs.getString('id') ?? '';
    // if (id.hashCode <= peerId.hashCode) {
    //   groupChatId = '$id-$peerId';
    // } else {
    //   groupChatId = '$peerId-$id';
    // }
    // resetCount(); // reset count
    setState(() {});
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    
    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile(false);
    }
  }


   bottomSheet() {
    showModalBottomSheet(
shape:  RoundedRectangleBorder( // be back
         borderRadius: new BorderRadius.circular(25.0)),
elevation: 3.0,
backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Container(
            
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
            Container(margin: EdgeInsets.all(17.0),
              width: 150.0,child: RaisedButton(
                  child: Row(
                    children: <Widget>[
                      SizedBox(height: 16.0,),
                      Icon(Icons.file_upload,color: Colors.black,),
                      Text('Upload Image',
                          style: TextStyle(color: Colors.black))
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  onPressed: () {
                  getImage();
                    Navigator.pop(context);
                  },
                  color: Colors.white,
                  padding: EdgeInsets.all(14.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),
            ),
                Container(margin: EdgeInsets.all(10.0),
              width: 150.0,child: RaisedButton(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.video_label,color: Colors.black,),
                      Text(' Upload Video',
                          style: TextStyle(color: Colors.black))
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  onPressed: () async{
                 imageFile = await ImagePicker.pickVideo(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile(true);
      Navigator.pop(context);
    }
                  },
                  color: Colors.white,
                  padding: EdgeInsets.all(14.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),
            )
          ],),height: 170.0,);
        });
  }



requestServiceNotifier(String playerId, String contents, String headings,String chatUid,String transactionalID) async {
// prefs = await SharedPreferences.getInstance();
 OneSignal.shared.postNotificationWithJson({
  "include_player_ids" : [playerId],
  "contents" : {"en" : contents},
  "headings": {"en": headings},
  "small_icon": "@mipmap/ic_launcher",
  "large_icon": "@mipmap/ic_launcher",
  "data": {"peerAvatar": _photoUrl,
  "fullName":full_namer,
  "phoneNumber":actual_from,"peerId": actual_from}
}).then((onValue){
// for re-activating user if offline
//    Firestore.instance.collection('users').
// document('${prefs.getString('uid')}')
// .setData({'current_status': 'Online'}, merge: true);

//  Firestore.instance
//           .collection('users')
//           .document(transactionalID)
//           .collection('chats')
//           .document(chatUid).setData({'defaultVideo'});

final Map<String, dynamic> transcoderPayload = {
          'uid': transactionalID,
          'imageUrl': imageUrl,
          'isChat': true,
          'path': 'N/A',
          'messageId': chatUid
 };
      http.post('http://35.246.43.91/crucken-transcord',
            body: json.encode(transcoderPayload),
            headers: {
              "accept": "application/json",
              "content-type": "application/json"
   }).then((onValue){
print('done!');
            }).catchError((onError){
print('failed to transcord image');
            });
});
 
}





  Future getdocument() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.camera);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile(false);
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile(bool isVideo) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
  
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1,isVideo);
      });
      
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }



  void onSendMessage(String content, int type,bool isVideo) {
    if (content.trim() != '') {
      textEditingController.clear();
      String chatUid = DateTime.now().millisecondsSinceEpoch.toString();
      final defaultVideo = 'https://firebasestorage.googleapis.com/v0/b/esalonbusiness-d3f3d.appspot.com/o/snowyscreen.gif?alt=media&token=35458d60-5e73-4e7e-ae13-aad26ff095ec';
      var myMessages = Firestore.instance
          .collection('users')
          .document(transactionalID)
          .collection('chats')
          .document(chatUid);
  
        myMessages.setData({
            'idFrom': actual_from,
            'idTo': actual_to,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type,
            'isVideo': isVideo,
            'fullName': '${fullName}',
            'message_id': DateTime.now().millisecondsSinceEpoch.toString(),
            'path': 'N/A',
            'defaultVideo': defaultVideo
       }).then((sendingTo){
     Firestore.instance.collection('users').
document(actual_from).collection('verified_contacts')
.document(actual_to).setData({
  'last_message': content.contains('https://firebasestorage') ? 'Sent media' : content,
  'date': DateTime.now().millisecondsSinceEpoch.toString(),
  'peerAvatar': peerAvatar,
  'isChatted': true,
  'chatCount': FieldValue.increment(1),
  'fullName': '$fullName',
  'idTo': actual_to
}, merge: true).then((v) {
 Firestore.instance.collection('users').
document(actual_to).collection('verified_contacts')
.document(actual_from).setData({
  'last_message': content.contains('https://firebasestorage') ? 'Sent media' : content,
  'date': DateTime.now().millisecondsSinceEpoch.toString(),
  'isChatted': true,
  'phoneNumber': actual_from,
  'peerAvatar': '$actual_picture',
  'fullName': '$full_namer',
  'chatCount': FieldValue.increment(1),
  'idTo': actual_from,
  'current_status': 'Online'
},merge: true).then((e) async {
Firestore.instance.collection('LatestNotifications').document('${actual_from}')
 .collection('new_nots').document('${actual_to}').setData({
   'chatCount': FieldValue.increment(1),
  //  'profilePicture': '${actual_to}',
   'phoneNumber': '${actual_to}',
   'fullName': '${fullName}',
   'date': DateTime.now().millisecondsSinceEpoch.toString(),
  'current_status': 'Online'
 },merge: true).then((notification){
  //  requestServiceNotifier(targetFcm, content, '$full_namer');
 Firestore.instance.collection('users').document(actual_to).get().then((notsval){
  requestServiceNotifier('${notsval.data['fcm_token']}', content, '$full_namer .', chatUid,transactionalID); 
 });
 });
});
}).catchError((e){
  print(e);
});
       });

      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == actual_from) { // document['idFrom'] == actual_from
      // Right (my message)
      return Row(
        children: <Widget>[
          document['type'] == 0
              // Text
              ? ClipPath(
          // clipper: ClipLThread(r), // to be fixed
          child: ClipRRect(
            
            borderRadius: BorderRadius.all(Radius.circular(r)),
            child: Container(
             decoration:  BoxDecoration(
               borderRadius: BorderRadius.circular(8.0),
                color: greyColor2,
          
        
  ),
              margin: EdgeInsets.only(bottom:  10.0, right: 10.0),
              padding: EdgeInsets.fromLTRB(8.0 + 2 * r, 8.0, 8.0, 8.0),// 8.0 + 2 * r, 8.0, 8.0, 8.0,
              // color: Colors.white,
              child:  Container(child:  GestureDetector(
            onLongPress: () {
        Clipboard.setData(new ClipboardData(text: '${document['content']} '));
       Fluttertoast.showToast(
          msg: 'Copied!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.greenAccent,
          textColor: Colors.white
      );
      },
      child: RichText(
text: TextSpan(
    text: '${document['content']} ',
    style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,height: 1,fontFamily: ''),
    children: <TextSpan>[
  TextSpan(text: DateFormat('jm')
                          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']))), style: TextStyle(color: greyColor, fontSize: 12.0, fontStyle: FontStyle.italic, fontFamily: 'NunitoSans'))
    
    ],
  ),
)
      ),
              constraints:  BoxConstraints.tightFor(width:  '${document['content']} '.length.toDouble() > 200 ? 250 : '${document['content']} '.length.toDouble() < 25 ? 130.0 : '${document['content']} '.length.toDouble() < 15.0 ? 30.0: 200.0),),
            ),
          ),
        ) : document['type'] == 1 && document['isVideo'] == false
                  // Image
                  ? InkWell(child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                        Material(
                        
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(

                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                                ),
                                width: 200.0,
                                height: 200.0,
                                padding: EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                  color: greyColor2,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              ),
                          errorWidget: (context, url, error) => Material(
                                child: Image.asset(
                                  'images/img_not_available.jpeg',
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                          imageUrl: document['content'],
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      SelectableText(DateFormat('jm')
                          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']))),style: TextStyle(height: 1.2,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w100,fontStyle: FontStyle.italic, color: Colors.black54, fontFamily: 'NunitoSans'),)
                      ],),
                      margin: EdgeInsets.only(bottom: 10.0 , right: 18.0),// isLastMessageRight(index) ? 20.0 : 10.0
                    ),onTap: (){
                      // Here....
                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    ViewImage(
                                                                      photoUrl: document['content'],
                                                                      serviceName: document['idFrom'],
                                                                          isVideo: document['isVideo'],
                                                                    )));
                    },)
                  // Sticker
                  : InkWell(child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,children: <Widget>[
                          Container(
                          decoration: document['path'] != 'N/A' ? BoxDecoration(color: Colors.black,
                            borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                          ),
                            image: DecorationImage(image: NetworkImage('${document['defaultVideo']}'),fit: BoxFit.fill)): BoxDecoration(color: Colors.black,
                            borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                          ),
                            image: DecorationImage(image: NetworkImage('${document['pathAvailable']}'),fit: BoxFit.fill)),
                            child: Center(child: shouldTogglePlay.contains(index) && downloading ? Container(
                              height: 40.0,width: 40.0,
                              child: Stack(children: <Widget>[
                                                        Positioned(
                                                          left: progress == '100' ? 7.0 : 12.5,
                                                          top: 13.0,
                                                          child: Text('',style: TextStyle(fontSize: 15,
                                                          fontWeight: FontWeight.bold,color: Colors.white),),),
                                                        Container(child: CircularProgressIndicator(
                                                        valueColor: new AlwaysStoppedAnimation<Color>(Colors.yellow[800]),
                                                        strokeWidth: 3.0,
                                                        value: double.parse(progress) / 100,
                                                        backgroundColor: Colors.white,),width: 45,height: 45,)
                                                      ],),): Icon(Icons.play_circle_filled,color: Colors.white,size: 30.0,)), // has to feel here
                            height: 200.0,
                            width: 200.0,
                            margin: EdgeInsets.only(left: 4.0),
                          ),
                           SelectableText(DateFormat('jm')
                          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']))),style: TextStyle(height: 1.2,fontWeight: FontWeight.w200,fontStyle: FontStyle.italic, color: Colors.black54,fontFamily: 'NunitoSans'),)
                        ],),margin: EdgeInsets.only(right: 18.0),),onTap: (){
                  Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    WatchVideo(
                                                                      photoUrl: document['content'],
                                                                      serviceName: document['idFrom'],
                                                                          isVideo: document['isVideo'],
                                                                    )));
//                                 if('${document['path']}' == 'N/A'){
// downloadFile(document['content'],index,
//                                                               document['idFrom'],
//                                                               document['message_id']
//                                                               );
//                                 } else {
// Navigator.push(
//                                                         context,
//                                                         MaterialPageRoute(
//                                                             builder:
//                                                                 (context) =>
//                                                                     WatchVideo(
//                                                                       photoUrl: document['path'],
//                                                                       serviceName: document['idFrom'],
//                                                                           isVideo: document['isVideo'],
//                                                                     )));
//                                 }
                          },),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    }
     if(document['idFrom'] == actual_to) { // document['actual_from'] == actual_to // fails here
      print('Actual to..');
      print(phoneNumber);
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(width: 6.0,),
                document['type'] == 0
                    ? ClipPath(
      clipper: ClipRThread(r),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(r)),
        child: Container(
          //width: (50 + '${document['content']}'.length.toDouble()) < 200 ? (80 + '${document['content']}'.length.toDouble()) : 250,
          constraints:  BoxConstraints.tightFor(width:  '${document['content']} '.length.toDouble() > 200 ? 250 : '${document['content']} '.length.toDouble() < 25 ? 160.0 : '${document['content']} '.length.toDouble() < 15.0 ? 30.0: 200.0),
          padding: EdgeInsets.fromLTRB(8.0 + 2 * r, 8.0, 8.0, 8.0),
          color: primaryColor,
          child: GestureDetector(
      child: RichText(
text:  TextSpan(
    text: '${document['content']}  ',
    style: TextStyle(color: Colors.white,fontFamily: ''),
    children: <TextSpan>[
      TextSpan(text: DateFormat('jm')
                          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']))), style: TextStyle(color: greyColor, fontSize: 12.0, fontStyle: FontStyle.italic,fontFamily: 'NunitoSans' ))
    ],
  ),
),
      onLongPress: () {
        Clipboard.setData(new ClipboardData(text: '${document['content']}  '));
       Fluttertoast.showToast(
          msg: 'Copied!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.greenAccent,
          textColor: Colors.white
      );
      },
),
        ),
      ),
    )
                    : document['type'] == 1 && document['isVideo'] == false
                        ? InkWell(child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                          Container(
                            child: Material(
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                                      ),
                                      width: 200.0,
                                      height: 200.0,
                                      padding: EdgeInsets.all(70.0),
                                      decoration: BoxDecoration(
                                        color: greyColor2,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                errorWidget: (context, url, error) => Material(
                                child: Image.asset(
                                  'images/img_not_available.jpeg',
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                                imageUrl: document['content'],
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            margin: EdgeInsets.only(left: 4.0),
                          ),
                          SelectableText(
                      DateFormat('jm')
                          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']))),
                      style: TextStyle(color: greyColor, fontSize: 12.0, fontStyle: FontStyle.italic, fontFamily: 'NunitoSans'),
                    )

                        ],),onTap: (){
                            // Toy
                             Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    ViewImage(
                                                                      photoUrl: document['content'],
                                                                      serviceName: document['idFrom'],
                                                                          isVideo: document['isVideo'],
                                                                    )));
                          },)
                        : InkWell(child: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                          ),color: Colors.black),
                            child: Center(child: shouldTogglePlay.contains(index) && downloading ?Stack(children: <Widget>[
                                                        Positioned(
                                                          left: progress == '100' ? 7.0 : 12.5,
                                                          top: 13.0,
                                                          child: Text('${progress}%', style: TextStyle(fontSize: 15,
                                                          fontWeight: FontWeight.bold),),),
                                                        Container(child: CircularProgressIndicator(
                                                        valueColor: new AlwaysStoppedAnimation<Color>(Colors.yellow[800]),
                                                        strokeWidth: 3.0,
                                                        value: double.parse(progress) / 100,
                                                        backgroundColor: Colors.white,),width: 45,height: 45,)
                                                      ],): Icon(Icons.play_circle_filled,color: Colors.white,size: 30.0,)),
                            height: 200.0,
                            width: 200.0,
                            margin: EdgeInsets.only(left: 4.0), // pinned
                          ),onTap: (){

//                                 if('${document['path']}' == 'N/A'){
// downloadFile(document['content'],index,
// document['idFrom'],
// document['message_id']
//  );
//                                 } else {
// Navigator.push(
//                                                         context,
//                                                         MaterialPageRoute(
//                                                             builder:
//                                                                 (context) =>
//                                                                     WatchVideo(
//                                                                       photoUrl: document['content'],
//                                                                       serviceName: document['idFrom'],
//                                                                           isVideo: document['isVideo'],
//                                                                     )));
//                                 }
                       Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    WatchVideo(
                                                                      photoUrl: document['content'],
                                                                      serviceName: document['idFrom'],
                                                                          isVideo: document['isVideo'],
                                                                    )));     
                          },),
              ],
            ),
/*
DateFormat('dd MMM kk:mm')
                          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp'])))
*/
            // Time
            document['isVideo'] == false ? Container(
                    child: Text(
                      '',
                      style: TextStyle(color: greyColor, fontSize: 12.0, fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 10.0, top: 5.0, bottom: 5.0),
                  ): Container()
           
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) { // to be edited 
    if ((index > 0 && listMessage != null && listMessage[index - 1]['idFrom'] == actual_to) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) { // to be edited
    if ((index > 0 && listMessage != null && listMessage[index - 1]['idFrom'] != actual_from) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),
              // Sticker
              (isShowSticker ? buildSticker() : Container()),

              // Input content
              buildInput(),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildSticker() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2,false),
                child: new Image.asset(
                  'images/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', 2, false),
                child: new Image.asset(
                  'images/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', 2, false),
                child: new Image.asset(
                  'images/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi4', 2, false),
                child: new Image.asset(
                  'images/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi5', 2, false),
                child: new Image.asset(
                  'images/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi6', 2, false),
                child: new Image.asset(
                  'images/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi7', 2, false),
                child: new Image.asset(
                  'images/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi8', 2,false),
                child: new Image.asset(
                  'images/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi9', 2, false),
                child: new Image.asset(
                  'images/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: new BoxDecoration(
          border: new Border(top: new BorderSide(color: greyColor2, width: 0.5)), color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(FontAwesomeIcons.image),
                onPressed: bottomSheet,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
           Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(FontAwesomeIcons.camera),
                onPressed: getdocument,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Flexible(
            child: Container(
              child: TextField(
                keyboardType: TextInputType.multiline,
        minLines: 1,
        maxLines: null,
                style: TextStyle(color: primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(FontAwesomeIcons.paperPlane),
                onPressed: () => onSendMessage(textEditingController.text, 0,false),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border: new Border(top: new BorderSide(color: greyColor2, width: 0.5)), color: Colors.white),
    );
  }




askPermisionStorage() async {
  PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted && permission != PermissionStatus.disabled) {
      Map<PermissionGroup, PermissionStatus> permissionStatus = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      return permissionStatus[PermissionGroup.storage] ?? PermissionStatus.unknown;
      
    } else {
      return permission;
    }
}

void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to storage denied",
          details: null);
    } else if (permissionStatus == PermissionStatus.disabled) {
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Storage is not available on device",
          details: null);
    }
  }


// video file downloder
downloadFile(String url,int index,String fullName, String docId) async {
  setState(() {
    shouldTogglePlay.add(index); // imediately show downloder con
    downloading = true;
    progress = '1';
  });
  var userMessages = Firestore.instance

          .collection('users')
          .document(transactionalID)
          .collection('chats')
          .document(docId);
  Dio dio = Dio();
  PermissionStatus permissionStatus = await askPermisionStorage();
   if (permissionStatus == PermissionStatus.granted) {
       String dirloc = "";
        if (Platform.isAndroid) {
          dirloc = (await getExternalStorageDirectory()).path;
        } else {
          dirloc = (await getExternalStorageDirectory()).path;
        }

        var randid = '/' + randomAlpha(5);
        try{
        
          FileUtils.mkdir([dirloc]);
          if(isAlreadyDownloading.contains(index)){
            return null;
          }else{
            await dio.download(url, dirloc + randid + ".mp4",
              onReceiveProgress: (receivedBytes, totalBytes) {
                isAlreadyDownloading.add(index);
            setState(() {
              progress =
                  ((receivedBytes / totalBytes) * 100).toStringAsFixed(0);
            });

            if (progress == '100') {
               isAlreadyDownloading.remove(index);
           }
          });
          }
        }catch(err){
         print(err);
        }
        // set the path and navigate to watch video
      path = dirloc + randid + ".mp4";
       Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    WatchVideo(
                                                          serviceName: fullName,
                                                          photoUrl: path,
                                                          isVideo: true,
 )));
 // store path to db
   userMessages.setData({'path':path},merge: true);
   if(mounted){
      setState((){
        downloading = false; // honcho
      });
    }
   }else{
     _handleInvalidPermissions(permissionStatus);
   }
 }




  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document('$transactionalID')
                  .collection('chats')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
                } else {
                  listMessage = snapshot.data.documents;
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) => buildItem(index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }
}

