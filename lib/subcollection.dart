import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
// import 'package:gcloud/pubsub.dart';

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

class Subcat extends StatefulWidget {
  final String categoryName;
  Subcat({this.categoryName});
  @override
  SubcatState createState() => SubcatState();
}

class SubcatState extends State<Subcat> {
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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _firebaseUID;
  String serviceProviderID;
  String _description;
  String countryCode;
  String _catName;
  chopDescription(String txt) {
    try {
      if (txt.length > 40) {
        return txt.substring(0, 38) + ' ...more';
      } else {
        return txt;
      }
    } catch (err) {
      return '';
    }
  }

  



_launchURL() async {
  final url = 'https://play.google.com/store/apps/details?id=com.esalonbusiness.esalonbusiness';
 
  print(url);
  if (await canLaunch(url)) {
    await launch(url, universalLinksOnly: true); // ,forceWebView: true,enableJavaScript: true
  } else {
    Toast.show('Oops!, website not listed by service provider.', context, duration: 7,backgroundColor: Colors.red); // Locator
  }
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






  initState() {
    _catName = widget.categoryName;
    localesLoader();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

 
  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
        context: context,
        builder: (BuildContext context) {
          /*
         => new CupertinoAlertDialog(
            title: new Text(title),
            content: new Text(body),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: new Text('Ok'),
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                  await Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) => new SecondScreen(payload),
                    ),
                  );
                },
              )
            ],
          ),
        */
          return Text('Notification');
        });
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => RatingWidget()),
    );
  }

  // Future onSelectNotification(String payload) async {
  //   Navigator.push(
  //       context, MaterialPageRoute(builder: (context) => RatingWidget()));
  // }

  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('clock', false);
    prefs.remove('isSignedIn');
    authService.signOut();
    Navigator.popAndPushNamed(context, '/auth').then((onValue){
      Navigator.of(context).pop();
    });
    print('called logout');
  }

  String stringChopper(String word) {
    if (word.length > 16) {
      return word.substring(0, 16) + '...';
    } else {
      return word;
    }
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
                fontWeight: FontWeight.w700,
                fontFamily: 'Merienda',
                color: Colors.black,
                fontSize: 25.0,
                letterSpacing: 0.8),
          ),
          backgroundColor: Colors.white,
          elevation: 1.0,
          iconTheme: IconThemeData(color: Colors.black),
          actions: <Widget>[
            IconButton(
                    icon: Icon(Icons.star_border),
                    onPressed: () {
                      setState(() {
                        counter = 0;
                      });
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RatingWidget()));
                    }),
            new IconButton(
                    icon: Icon(Icons.live_tv),
                    onPressed: () {
                       Navigator.pushNamed(context, '/tv');
                    })
          ],
        ),
        drawer: Container(width: 260.0,child: Theme(child:  Drawer(
          
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
                                CachedNetworkImage(imageBuilder: (context,imageProvider){
                                  return CircleAvatar( // xoxo
                                  foregroundColor:
                                      Theme.of(context).primaryColor,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: imageProvider,
                                      
                                  radius: 50.0,
                                );
                                },
        imageUrl: "${snapshot.data['profilePicture']}",
        placeholder: (context, url) => new CircularProgressIndicator(),
        errorWidget: (context, url, error) => new Icon(Icons.error),
     ),
                                
                                Padding(padding: EdgeInsets.all(5.0),child:  Text(
                                  '${snapshot.data['fullName']}',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18.0),
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
                leading: Icon(FontAwesomeIcons.globeAmericas, color: Colors.white,),
                title: Text('Go International',style: TextStyle(color: Colors.white),),
                onTap: () {
                    Navigator.popAndPushNamed(context, '/change-country');
                },
              ),
              // ListTile(
              //   leading: Icon(Icons.swap_horiz, color: Colors.white,),
              //   title: Text(DemoLocalizations.of(context).requFests, style: TextStyle(color: Colors.white)),
              //   onTap: () {
              //     // Update the state of the app
              //     // ...
              //     Navigator.popAndPushNamed(context, '/requests');
              //   },
              // ),
              ListTile(
                leading: Icon(Icons.history, color: Colors.white,),
                title: Text(DemoLocalizations.of(context).history, style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Update the state of the app
                  // ...
                  /*Navigator.pop(context);*/
                  Navigator.popAndPushNamed(context, '/history');
                },
              ),
              ListTile(
                leading: Icon(Icons.account_circle,color: Colors.white,),
                title: Text(DemoLocalizations.of(context).profile,style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Update the state of the app
                  // ...
                  /*Navigator.pop(context);*/
                  Navigator.popAndPushNamed(context, '/profile');
                },
              ),
              ListTile(
                leading: Icon(Icons.help,color: Colors.white),
                title: Text(DemoLocalizations.of(context).help, style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Update the state of the app
                  // ...
                  /*Navigator.pop(context);*/
                  Navigator.popAndPushNamed(context, '/help');
                },
              ),
              ListTile(
                leading: Icon(Icons.share,color: Colors.white,),
                title: Text('Join Rexa Business',style: TextStyle(color: Colors.white)),
                onTap: () {
                  // url launcher goes here
                  Navigator.of(context).pop();
                  _launchURL();
                },
              ),
              ListTile(
                leading: Icon(Icons.power_settings_new, color: Colors.white,),
                title: Text(DemoLocalizations.of(context).logOut, style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Update the state of the app
                  // ...
                  /*Navigator.pop(context);*/
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
                .collection('servicesfeed').where('subCategory',isEqualTo: _catName)
                .where('country',isEqualTo: '$countryCode')
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(strokeWidth: 5.0),
                );
              }
              try{
return snapshot.data.documents.length > 0 ?ListView.builder(
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
                                    print('chunker...');
                                    print({
                                      'uid':
                                                      '${snapshot.data.documents[index]['uid']}',
                                                  'serviceOffered':
                                                      '${snapshot.data.documents[index]['serviceOffered']}',
                                                  'userId': '$_userId',
                                                  'location':
                                                      '${snapshot.data.documents[index]['location']}',
                                                  'price':
                                                      '${snapshot.data.documents[index]['price']}',
                                                  'serviceProviderToken':
                                                      '${snapshot.data.documents[index]['serviceProviderToken']}',
                                                  'duration':
                                                      '${snapshot.data.documents[index]['time']}',
                                                  'description':
                                                      '${snapshot.data.documents[index]['description']}'
                                    });

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
                                                      fcmToken: '${snapshot.data.documents[index]['fcm_token']}'
                                                )));
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
                                                  style: TextStyle(
                                                    color: Color(0xFF2c2828),
                                                      fontSize: 16.7,
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: 'Rukie',
                                                      letterSpacing: .5)),
                                            )
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
                                                      fcmToken: '${snapshot.data.documents[index]['fcm_token']}'
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

                                Container(child: Row(children: <Widget>[
                                                              RichText(
  text: TextSpan(
    text: '${snapshot.data.documents[index]['price']}',
    style: TextStyle(fontWeight: FontWeight.w500,
                                      fontSize: 16.0,
                                      color: Colors.yellow[800],
                                      fontFamily: 'NunitoSans',),
    children: <TextSpan>[
      TextSpan(text: ' • ', style: TextStyle(fontWeight: FontWeight.w200,color: Colors.grey[500])),
      TextSpan(text: '${snapshot.data.documents[index]['time']}'.toLowerCase(), 
      style: TextStyle(fontWeight: FontWeight.w100,
      fontStyle: FontStyle.italic,
      fontSize: 13.0,
       color: Colors.grey[500], fontFamily: 'Caveat')),
    ],
  ),
)


                                ],),padding: EdgeInsets.only(left: 16.0,top:0),),
                                
                                SizedBox(height:7),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: SizedBox(
                                      child: Text(
                                          "${chopDescription(snapshot.data.documents[index]['description'])}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 0.3,
                                              fontFamily: 'PatrickHand',
                                              fontSize: 15.7,
                                              height: 1.0,
                                              color: Colors.grey[800])),
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
                    }): Center(child: Text('Services not yet added for this category'),);
              }catch(e){
                return Center(child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child:
                 Text('Please check your internet connection and try again', style: TextStyle(fontFamily: 'Caveat'),),),);
              }
            }),
        backgroundColor: Color.fromRGBO(240, 240, 240, 1.0),
      ),onWillPop: (){
        Navigator.popAndPushNamed(context, '/home');
        return Future.value(false);
      },),
    );
  }
}
