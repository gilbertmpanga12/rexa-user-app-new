import 'dart:io';
import 'package:rexa/orderpage.dart';

import './help.dart';
import './mainTabChat.dart';
import './styles_beauty.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';
import './contacts.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import './app_services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import './rating.dart';
import './app_services/localizer.dart';
import './viewfull_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './new_chats.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toast/toast.dart';
import 'chat_view.dart';
import './app_services/linker.dart';
import 'package:intl/intl.dart';

class Photo {
  final String profilePicture;
  Photo({this.profilePicture});
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(profilePicture: json['profilePicture']);
  }
}

class CategoriesAll {
  final String nationalId;
  final bool isRequested;
  final String servicePhotoUrl;
  final String serviceCategoryId;
  final String serviceOfferedId;
  final String fullName;
  final String serviceCategoryName;
  final String time;
  final String location;
  final String serviceOffered;
  final String uid;
  final String price;
  final String serviceProvider;
  final String serviceProviderToken;
  final bool statusNotRequired;
  final String description;
  final String website;
  CategoriesAll(
      {this.nationalId,
      this.isRequested,
      this.servicePhotoUrl,
      this.serviceCategoryId,
      this.fullName,
      this.serviceCategoryName,
      this.time,
      this.location,
      this.serviceOffered,
      this.serviceOfferedId,
      this.uid,
      this.price,
      this.serviceProviderToken,
      this.serviceProvider,
      this.statusNotRequired,
      this.description,this.website});

  factory CategoriesAll.fromJson(Map<String, dynamic> json) {
    return CategoriesAll(
        nationalId: json['nationalId'],
        isRequested: json['isRequested'],
        servicePhotoUrl: '${json['servicePhotoUrl']}',
        serviceCategoryId: json['serviceCategoryId'],
        fullName: json['fullName'],
        serviceCategoryName: json['serviceCategoryName'],
        time: '${json['time']}',
        location: json['location'],
        serviceOffered: json['serviceOffered'],
        serviceOfferedId: json['serviceOffered'],
        price: '${json['price']}',
        uid: json['uid'],
        serviceProviderToken: json['serviceProviderToken'],
        serviceProvider: json['serviceProvider'],
        description: json['description'],
        website: json['website']);
  }
}

class ViewList extends StatefulWidget {
  @override
  ViewListState createState() => ViewListState();
}

class ViewListState extends State<ViewList> {
  List<CategoriesAll> resultsFetched = List();
  String _categoryType;
  String _userId;
  bool notAvailable = false;
  double paddingTitle = 67.0;
  String profilePicture;
  String displayName;
  String newPhoto;
  bool isRequestedError = false;
  String _filePath;
  int counter = 0;
  String _firebaseUID;
  String serviceProviderID;
  String _description;
  String countryCode;
  String _type;
  String _messageProfilePicture;
  String _messageFullName;
  String _messagePhone;
  StreamSubscription<ConnectivityResult> subscription;
  Flushbar flushbar;
  bool isInternational;
  // int tvCount = 0;
  // int ratingCount = 0;
  chopDescription(String txt) {
    try {
      if (txt.length > 40) {
        return txt.substring(0, 38) + '   ...more';
      } else {
        return txt;
      }
    } catch (err) {
      return '';
    }
  }

_launchURL() async {
  final String url = 'You have been invited to Rexa https://rexa-web.firebaseapp.com';
 Share.share(url);
}



  localesLoader() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _firebaseUID = prefs.getString('uid');
        serviceProviderID = prefs.getString('serviceProviderUid');
        countryCode = prefs.getString('countryCode');
      });
    }
    print('printinh >>> provider id');
    print('${serviceProviderID}');
  }



void setCounts(int count, String countType) async{
   SharedPreferences prefs = await SharedPreferences.getInstance();
try{
  await Firestore.instance.collection('users').document(prefs.getString('uid'))
.setData({
  countType : count
}, merge: true);
}catch(e){
  print(e);
}
}

  initState() {
      super.initState();
      checkIfInternational();
    localesLoader();
     subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
       if (result.toString() == 'ConnectivityResult.mobile' && flushbar != null) {
flushbar.dismiss();
} else if (result.toString() == 'ConnectivityResult.wifi'&& flushbar != null) {
flushbar.dismiss();
} else if(result.toString() == 'ConnectivityResult.none'){
        flushbar =  Flushbar(
                showProgressIndicator: true,
                progressIndicatorBackgroundColor: Colors.blueGrey,
                  title:  "Something is wrong",
                  message:  "Check your internet connection..",
                  duration:  Duration(minutes: 2),              
                )..show(context);
       }
       
  });

// OneSignal.shared.setNotificationReceivedHandler((OSNotification result) {
//   //  if(result.payload.rawPayload['title'].toString().contains('shared a new style')){
//   // }
//    if (result.payload.additionalData['type'] == 'new-videos'){
//      _activateVideoCount();
//   }

// });



OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult notification){
try{
 if(notification.notification.payload.rawPayload['title'].toString().contains('Rate')){
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => RatingWidget()));
 } else if((notification.notification.payload.rawPayload['title'].toString().contains('shared a new style'))){
   Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => StylesBeautyWidget()));
 } else {
Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Chat(
                                            peerAvatar:
                                                '${notification.notification.payload.additionalData['peerAvatar']}',
                                            fullName:
                                                '${notification.notification.payload.additionalData['fullName']}',
                                            phoneNumber:
                                                '${notification.notification.payload.additionalData['phoneNumber']}',
                                            peerId:
                                                '${notification.notification.payload.additionalData['phoneNumber']}',
  )));
 }
}catch(err){
print('Nothing to open');
}

});
// getStylesCount(); 
  
  }

checkIfInternational() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
isInternational = prefs.getBool('international');
}


  @override
  void dispose() {
    super.dispose();
  }


  logout() async {
    var lastSeen = DateTime.now().millisecondsSinceEpoch.toString();
    var fullDate = DateFormat('jm')
                          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(lastSeen)));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
  Navigator.popAndPushNamed(context, '/auth');
    Firestore.instance.collection('users').document(prefs.getString('uid')).setData({
      'current_status':'at $fullDate'
    }, merge: true).then((onValue){
      authService.signOut();
      prefs.clear();
    });
   
  }

  String stringChopper(String word) {
    if (word.length > 16) {
      return word.substring(0, 16) + '...';
    } else {
      return word;
    }
  }

  Widget actionIcon(String count, IconData iconName, String routeName){
    return  Stack(
              children: <Widget>[
                new IconButton(icon: Icon(iconName,color: Colors.black87,size: 25.0), onPressed: () {
                  Navigator.pushNamed(context, routeName);
                }),
                Positioned(
                  right: 4,
                  top: 11,
                  child: GestureDetector(child: new Container(
                    padding: EdgeInsets.all(2),
                    decoration: new BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 25,
                      minHeight:25,
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.5,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ),onTap: (){
                              Navigator.pushNamed(context, routeName);
                  },),
                )
              ],
            );
  }


  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return SafeArea(
      child: WillPopScope(child: Scaffold(
        appBar: AppBar(
          leading: Builder(
              builder: (context) => IconButton(
                    icon: new Icon(
                      Icons.more_horiz,
                      size: 25.0,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  )),
          centerTitle: true,
          title: Text(
            'Rexa',
            style: TextStyle(
                fontFamily: 'Monoton',
                color: Colors.black,
                fontSize: 23.0,
                letterSpacing: 0.8),
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.black),
          actions: <Widget>[
StreamBuilder(stream: Firestore.instance.collection('users')
    .document(_firebaseUID).snapshots(),builder: (BuildContext context, snapshots){
      switch(snapshots.connectionState){
        case ConnectionState.waiting: return  IconButton(icon: Icon(Icons.star_border,color: Colors.black87,size: 25.0), onPressed: () {
                  Navigator.pushNamed(context, '/rating');
                });
        default:
          return snapshots.data['hasRated'] ? actionIcon('1', Icons.star_border, '/rating'): IconButton(icon: Icon(Icons.star_border,color: Colors.black87,size: 25.0), onPressed: () {
                  Navigator.pushNamed(context, '/rating');
                });
      }
    }),

   StreamBuilder(stream: Firestore.instance.collection('users')
    .document(_firebaseUID).snapshots(), builder:(BuildContext context, snapshots){
      switch(snapshots.connectionState){
        case ConnectionState.waiting: return IconButton(icon: Icon(Icons.live_tv,color: Colors.black87,size: 25.0), 
        onPressed: () {
          Navigator.pushNamed(context, '/tv');
        });
        default:
          return snapshots.data['hasNewVideo']  ? actionIcon('1', Icons.live_tv, '/tv'): IconButton(icon: Icon(Icons.live_tv,color: Colors.black87,size: 25.0), onPressed: () {
                  Navigator.pushNamed(context, '/tv');
       });
      }
    })

         
            
          ],
        ),
        drawer: Container(width: 210.0,child: Theme(child:  Drawer(
          
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                  child: StreamBuilder(
                      stream: Firestore.instance
                          .collection('users')
                          .document('${_firebaseUID}')
                          .snapshots(),
                      builder: (context, snapshot) {
                        print('$_firebaseUID');
                        if (!snapshot.hasData) {
                          return Text('Loading...');
                        }
                        try {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              children: <Widget>[
                                InkWell(
                                  onTap: (){
                                    Navigator.popAndPushNamed(context, '/profile');
                                  },
                                  child: CachedNetworkImage(
                                  
                                  imageBuilder: (context,imageProvider){
                                  return CircleAvatar( // xoxo
                                  foregroundColor:
                                      Theme.of(context).primaryColor,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: imageProvider,
                                      
                                  radius: 40.0,
                                );
                                },
        imageUrl: "${snapshot.data['profilePicture']}",
        placeholder: (context, url) => new CircularProgressIndicator(),
        errorWidget: (context, url, error) => new Icon(Icons.error),
     ),),
                                
                                Padding(padding: EdgeInsets.all(5.0),child:  Text(
                                  '${snapshot.data['fullName']}',
                                  style: TextStyle(letterSpacing: .5,
                                      color: Colors.white, fontSize: 15.0, fontFamily: 'Rukie'),
                                ),),
                  
                              ],
                            ),
                          );
                        } catch (err) {
                          return Container(
                            child: Text(''),
                          );
                        }
                      }),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  
                  )),
                  // Divider(color: Colors.white,height: ,),
              ListTile(
                leading: Icon(FontAwesomeIcons.globeEurope, color: Colors.white,size: 21,),
                title: Text('International',style: TextStyle(color: Colors.white, fontSize: 12.5),),
                onTap: () {
                    Navigator.popAndPushNamed(context, '/change-country');
                },
              ),
        
              ListTile(
                leading: Icon(Icons.history, color: Colors.white,size: 21),
                title: Text(DemoLocalizations.of(context).history, style: TextStyle(color: Colors.white, fontSize: 12.5)),
                onTap: () {
                  // Update the state of the app
                  // ...
                  /*Navigator.pop(context);*/
                  Navigator.popAndPushNamed(context, '/history');
                },
              ),
              
              ListTile(
                leading: Icon(Icons.help,color: Colors.white,size: 21),
                title: Text(DemoLocalizations.of(context).help, style: TextStyle(color: Colors.white, fontSize:12.5)),
                onTap: () {
                  // Update the state of the app
                  // ...
                  /*Navigator.pop(context);*/
                  Navigator.popAndPushNamed(context, '/help');
                },
              ),
              ListTile(
                leading: Icon(Icons.share,color: Colors.white,size: 21),
                title: Text('Join Rexa Business',style: TextStyle(color: Colors.white, fontSize: 12.5)),
                onTap: () {
                  // url launcher goes here
                  Navigator.of(context).pop();
                  _launchURL();
                },
              ),
              ListTile(
                leading: Icon(Icons.power_settings_new, color: Colors.white,size: 21),
                title: Text(DemoLocalizations.of(context).logOut, 
                style: TextStyle(color: Colors.white, fontSize: 12.5),
                ),
                onTap: () {
                  logout();
                },
              )
            ],
          )
          // Changed drawer color
        ),data: Theme.of(context).copyWith(
       // Set the transparency here
       canvasColor: Color.fromRGBO(57, 62, 70, 0.3) // 255,255,255
       //or any other color you want. e.g Colors.blue.withOpacity(0.5)
      )),),
        body: StreamBuilder( // orderBy('created_at', descending: true)
            stream: Firestore.instance
                .collection('servicesfeed')
                .where('country',isEqualTo: '$countryCode').where('isVideo',isEqualTo: false)
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SpinKitPulse(
  color: Colors.blue,
  size: 66.0,
);
              }
              try{
return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.white,
                              margin: EdgeInsets.all(0),
                              elevation: 1.0,
                              child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            index == 0
                                ? new SizedBox(
                                    child: new InstaStories(),
                                    height: 114.0,
                                  )
                                : SizedBox.shrink(),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[

                                InkWell(
                                  child: new CachedNetworkImage(
        imageUrl: "${snapshot.data.documents[index]['servicePhotoUrl']}",
        placeholder: (context, url) => Image.memory(kTransparentImage),
        errorWidget: (context, url, error) => Icon(Icons.image,color: Colors.grey),
     ),
                                  onTap: () {
                                if(isInternational){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OrderPage(
                                                  serviceProviderPhoto: '${snapshot.data.documents[index]['profilePicture']}',
                                                  latitude: snapshot.data.documents[index]['latitude'],
                                                  longitude: snapshot.data.documents[index]['longitude'],
                                                  serviceProviderName: '${snapshot.data.documents[index]['fullName']}',
                                                  serviceProviderNamePhone: '${snapshot.data.documents[index]['phoneNumber']}',
                                                  docID: '${snapshot.data.documents[index]['docID']}',
                                                  commentRate: '${snapshot.data.documents[index]['raterComment'] ?? 'Tap to see more'}',
                                                  uid:
                                                      '${snapshot.data.documents[index]['uid']}',
                                                  serviceOffered:
                                                      '${snapshot.data.documents[index]['serviceOffered']}',
                                                  userId: '$_userId',
                                                  location:
                                                      '${snapshot.data.documents[index]['location']}',
                                                  price:
                                                      '${snapshot.data.documents[index]['price']}',
                                                  serviceProviderToken:
                                                      '${snapshot.data.documents[index]['serviceProviderToken']}',
                                                  duration:
                                                      '${snapshot.data.documents[index]['time']}',
                                                  description:
                                                      '${snapshot.data.documents[index]['description']}',
                                                      website: '${snapshot.data.documents[index]['website']}',
                                                      shippingAddress: '${snapshot.data.documents[index]['shippingAddress']}',
                                                      fcmToken: '${snapshot.data.documents[index]['fcm_token']}' ,
                                                      // isIos: snapshot.data.documents[index]['isIos'],
                                                )));
                                }else{
                                  Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ServicesContacts(
                                                  serviceProviderPhoto: '${snapshot.data.documents[index]['profilePicture']}',
                                                  latitude: snapshot.data.documents[index]['latitude'],
                                                  longitude: snapshot.data.documents[index]['longitude'],
                                                  serviceProviderName: '${snapshot.data.documents[index]['fullName']}',
                                                  serviceProviderNamePhone: '${snapshot.data.documents[index]['phoneNumber']}',
                                                  docID: '${snapshot.data.documents[index]['docID']}',
                                                  commentRate: '${snapshot.data.documents[index]['raterComment'] ?? 'Tap to see more'}',
                                                  uid:
                                                      '${snapshot.data.documents[index]['uid']}',
                                                  serviceOffered:
                                                      '${snapshot.data.documents[index]['serviceOffered']}',
                                                  userId: '$_userId',
                                                  location:
                                                      '${snapshot.data.documents[index]['location']}',
                                                  price:
                                                      '${snapshot.data.documents[index]['price']}',
                                                  serviceProviderToken:
                                                      '${snapshot.data.documents[index]['serviceProviderToken']}',
                                                  duration:
                                                      '${snapshot.data.documents[index]['time']}',
                                                  description:
                                                      '${snapshot.data.documents[index]['description']}',
                                                      website: '${snapshot.data.documents[index]['website']}',
                                                      shippingAddress: '${snapshot.data.documents[index]['shippingAddress']}',
                                                      fcmToken: '${snapshot.data.documents[index]['fcm_token']}' ,
                                                      isIos: snapshot.data.documents[index]['isIos'],
                                                )));
                                } 

                                    
                                  },
                                ),

                                SizedBox(
                                  height: 35.9,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 1.0, left: 16.0, right: 16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 4.8),
                                              child: Text(
                                                  '${stringChopper(snapshot.data.documents[index]['serviceOffered'])}',
                                                  style: TextStyle(fontWeight: FontWeight.w600,fontSize:16.0),
                                                  ),
                                            ),
                                            // SizedBox(height: 5.0),
                                          ],
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.visibility),
                                          onPressed: () {
                                            if (snapshot.data.documents[index]
                                                    ['isVideo'] ==
                                                true) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ServicesContacts(
                                                            serviceProviderPhoto: '${snapshot.data.documents[index]['profilePicture']}',
                                                            serviceProviderNamePhone: '${snapshot.data.documents[index]['phoneNumber']}',
                                                            commentRate: '${snapshot.data.documents[index]['commentRate'] ?? 'Not available'}',
                                                            latitude: snapshot.data.documents[index]['latitude'],
                                                            longitude: snapshot.data.documents[index]['longitude'],
                                                            docID: '${snapshot.data.documents[index]['docID']}',
                                                            description: '${snapshot.data.documents[index]['description']}',
                                                            serviceProviderName: '${snapshot.data.documents[index]['fullName']}',
                                                            uid:
                                                                '${snapshot.data.documents[index]['uid']}',
                                                            serviceOffered:
                                                                '${snapshot.data.documents[index]['serviceOffered']}',
                                                            userId: '$_userId',
                                                            location:
                                                                '${snapshot.data.documents[index]['location']}',
                                                            price:
                                                                '${snapshot.data.documents[index]['price']}',
                                                            serviceProviderToken:
                                                                '${snapshot.data.documents[index]['serviceProviderToken']}',
                                                            duration:
                                                                '${snapshot.data.documents[index]['time']}',
                                                                website: '${snapshot.data.documents[index]['website']}',
                                                                shippingAddress: '${snapshot.data.documents[index]['shippingAddress']}',
                                                                fcmToken: '${snapshot.data.documents[index]['fcm_token']}',
                                                                isIos: snapshot.data.documents[index]['isIos'],
                                                          )));
                                            } else {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewImage(
                                                            serviceName: snapshot
                                                                        .data
                                                                        .documents[
                                                                    index][
                                                                'serviceOffered'],
                                                            photoUrl: snapshot
                                                                        .data
                                                                        .documents[
                                                                    index][
                                                                'servicePhotoUrl'],
                                                            isVideo: snapshot
                                                                    .data
                                                                    .documents[
                                                                index]['isVideo'],
                                                          )));
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Container(child: Row(
                                  
                                  children: <Widget>[
                                                              RichText(
  text: TextSpan(
    style: TextStyle(color: Colors.yellow[800],fontFamily: 'NunitoSans',fontStyle: FontStyle.normal,fontSize:16),
    text: '${snapshot.data.documents[index]['price']}',
    children: <TextSpan>[
      TextSpan(text: '  ', style: TextStyle(fontWeight: FontWeight.w200,color: Colors.red[200])),// [500]
      TextSpan(text: '${snapshot.data.documents[index]['time']}'.toLowerCase(), 
      style: TextStyle(fontWeight: FontWeight.w300,color: Colors.grey[500],fontSize: 13.7)
   ),
    ],
  ),
)


                                ],),padding: EdgeInsets.only(left: 16.0,top:0),margin: EdgeInsets.all(0)),
                                
                                SizedBox(height:3),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: SizedBox(
                                      child: Text(
                                          "${chopDescription(snapshot.data.documents[index]['description'])}",
                                          style: TextStyle(fontWeight: FontWeight.w400,
                                          color: Colors.grey[500],
                                          fontFamily: 'NunitoSans',fontSize: 13),
                                     ),
                                      width: 200.0),
                                ),
                                SizedBox(height: 1.5),

                                SizedBox(
                                  height: 7.5,
                                ),
                              ],
                            )
                          ])
);
                    });
              }catch(e){
                return Center(child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child:
                 Text('Please check your internet connection and try again', style: TextStyle(fontFamily: 'Caveat'),),),);
              }
            }),
        backgroundColor: Color.fromRGBO(240, 240, 240, 1.0),
        floatingActionButton: FloatingActionButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/categories');
                      },
                      child: Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      backgroundColor: Colors.white,
                    ),
      ),onWillPop: (){
        return Future.value(false);
      },),
    );
  }
}
