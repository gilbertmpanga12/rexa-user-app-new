import 'package:flutter/material.dart';

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
          http.post('https://viking-250012.appspot.com/api/update-profile-picture',
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



  Widget build(BuildContext context){
    return WillPopScope(child: SafeArea(child: Scaffold(
        appBar: AppBar(
          title: Text(
            DemoLocalizations.of(context).profile,
            style: TextStyle(
              fontSize: 20.0,letterSpacing: .4,
              color: Colors.black,fontFamily: 'NunitoSans',fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          elevation: 1.5,
        ),
        body: ListView(children: <Widget>[
          StreamBuilder(
                      stream: Firestore.instance.collection('users')
                      .document('${_firebaseUID}').snapshots(),
                      builder: (context, snapshot) {
                        print('$_firebaseUID');
                        print('${snapshot.data}');
                        if(!snapshot.hasData){
                          return Center(child: CircularProgressIndicator());
                        }
                        return Form(child:Center(
          child: Padding(
            padding: EdgeInsets.only(top: 20.0, left: 0, right: 20.0),
            child: Column(
              children: <Widget>[
                Container(
                  child: InkWell(
                    child: CachedNetworkImage(imageBuilder: (context,imageProvider){
                                  return CircleAvatar(
                      foregroundColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.yellow[700],
                      backgroundImage: new NetworkImage(
                          '${snapshot.data['profilePicture']}'),
                      radius: 75.0,
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
                
                ListTile(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeName()));
                  },
                  trailing: Icon(Icons.edit),
                  leading: Icon(
                      Icons.person,
                      color: Colors.yellow[800]
                  ),
                  title: Text('Username',style: TextStyle(fontWeight: FontWeight.w500,)),
                  subtitle: Text('${snapshot.data['fullName']}',style: TextStyle(fontSize: 17.0,)),

                ),
                Container(child: Divider(indent: 57.8,),padding: EdgeInsets.only(left:12.0),),

                ListTile(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeAbout()));
                  },
                  trailing: Icon(Icons.edit),
                  leading: Icon(Icons.info, color: Colors.yellow[800]),
                  title: Text(
                    DemoLocalizations.of(context).about,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text('${snapshot.data['about'] == null ? 'Not Available': snapshot.data['about']}',style: TextStyle(fontSize: 17.0,)),
                ),
                Container(child: Divider(indent: 57.8,),padding: EdgeInsets.only(left:12.0),),
                ListTile(
                  leading: Icon(Icons.phone, color: Colors.yellow[800]),
                  title: Text(DemoLocalizations.of(context).telephone,
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('$phoneNumber',style: TextStyle(fontSize: 17.0,)),
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
