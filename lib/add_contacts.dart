import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
// import './chat_view.dart';
// import './app_services/auth_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:flushbar/flushbar.dart';
import './chat_view.dart';



class CustomSearchDelegate extends SearchDelegate {
  Iterable<Contact> _contacts;
  Set inviter = new Set();
  String firebaseUid;
  String userName;
  String my_number;
   Flushbar flashbar;

  bool shouldShow =true;
  CustomSearchDelegate({this.firebaseUid, this.userName, this.my_number});
  String rexaUrl = 'https://play.google.com/store/apps/details?id=esalonuser.esalonuser.esalonuser';
  String defaultPicture =  'https://firebasestorage.googleapis.com/v0/b/esalonbusiness-d3f3d.appspot.com/o/avatar.png?alt=media&token=53503121-c01f-4450-a5cc-cf25e76f0697';
  updateContact()  async{
    print('inside search ....');
  
     if(query.length > 3){
         Iterable<Contact> searched = await ContactsService.getContacts(query : "$query");
     _contacts = searched;
       
     }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }


_launchURL(String activityType, String payload) async {
   print(payload);
  final url = activityType == 'text' ? 'sms:$payload?body=Invitation from Rexa to chat via rexa $rexaUrl' : 'whatsapp://send?phone=$payload&text=$userName has invited you to chat via rexa $rexaUrl';
  Clipboard.setData(ClipboardData(text: '$rexaUrl'));
  print(url);
  if (await canLaunch(url)) {
    await launch(url, universalLinksOnly: true); // ,forceWebView: true,enableJavaScript: true
  } else {
    // Toast.show('Oops!, website not listed by service provider.', context, duration: 7,backgroundColor: Colors.red); // Locator
  }
}

  void _settingModalBottomSheet(context,String paramsi) {
    showModalBottomSheet(elevation: 3.0,backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Container(height: 190.0,child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 30.0),
            Container(margin: EdgeInsets.all(10.0) ,child: FloatingActionButton(backgroundColor: Color(0xFF25D366),// 0xffb74093
                  child: Icon(FontAwesomeIcons.whatsapp,color: Colors.white,),
                  onPressed: (){
       _launchURL('whatsapp', '${paramsi}');
                  },
             
                ),),
            Container(margin: EdgeInsets.all(10.0) ,child: FloatingActionButton(backgroundColor: Colors.blueAccent,
                  child: Icon(FontAwesomeIcons.sms,color: Colors.white,),
                  onPressed: (){
        _launchURL('text', '${paramsi}');
                  },
             
                ),)
            
          ],),);
        });
  }


  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // if (query.length < 3) {
    //   return Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: <Widget>[
    //       Center(
    //         child: Text(
    //           "Search full number",
    //         ),
    //       )
    //     ],
    //   );
    // }
    
    //Add the search term to the searchBloc. 
    //The Bloc will then handle the searching and add the results to the searchResults stream.
    //This is the equivalent of submitting the search term to whatever search service you are using
    print(query);
    

    return Center(child: Text('Looking up contacts...'),);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    updateContact();
    
    // This method is called everytime the search term changes. 
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
   return SafeArea(
        child: _contacts != null
            ? ListView.builder(
          itemCount: _contacts?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            Contact c = _contacts?.elementAt(index);
            return ListTile(
              onTap: () async{
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  var countryCode = prefs.getString('iso_code') ?? '+256';
                var _phoneNumber = c.phones.toList().first.value.
             toString().split(' ').join('').replaceAll(new RegExp(r'[!@#,<>?":_`~;[\]\\|=+)(*&^%-]'),'');
             String actual_number;
              print(_phoneNumber);
             if(_phoneNumber.length == 10){
                print('I am called otttttt*');
                print('${countryCode + _phoneNumber.substring(1,)}');
                actual_number = countryCode + _phoneNumber.substring(1,);
                actual_number;
             }else if(_phoneNumber.length > 10){
              
               actual_number = '+' + _phoneNumber;
                print('I am called u* $actual_number');
                actual_number;
             }
            flashbar = Flushbar(
                  mainButton: FlatButton(
        onPressed: () {
          flashbar.dismiss();
        },
        child: Text(
          "UNDO",
          style: TextStyle(color: Colors.amber),
        ),
      ),
                  title:  "Inviting ${c.displayName}",
                  message:  "Please wait...",
                  duration:  Duration(minutes: 2),              
                )..show(context);
             Firestore.instance.collection('users')
                                .document('${actual_number}').get().then((user) {
                                    if(user.exists){
                                      flashbar.dismiss();
                                      Firestore.instance.
          collection('users').document('${my_number}')
          .collection('verified_contacts').document('${actual_number}').setData({
            'isRegistered:': false,
            'last_message': '',
            'fullName': user.data['fullName'],
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'isChatted': true,
            'phoneNumber': user.data['phoneNumber'],
            'peerAvatar': user.data['profilePicure'],
            'date': DateTime.now().millisecondsSinceEpoch.toString()
          },merge: true).then((resp) {
            print('done');
            Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Chat(
                                            peerAvatar:
                                                '${user.data['profilePicture']}',
                                            fullName:
                                                '${user.data['fullName']}',
                                            phoneNumber:
                                                '${user.data['phoneNumber']}',
                                            peerId:
                                                '${user.data['phoneNumber']}',
                                          )));
          }); 
              

                                    }else{
                               flashbar.dismiss();
                                  _settingModalBottomSheet(context,'${actual_number}');
                                    }
                                });
               
              },
              leading: (c.avatar != null && c.avatar.length > 0)
                  ? CircleAvatar(backgroundImage: MemoryImage(c.avatar))
                  : CircleAvatar(child: Text(c.initials())),
              title: Text(c.displayName ?? "")

            );
          },
        )
            : Center(child: CircularProgressIndicator(),),
      );
  }
}


class AllContacts extends StatefulWidget {
  @override
  AllContactsState createState() {
    return new AllContactsState();
  }
}

class AllContactsState extends State<AllContacts> {
  String invite = 'Invite';
  Set inviter = new Set();
  String getcontacts = 'Get Contacts';
  bool isDone = false;
  String uid;
  String defaultPicture = 'https://firebasestorage.googleapis.com/v0/b/esalonbusiness-d3f3d.appspot.com/o/avatar.png?alt=media&token=53503121-c01f-4450-a5cc-cf25e76f0697';
  Iterable<Contact> _contacts;
  String firebaseUid;
  String rexaUrl = 'https://play.google.com/store/apps/details?id=esalonuser.esalonuser.esalonuser';
  List<Map<String,dynamic>> allContacts = new List();
  String userName;
  String countryCode;
  bool showBanner = false;
  String my_number;
  Flushbar flashbar;
   


 localStorage() async{
   SharedPreferences prefs = await SharedPreferences.getInstance();
   userName = prefs.getString('fullName');
   my_number = prefs.getString('uid');
   countryCode = prefs.getString('iso_code') ?? '+256';
   if(userName == null){
     Firestore.instance.collection('users').document(prefs.getString('uid')).get().then((resp){
       userName = resp.data['fullName'];
     }).catchError((onError){
       userName = prefs.getString('fullName') ?? 'A rexa user';
     });
   }
    setState(() {
      firebaseUid = prefs.getString('uid');
    });
    print('current firebase uid ******************');
    print(prefs.getString('uid'));
 }


 _launchURL(String activityType, String payload) async {
   print(payload);
  final url = activityType == 'text' ? 'sms:$payload?body=$userName has invited you to chat via rexa $rexaUrl' : 'whatsapp://send?phone=$payload&text=$userName has invited you to chat via rexa $rexaUrl';
  Clipboard.setData(ClipboardData(text: '$rexaUrl'));
  print(url);
  if (await canLaunch(url)) {
    await launch(url, universalLinksOnly: true); // ,forceWebView: true,enableJavaScript: true
  } else {
    Toast.show('Oops!, website not listed by service provider.', context, duration: 7,backgroundColor: Colors.red); // Locator
  }
}

void _settingModalBottomSheet(context,String paramsi) {
    showModalBottomSheet(elevation: 3.0,backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Container(height: 190.0,child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 30.0),
            Container(margin: EdgeInsets.all(10.0) ,child: FloatingActionButton(backgroundColor: Color(0xFF25D366),// 0xffb74093
                  child: Icon(FontAwesomeIcons.whatsapp,color: Colors.white,),
                  onPressed: (){
       _launchURL('whatsapp', '${paramsi}');
                  },
             
                ),),
            Container(margin: EdgeInsets.all(10.0) ,child: FloatingActionButton(backgroundColor: Colors.blueAccent,
                  child: Icon(FontAwesomeIcons.sms,color: Colors.white,),
                  onPressed: (){
        _launchURL('text', '${paramsi}');
                  },
             
                ),)
            
          ],),);
        });
  }


refreshContacts() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      var contacts = await ContactsService.getContacts();
       setState(() {
        _contacts = contacts;
      });

    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

   

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted && permission != PermissionStatus.disabled) {
      Map<PermissionGroup, PermissionStatus> permissionStatus = await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
      return permissionStatus[PermissionGroup.contacts] ?? PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

   void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to location data denied",
          details: null);
    } else if (permissionStatus == PermissionStatus.disabled) {
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }
  

  saveContacts(contacts, uid) async {
  
    var _payload = json.encode({'contacts': allContacts, 'uid': uid});
    final response = await http.post(
        'https://viking-250012.appspot.com/register-phone-contacts',
        body: _payload,
        headers: {
          "accept": "application/json",
          "content-type": "application/json"
        });

    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        _contacts =  json.decode(response.body);
      });
      print(_contacts);
      Toast.show('Contacts synced succcessfully!', context,
          duration: 8, backgroundColor: Colors.green);
    } else {
      Toast.show('Oops something went wrong try again!', context,
          duration: 8, backgroundColor: Colors.red);
    }
  }

  @override
  void initState() {
    localStorage();
    refreshContacts();
    super.initState();
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(
          'Import Contacts',
  style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w900,fontSize: 17),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        elevation: 1.5,
        actions: <Widget>[
          IconButton(onPressed: (){
            showSearch(context: context,delegate: CustomSearchDelegate(firebaseUid: firebaseUid,userName: userName,my_number: my_number));
          },icon: Icon(Icons.search),)
        ],
      ),
      body: SafeArea(
        child: _contacts != null
            ? ListView.builder(
          itemCount: _contacts?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            Contact c = _contacts?.elementAt(index);
            print(c.company);
            return ListTile(
              onTap: () {
                if(mounted){
                  setState(() {
                  showBanner = true;
                });
                }
             var _phoneNumber = c.phones.toList().first.value.
             toString().split(' ').join('').replaceAll(new RegExp(r'[!@#,<>?":_`~;[\]\\|=+)(*&^%-]'),'');
             String actual_number;
              print(_phoneNumber);
             if(_phoneNumber.length == 10){
                print('I am called otttttt*');
                print('${countryCode + _phoneNumber.substring(1,)}');
                actual_number = countryCode + _phoneNumber.substring(1,);
                actual_number;
             }else if(_phoneNumber.length > 10){
              
               actual_number = '+' + _phoneNumber;
                print('I am called u* $actual_number');
                actual_number;
             }
          flashbar =    Flushbar(
                    mainButton: FlatButton(
        onPressed: () {
          flashbar.dismiss();
        },
        child: Text(
          "UNDO",
          style: TextStyle(color: Colors.amber),
        ),
      ),
                  title:  "Inviting ${c.displayName}",
                  message:  "Please wait...",
                  duration:  Duration(seconds: 5),              
                )..show(context);
             Firestore.instance.collection('users')
                                .document('${actual_number}').get().then((user) {

                                  if(user.exists == false){
                                    flashbar.dismiss();
                               if(mounted){
                                       setState(() {
                          inviter.remove(index);
                  
                        });
                               }
                                  _settingModalBottomSheet(context,'${actual_number}');
                                  }

                                    if(user.exists){
                                       flashbar.dismiss();
              setState(() {
                          inviter.remove(index);
                 
                        });

                        Firestore.instance.
          collection('users').document('${my_number}')
          .collection('verified_contacts').document('${actual_number}').setData({
            'isRegistered:': false,
            'last_message': '',
            'fullName': user.data['fullName'],
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'isChatted': true,
            'phoneNumber': user.data['phoneNumber'],
            'peerAvatar': user.data['profilePicure'],
            'date': DateTime.now().millisecondsSinceEpoch.toString()
          },merge: true).then((resp) {

Firestore.instance.collection('users').
      document('${my_number}').collection('verified_contacts')
      .document('${actual_number}').setData({
 'last_message': '',
 'date': DateTime.now().millisecondsSinceEpoch.toString(),
 'phoneNumber': '${actual_number}',
 'idFrom': my_number,
 'idTo': actual_number,
 'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
 'isRegistered': true,
 'isChatted': false,
 'peerAvatar': '${user.data['profilePicure']}',
 'date': DateTime.now().millisecondsSinceEpoch.toString()
},merge: true).then((doc){
 Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Chat(
                                            peerAvatar:
                                                '${user.data['profilePicture']}',
                                            fullName:
                                                '${user.data['fullName']}',
                                            phoneNumber:
                                                '${user.data['phoneNumber']}',
                                            peerId:
                                                '${user.data['phoneNumber']}'
                                          )));
});

//             Firestore.instance.collection('LatestNotifications').document('${my_number}')
//  .collection('new_nots').document('${actual_number}').setData({
//    'chatCount': FieldValue.increment(1),
//    'phoneNumber': '${actual_number}',
//    'fullName': '${user.data['fullName']}',
//    'peerAvatar': '${user.data['profilePicture']}'
//  },merge: true).then((onValue){

//  });
           
          });

                  

                                    }
                                });
               
                    
              },
              leading: (c.avatar != null && c.avatar.length > 0)
                  ? CircleAvatar(backgroundImage: MemoryImage(c.avatar))
                  : CircleAvatar(child: Text(c.initials())),
              title: Text(c.displayName ?? ""),
trailing: Text('Invite', style: TextStyle(color: Colors.lightBlue)),
            );
          },
        )
            : Center(child: CircularProgressIndicator(),),
      ));
      // .orderBy('fullName',descending: false)
  }
}
