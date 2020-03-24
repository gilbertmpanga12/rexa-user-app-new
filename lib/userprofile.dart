import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:random_string/random_string.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import './app_services/linker.dart';
import './app_services/localizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './changeName.dart';
import './changeAbout.dart';
import 'dart:async';
class UserProfile extends StatefulWidget{
  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
String profilePicture;
String displayName;
String phoneNumber;
String  _firebaseUID;
String  _fullName;
String about;
Flushbar flashbar;
Flushbar flashbar2;
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
final TextEditingController controller = TextEditingController();
bool _isTextValid = false;
GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  initState() {
    localStorage();
    super.initState();

  }
  localStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
     print(prefs.getString('fullName'));
      print(prefs.getString('phoneNumber'));
      // prefs.setString('phoneNumber', '+256778849457');
      // prefs.setString('uid', '+256778849457');
    if(mounted){
      setState(() {
      profilePicture = prefs.getString('profilePicture');
      displayName = prefs.getString('fullName');
      phoneNumber = prefs.getString('phoneNumber');
       _firebaseUID = prefs.getString('uid');
    });
    }
  }

  @override
  dispose(){
    if(flashbar2 != null){
      flashbar2.dismiss();
    }
    super.dispose();
  }






  uploadPhoto() async {
    print('I am >>>>>>>>');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    ImagePicker.pickImage(source: ImageSource.gallery).then((image){
      final url = randomAlpha(10);
      final StorageReference firebaseStorageRef =
      FirebaseStorage.instance.ref().child('${url}');
      final StorageUploadTask task =
      firebaseStorageRef.putFile(image);

      // showDialog(context: context,builder: (BuildContext context){
      //   return AlertDialog(content: Row(children: <Widget>[
      //     Container(child: CircularProgressIndicator(),margin: EdgeInsets.only(right: 10.0),),
      //     Container(child: Text('Processing...',style: TextStyle(fontSize: 17.0),),)
      //   ],),);
      // });
      flashbar = Flushbar(
                showProgressIndicator: true,
                progressIndicatorBackgroundColor: Colors.blueGrey,
                  title:  "Updating profile picture",
                  message:  "Please wait...",
                  duration:  Duration(minutes: 2),              
                )..show(context);

      task.onComplete.then((image){
        firebaseStorageRef.getDownloadURL().then((result) {
          
          final Map<String, dynamic> service = {
            'profilePicture': result.toString(),
            'uid': prefs.getString('uid')
          };
          prefs.setString('profilePicture', result.toString());
          linkerService.pictureListener.add(service['profilePicture']);
          if(mounted){
            setState(() {
            profilePicture = service['profilePicture'];
          });
          }
          http.post('https://young-tor-95342.herokuapp.com/api/update-profile-picture',
              body: json.encode(service),
              headers: {
                "accept": "application/json",
                "content-type": "application/json"
              }).then((response){
            if(response.statusCode == 200 || response.statusCode == 201){
              this.flashbar.dismiss();
  // Navigator.of(context, rootNavigator: true).pop('dialog');
              // showDialog(context: context,builder: (BuildContext context){
              //   return AlertDialog(
              //     title: Text('Success'),
              //     content: Text('Your profile picture has been updated'),actions: <Widget>[
              //     FlatButton(child: Text('OK'),onPressed: (){
              //       this.flashbar.dismiss();
              //        Navigator.of(context, rootNavigator: true).pop('dialog');

              //     },)
              //   ],);
              // });
         flashbar2 =      Flushbar(
                 icon: Icon(
        Icons.check,
        color: Colors.greenAccent,
      ),
                  titleText: Text(
        "Success",
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.greenAccent,fontFamily: 'NunitoSans'),
      ),
                  messageText: Text(
        "Profile picture updated!",
        style: TextStyle(fontSize: 18.0, color: Colors.greenAccent, fontFamily: 'NunitoSans'),
      ),
                  duration:  Duration(seconds: 3),              
                )..show(context);
            }else{
              print(response.body);
            this.flashbar.dismiss();
              showDialog(
                context: context,builder: (BuildContext context){
                return AlertDialog(
                         shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20.0))
),
                  title: Text('Oops something went wrong'),
                  content: Text('Please try again or contact support team'),actions: <Widget>[
                  FlatButton(child: Text('OK'),onPressed: (){
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },)
                ],);
              });
              throw Exception('Oops something wrong');
            }
          });

        });
      });

    });
  }


  void _submitUsername() async {
    Firestore.instance.collection('users').document('${_firebaseUID}').updateData({
              'fullName': controller.value.text
            }).then((resp){
         controller.clear();     
        Navigator.pop(context);
            });
}

void _submitAbout() async {
 Firestore.instance.collection('users').document('${_firebaseUID}').updateData({
              'about':  controller.value.text
            }).then((resp){
               controller.clear();  
              Navigator.pop(context);
            });
}

  void _settingModalBottomSheet(context, String actionPlaceholder, String fullName) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0),topRight: Radius.circular(20.0))
),
      elevation: 3.0,backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
            // Padding(child: 
            // Text('$actionPlaceholder',style: 
            // TextStyle(color: Colors.white,
            // fontWeight: FontWeight.w600,fontSize: 20.6,
            // letterSpacing: .9,
            // fontFamily:'NunitoSans'),
            // textAlign: TextAlign.left),padding: EdgeInsets.only(top:18.0,bottom: 1.0,left: 18.0,right: 18.0),),
            // // Padding(child: 
            // // Text('Share with the world',style: 
            // // TextStyle(
            // //   wordSpacing: -0.800,
            // //   color: Colors.white,
            // // fontWeight: FontWeight.w400,fontSize: 17.3,
            // // letterSpacing: .9,
            // // fontFamily:'NunitoSans'),
            // // textAlign: TextAlign.center),padding: EdgeInsets.all(1.0),),
            SizedBox(height: 25.0,),
            // ListView.builder(itemBuilder: (BuildContext),) inputBar()
           Padding(child:Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        color: Colors.white,
        child: Row(
          children: <Widget>[
           SizedBox(width: 13.0),
          
            Expanded(
              child: TextField(

                inputFormatters: [
                  LengthLimitingTextInputFormatter(500)
                ],
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                 maxLines: null,
                 controller: controller,
                decoration: InputDecoration(
                  errorText: _isTextValid ? 'Field Can\'t Be Blank' : null,
                  hintText: '$fullName',hintStyle:  TextStyle(fontFamily: 'Rukie',fontSize: 20, fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(width: 8.0),
          ],
        ),
      ),
    ),
          ),
          SizedBox(
            width: 5.0,
          ),
          InkWell(
            onTap: () {
              if(actionPlaceholder == 'Enter your username'){
                 _submitUsername();
              }else{
                _submitAbout();
              }
              
            },
            child: CircleAvatar(
              child: Icon(FontAwesomeIcons.paperPlane),
            ),
          ),
        ],
      ),
    ),          padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom))

          ],);
        }).whenComplete((){
controller.clear();

        });
  }
  



  Widget build(BuildContext context){
    return WillPopScope(child: SafeArea(child: Scaffold(
        appBar: AppBar(
          title: Text(
            DemoLocalizations.of(context).profile,
            style: TextStyle(
              fontSize: 17.0,letterSpacing: .4,
              color: Colors.black,fontFamily: 'NunitoSans',fontWeight: FontWeight.w900),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          elevation: 0.0
        ),
        body: ListView(children: <Widget>[
          StreamBuilder(
                      stream: Firestore.instance.collection('users')
                      .document('${_firebaseUID}').snapshots(),
                      builder: (context, snapshot) {
                        if(!snapshot.hasData){
                          return Center(child: CircularProgressIndicator());
                        }
                        return Form(child:Center(
          child: Padding(
            padding: EdgeInsets.only(top: 20.0, left: 0, right: 20.0),
            child: Column(
              children: <Widget>[
                Stack(children: <Widget>[
                  Container(
                  child: InkWell(
                    child: CachedNetworkImage(imageBuilder: (context,imageProvider){
                                  return CircleAvatar(
                      foregroundColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.yellow[700],
                      backgroundImage: new NetworkImage(
                          '${snapshot.data['profilePicture']}'),
                      radius: 66.0,
                    );
                                },
        imageUrl: "${snapshot.data['profilePicture']}",
        placeholder: (context, url) => new CircularProgressIndicator(),
        errorWidget: (context, url, error) => new Icon(Icons.error),
     ),onTap: (){
                    uploadPhoto();
                  },
                  ),
                  margin: EdgeInsets.only(left: 18.0, bottom: 25.0),
                ),
                Positioned(bottom: 19.6,child: Icon(Icons.add_circle,color: Colors.yellow[800],size: 30),right: 8,)
                ],),
                
                ListTile(
                  onTap: (){
                  _settingModalBottomSheet(context,'Enter your username','${snapshot.data['fullName']}');
                  },
                  trailing: Icon(Icons.edit),
                  leading: Icon(
                      Icons.person,
                      color: Colors.yellow[800]
                  ),
                  title: Text('Username',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14)),
                  subtitle: Text('${snapshot.data['fullName']}',style: TextStyle(fontSize: 14.0,)),

                ),
                Container(child: Divider(indent: 57.8,),padding: EdgeInsets.only(left:12.0),),

                ListTile(
                  onTap: (){
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeAbout()));
                    _settingModalBottomSheet(context,'Add About','${snapshot.data['about'] == null ? 'Not Available': snapshot.data['about']}');
                  },
                  trailing: Icon(Icons.edit),
                  leading: Icon(Icons.info, color: Colors.yellow[800]),
                  title: Text(
                    DemoLocalizations.of(context).about,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  subtitle: Text('${snapshot.data['about'] == null ? 'Not Available': snapshot.data['about']}',style: TextStyle(fontSize: 14.0,)),
                ),
                Container(child: Divider(indent: 57.8,),padding: EdgeInsets.only(left:12.0),),
                ListTile(
                  leading: Icon(Icons.phone, color: Colors.yellow[800]),
                  title: Text(DemoLocalizations.of(context).telephone,
                      style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14)),
                  subtitle: Text('$phoneNumber',style: TextStyle(fontSize: 14.0,)),
                ),
              ],
            ),
          ),
        ) ,key: _formKey,);
                      }
                  )
        ],)),),onWillPop: (){
           Navigator.popAndPushNamed(context, '/home');
      return Future.value(false);
        },);
  }
}
