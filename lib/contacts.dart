import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';

import './swiper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './navigation.dart';
import './app_services/localizer.dart';
import 'package:toast/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:url_launcher/url_launcher.dart';
import './webview.dart';
import 'globals/config.dart';

class ServiceProvider {
  final String fullName;
  final String profilePicture;
  final String phoneNumber;
  final String longitude;
  final String latitude;
  final String location;
  final String isRequested;

  ServiceProvider(
      {this.profilePicture,
      this.longitude,
      this.latitude,
      this.phoneNumber,
      this.fullName,
      this.location,
      this.isRequested
      });
  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
        fullName: json['fullName'],
        profilePicture: json['profilePicture'],
        phoneNumber: json['phoneNumber'],
        longitude: '${json['longitude']}',
        latitude: '${json['latitude']}',
        location: json['location'],
        isRequested: '${json['isRequested']}'
    );
  }
}

class Payload {
  final bool isRequested;
  final String requestedSaloonService;
  final String timeStamp;
  final String serviceProviderId;
  final String userId;

  Payload(
      {this.isRequested,
      this.requestedSaloonService,
      this.timeStamp,
      this.serviceProviderId,
      this.userId});

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
        isRequested: json['isRequested'],
        requestedSaloonService: json['requestedSaloonService'],
        timeStamp: json['timeStamp'],
        serviceProviderId: json['serviceProviderId'],
        userId: json['userId']);
  }
}

class ServicesContacts extends StatefulWidget {
  final String uid;
  final String serviceOffered;
  final String userId;
  final String price;
  final String location;
  final double longitude;
  final double latitude;
  final String serviceProviderToken;
  final String duration;
  final String description;
  final String website;
  final String shippingAddress;
  final String commentRate;
  final String docID;
  final String serviceProviderName;
  final String serviceProviderNamePhone;
  final String  serviceProviderPhoto;
  final String fcmToken;
  

  ServicesContacts(
      {this.uid,
      this.serviceOffered,
      this.userId,
      this.price,
      this.location,
      this.longitude,
      this.latitude,
      this.serviceProviderToken,
      this.duration,
      this.description,
      this.website,
      this.shippingAddress,
      this.commentRate,
      this.docID,
      this.serviceProviderName,
      this.serviceProviderNamePhone,
      this.serviceProviderPhoto,
      this.fcmToken
      });
      

  @override
  ServicesContactsState createState() => ServicesContactsState();
}

class ServicesContactsState extends State<ServicesContacts> {
  String _uid;
  String _requestedSaloonService;
  String _requestedDescription;
  String _commentRate;
  String _userId;
  ServiceProvider fetchResults;
  String requesteeName;
  bool errorPlaceholder;
  bool successPlaceholder;
  String _price;
  String _location;
  String serviceProviderName;
  String serviceProviderPicture;
  String serviceProvidePhoneNumber;
  Map<String, double> coordinates;
  String serviceProviderToken;
  String serviceHours;
  String _profilePicture;
  bool isBooked = false;
  String _firebaseUID;
  bool isSwitched = true;
  String _website;
  String _shippingAddress;
  String _docUid;
  double _longitude;
  double _latitude;
  String _serviceProviderName;
  String _serviceProviderNamePhone;
  String _serviceProviderPhoto;
  String _fcmToken;
  String defaultPicture = 'https://firebasestorage.googleapis.com/v0/b/esalonbusiness-d3f3d.appspot.com/o/avatar.png?alt=media&token=53503121-c01f-4450-a5cc-cf25e76f0697';
  StreamSubscription<ConnectivityResult> subscription;
  bool isNetworkAvailable = true;
_launchURL(String website, bool shouldToggle,String bookingUrl, String shippingUrl) async {
  Navigator.push(context, 
  MaterialPageRoute(builder: 
  (context) => WebViewer(website: website,uid: _uid,
  bookingUrl: bookingUrl,
  shippingUrl: shippingUrl,shouldToggle: shouldToggle)));
}

shipUrl(String website, bool shouldToggle,String bookingUrl, String shippingUrl) async {
  Navigator.push(context, 
  MaterialPageRoute(builder: 
  (context) => WebViewer(website: website,uid: _uid,
  bookingUrl: bookingUrl,
  shippingUrl: shippingUrl,shouldToggle: shouldToggle)));
}

showReviews(String uid){
  showModalBottomSheet(
      backgroundColor: Colors.transparent,
      elevation: 3.0,
      shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0),topRight: Radius.circular(20.0))
),
context: context,
builder: (BuildContext bc){
return Container(height: 260.0,child: StreamBuilder(builder: (context, snapshot){
if(!snapshot.hasData){
  return Center(child: CircularProgressIndicator());
}
return snapshot.data.documents.length > 0 ? Scrollbar(child: ListView.builder(
      itemCount: snapshot.data.documents.length,
      itemBuilder: (context, index) {
        return new Column(
            children: <Widget>[
                SizedBox(height: 10.0),
           ListTile(
             isThreeLine: true,
                trailing: Text(''),
               
                leading:  CircleAvatar(
                  radius: 20.5,
                  backgroundImage: NetworkImage('${snapshot.data.documents[index]['photoUrl'] ?? defaultPicture}'),
                )
                ,
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                  
                   Padding(child:  new Text(
                      '${snapshot.data.documents[index]['commenter_name']}',
                      style: new TextStyle(fontWeight: FontWeight.bold,fontSize: 17.6,
                      letterSpacing: .5,
                      color: Colors.white),
                    ),padding: EdgeInsets.all(2.0)),
                  ],
                ),
                subtitle: new Container(
                  width: 200.0,
                  padding: const EdgeInsets.only(top: 2.0,left: 3.0),
                  child: Text(
                    '${snapshot.data.documents[index]['raterComment']}',
                    style: new TextStyle(color: Colors.white, fontSize: 15.5,
                    fontFamily: 'Comfortaa',fontWeight: FontWeight.w300
                    ),
                  ),
                ),
              ),
              //    new Divider(
              //   height: 1.0,
              // ),
            ],
          );
      }
    ),): Center(child: Text('No reviews for this service provider', style: TextStyle(color: Colors.white,)),);
},stream: Firestore.instance.collection('saloonServiceProvider').document(uid)
              .collection('reviews').where('comment_length',isGreaterThan: 1).snapshots(),),);
}
);
}

  cancelRequest() {

    showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog( shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20.0))
),
              title: Text('Warning',style: TextStyle(fontWeight: FontWeight.bold),),
              content: Row(
                children: <Widget>[
                  Container(width: 200.0,
                    child: Text(
                      'Are you sure you want to cancel request?',
                      style: TextStyle(fontSize: 17.0,fontFamily: 'NunitoSans'),
                      
                    ),
                  )
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                ),
                FlatButton(
                  child: Text('Yes', style: TextStyle(color: Colors.red),),
                  onPressed: () async {
try{
SharedPreferences prefs = await SharedPreferences.getInstance();
  Toast.show('Processing...please wait', context, duration: 5);

      Firestore.instance
          .collection('orders')
          .document('${prefs.getString('lastOrderedServiceProviderId')}')
          .delete()
          .then((onvalue) {
        Firestore.instance
            .collection('saloonServiceProvider')
            .document('${_uid}')
            .setData({'isRequested': false,'status_notifier': false}, merge: true).then((newval) {
          requestServiceNotifier(_fcmToken,
"Request Cancellation",
"$requesteeName has cancelled request");
          Toast.show('Cancelled request successfully', context,
              duration: 5, backgroundColor: Colors.green);
          cancelBooked();
          Firestore.instance
            .collection('users')
            .document('${_userId}').updateData({
              'request_made': false
            }).then((val){
Navigator.push(context, MaterialPageRoute(builder: (context) => Swiper()));
            });
          
        });
      }).catchError((err) {
        Toast.show('Oops something went wrong!', context,
            duration: 5, backgroundColor: Colors.red);
      });
}catch(err){
print(err);
}
                  },
                )
              ],
            );
          });


    
  }

  cancelBooked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isBooked', false);
  }
  


  localStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('uid');
      requesteeName = prefs.getString('fullName');
      _profilePicture = prefs.getString('profilePicture');
      isSwitched =  prefs.getBool('international') ?? false;
    });
  }

  fetchCategories() async {
    try {
      final response = await http.get(
          'https://viking-250012.appspot.com/api/get-service-provider/$_uid');
          print('My body***** ${response.statusCode}' );
          print(response.body);
          
      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchResults = ServiceProvider.fromJson(json.decode(response.body));
        setState(() {
          serviceProviderName = fetchResults.fullName;
          serviceProviderPicture = fetchResults.profilePicture;
          serviceProvidePhoneNumber = fetchResults.phoneNumber;
          _uid = widget.uid;
          successPlaceholder = true;
        });
        return fetchResults;
      } else {
        setState(() {
          errorPlaceholder = true;
        });
        throw Exception('Oops something wrong');
      }
    } catch (e) {
      print('I am called eroed');
      setState(() {
        errorPlaceholder = true;
      });
    }
  }



requestServiceNotifier(String playerId, String contents, String headings) async {
String url = 'https://onesignal.com/api/v1/notifications';
Map<dynamic, dynamic> body = {
'app_id': Configs.appIdBusinessAndroidOnesignal,
'contents': {"en": contents},
'include_player_ids': [playerId],
'headings': {"en": headings},
'data': {"type": "new-stories"},
 "small_icon": "@mipmap/ic_launcher",
 "large_icon": "@mipmap/ic_launcher"
}; 
final response = await http.post(url,
body: json.encode(body),
headers: {HttpHeaders.authorizationHeader: Configs.authorizationHeaderAndroidOnesignal,
"accept": "application/json",
"content-type": "application/json"
}
);
}

  makeServiceRequest() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20.0))
),
            content: Row(
              children: <Widget>[
                Container(
                  child: CircularProgressIndicator(),
                  margin: EdgeInsets.only(right: 10.0),
                ),
                Container(
                  child: SizedBox(
                    width: 180.0,
                    child: SizedBox(
                        width: 200.0,
                        child:
                    Text(
                      DemoLocalizations.of(context).processing,
                      style: TextStyle(fontSize: 17.0),
                    ),),
                  ),
                )
              ],
            ),
          );
        });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _payload = json.encode({
      'isRequested': true,
      'requestedSaloonService': '$_requestedSaloonService',
      'timeStamp': '${DateTime.now()}',
      'serviceProviderId': '$_uid',
      'userId': '$_userId',
      'requesteeName': '${prefs.getString('fullName')}',
      'phoneNumber': '${prefs.getString('phoneNumber')}',
      'priceRequested': _price,
      'fcm_token': prefs.getString('fcm_token'),
      'serviceProviderToken': serviceProviderToken,
      'ProfilePicture': '${prefs.getString('profilePicture')}',
      'longitude': prefs.getDouble('long'),
      'latitude': prefs.getDouble('lat'),
      'status_notifier': true
    });
    
   
    final response = await http.post(
        'https://viking-250012.appspot.com/api/make-request',
        body: _payload,
        headers: {
          "accept": "application/json",
          "content-type": "application/json"
        });
    if (response.statusCode == 200 || response.statusCode == 201) {
      prefs.setBool('showResults', true);
      prefs.setBool('isBooked', true);
      print('I got submitted ${response.body}');
      prefs.setString('lastOrderedServiceProviderId', '$_uid');
      prefs.setString('serviceProviderName', _serviceProviderName);
      prefs.setString('serviceProviderPicture', _serviceProviderPhoto);
      prefs.setString('serviceProviderPrice', _price);
      prefs.setString('serviceProviderToken', serviceProviderToken);
      prefs.setString('serviceProviderUid', _uid);
      prefs.setString('serviceProvided', _requestedSaloonService);
      prefs.setString('servicePrice', _price);
      prefs.setString('serviceHours', serviceHours);
      prefs.setString('providerphoneNumber', _serviceProviderNamePhone);
      Navigator.pop(context);
     
  Navigator.pushReplacementNamed(context, '/success');
 Firestore.instance.collection('users').document('$_userId').updateData({
      'request_made': true
});
requestServiceNotifier(_fcmToken,
"New Service Request",
"$requesteeName has requested for $_requestedSaloonService"); // fcm token will go here
      return fetchResults;
    } else {
      print(response.body);
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/error');
      throw Exception('Oops something wrong');
    }
  }

@override
  void initState() {
    serviceProviderToken = widget.serviceProviderToken;
    _uid = widget.uid;
    _requestedSaloonService = widget.serviceOffered;
    _price = widget.price;
    _location = widget.location;
    serviceHours = widget.duration;
    _requestedDescription = widget.description;
    _website = widget.website;
    _shippingAddress = widget.shippingAddress;
    _commentRate = widget.commentRate;
    _docUid = widget.docID;
    _longitude = widget.longitude;
    _latitude = widget.latitude;
    _serviceProviderName = widget.serviceProviderName;
   _serviceProviderNamePhone = widget.serviceProviderNamePhone;
   _serviceProviderPhoto = widget.serviceProviderPhoto;
   _fcmToken = widget.fcmToken;
  
    localStorage();
    super.initState();
  }

  Widget bottomBarButton(){
    return StreamBuilder(builder:(context, request_canceler){
          if(!request_canceler.hasData){
            return SizedBox.shrink();
          }
            if(request_canceler.data['request_made'] == false){
              return StreamBuilder(stream: Firestore.instance
          .collection('saloonServiceProvider')
          .document('${_uid}').snapshots(),builder: (context, snapshot){
            if(!snapshot.hasData){
 return SizedBox.shrink();
}else{
    return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

StreamBuilder(builder: (context,snapshotInner){
                              try{
if(!snapshotInner.hasData){
                                print('No changes');
                                return Container(child: Text(''),);
                              }
                              if(snapshotInner.data['isPremium'] == false){
                                print('**** GUI');
                                // print(snapshotInner.data['isRequested']);
                                return Container(child: Text(''),);
                              } else{
                          print(snapshotInner.data);
                                print('**** POXi');
                                return Container(margin: EdgeInsets.all(8.0),
              width: 148.0,child: RaisedButton(
                  child: Row(
                    children: <Widget>[
                      // Icon(Icons.image,color: Colors.black,),
                      Text('More Booking',
                          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16.0))
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  onPressed: (){
                    
                    if(_website == 'null'){
Toast.show('Oops website url not available', context,backgroundColor: Colors.red,duration: 5);
                    }else{
                    // _launchURL('${_website}');
                    // '$_website',true,_website, _shippingAddress
                    shipUrl('$_website', true,_website, _shippingAddress);
                    }
                  
                  },
                  color: Colors.blueAccent,
                  padding: EdgeInsets.all(15.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),color: Colors.transparent,
            );
                              }
                              }catch(err){
                                return Container(child: Text(''),);
                              }
                            },stream: Firestore.instance
          .collection('referalEngine')
          .document('${_uid}').snapshots()),// be back

            isSwitched ? Container(margin: EdgeInsets.all(8.0),
              width: 135.0,child: RaisedButton(
                  child: Row(
                    children: <Widget>[
                      // Icon(Icons.image,color: Colors.black,),
                      Text('Shipping',
                          style: TextStyle(color: Colors.black,
                          fontWeight: FontWeight.bold,fontSize: 16.0))
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  onPressed: (){

                               if(_shippingAddress == 'null'){
Toast.show('Oops shipping address  not available', context,backgroundColor: Colors.red,duration: 5);
                    }else{
                    shipUrl('$_shippingAddress',false,_website, _shippingAddress);
                    }

                  },
                  color: Colors.white,
                  padding: EdgeInsets.all(15.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),color: Colors.transparent,
            ) : StreamBuilder(builder: (context,crack){
              if(!crack.hasData){
                return Container(margin: EdgeInsets.all(8.0),
              width: 135.0,child: RaisedButton(
                  child: SizedBox(child: 
    CircularProgressIndicator(backgroundColor: Colors.black),
    height: 18.5,width: 18.5,),
                  onPressed: (){
             makeServiceRequest();

                  },
                  color: Colors.white,
                  padding: EdgeInsets.all(15.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),color: Colors.transparent,
            );
              }
            // to be back here

              return crack.data['isRequested'] == true ? SizedBox.shrink() : Container(margin: EdgeInsets.all(8.0),
              width: 135.0,child: RaisedButton(
                  child: Row(
                    children: <Widget>[
                      // Icon(Icons.image,color: Colors.black,),
                      //comebacktome
                      Text('Request',
                          style: TextStyle(color: Colors.black,
                          fontWeight: FontWeight.bold,fontSize: 16.0))
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  onPressed: (){
             makeServiceRequest();

                  },
                  color: Colors.white,
                  padding: EdgeInsets.all(15.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),color: Colors.transparent,
            );
            },stream: Firestore.instance
          .collection('saloonServiceProvider')
          .document('${_uid}').snapshots(),)
            ],);// regular view;
}

        },);
            }else{
              return FlatButton(
                onPressed: () {
             cancelRequest();
                },
                child: Padding(
                  child: Text(
                    'Cancel Request',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                        fontWeight: FontWeight.w600,fontFamily: 'NunitoSans'),
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.only(top: 11.0, bottom: 11.0),
                ),
                color: Colors.redAccent,
              );
            }
        }, stream: Firestore.instance.collection('users').document('$_userId').snapshots());
  }

Widget mainWView(){
return Center(
                child: ListView(
                  children: <Widget>[
                    Center(
                      child: Padding(
                        padding:
                            EdgeInsets.only(top: 20.0, left: 0, right: 20.0),
                        child: Column(
                          children: <Widget>[
                          
                            StreamBuilder(builder: (context,snapshot){
                              if(!snapshot.hasData){
                                print('No changes');
                                return Container(child: Text(''),);
                              }
                              if(snapshot.data['isRequested']){
                                print('**** GUI');
                                print(snapshot.data['isRequested']);
                              
                                return Center(child: Center(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
Container(
                              child: CircleAvatar(
                                foregroundColor: Theme.of(context).primaryColor,
                                backgroundColor: Colors.yellow[800],
                                backgroundImage: NetworkImage(
                                    '${snapshot.data['profilePicture']}'),
                                radius: 65.0,
                              ),
                              margin: EdgeInsets.only(left: 18.0, bottom: 10.0),
                            ),
                             Padding(child: Text('${snapshot.data['fullName']}', 
  style: TextStyle(color: Colors.black87,fontSize: 18.0,fontWeight: FontWeight.w600,fontFamily: 'NunitoSans',)),
  padding: EdgeInsets.only(top:5.5,left: 5.5),),

                                  Row(mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                   
                                  Container(
                                    height: 14.0,
                                    width: 14.0,
//                                    color: Colors.green,
                                      // decoration: new BoxDecoration(
                                      //     color: Colors.red,
                                      //     borderRadius: BorderRadius.all(Radius.circular(40.0)))

                                  ),
                                  Padding(child: Container(width: 200.0,child: Padding(child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(text: '● Currently Booked,             ',children: [
                                      TextSpan(text: 'try another one')
                                    ],
                                   style: TextStyle(color: Colors.red,fontSize: 15,fontFamily: 'Lexand'),
                                  ),
                                  
                                  ),padding: EdgeInsets.all(3.0)),),padding: EdgeInsets.all(5.3),),
                                ],
                              )
                                ],),),);
                              } else {

                                return Center(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
Container(
                              child: CircleAvatar(
                                foregroundColor: Theme.of(context).primaryColor,
                                backgroundColor: Colors.yellow[800],
                                backgroundImage: NetworkImage(
                                    '${snapshot.data['profilePicture']}'),
                                radius: 65.0,
                              ),
                              margin: EdgeInsets.only(left: 18.0, bottom: 10.0),
                            ),
                             Padding(child: Text('${snapshot.data['fullName']}', 
  style: TextStyle(color: Colors.black87,fontSize: 18.9,fontWeight: FontWeight.w600,fontFamily: 'NunitoSans',)),
  padding: EdgeInsets.only(top:5.5,left: 5.5),),

                                  Row(mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                   
                                  Container(
                                    height: 14.0,
                                    width: 14.0,
//                                    color: Colors.green,
                                      decoration: new BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.all(Radius.circular(40.0)))

                                  ),
                                  Padding(child: Text('Available', style: TextStyle(color: Colors.green,fontSize: 16.0),),padding: EdgeInsets.all(5.3),),
                                ],
                              )
                                ],),);
                              }
                            },stream: Firestore.instance
          .collection('saloonServiceProvider')
          .document('${_uid}').snapshots()),
                            
                            SizedBox(height:9.0,),
                            ListTile(
                                leading: Icon(Icons.business_center,
                                    color: Colors.yellow[800]),
                                title: Text(
                                  DemoLocalizations.of(context).Service,
                                  style: TextStyle(fontWeight: FontWeight.w600,  fontFamily: 'NunitoSans',
                                      letterSpacing: .4,),
                                ),
                                subtitle: Padding(child: Text('${_requestedSaloonService}',
                                    style: TextStyle(
                                     
                                      fontSize: 17.0
                                    )),padding: EdgeInsets.only(top: 3.0,bottom: 4.0),)),
                                     Container(
                              child: Divider(
                                indent: 57.8,
                              ),
                              padding: EdgeInsets.only(left: 12.0),
                            ),
                             
                            
                            ListTile(
                              leading: Icon(Icons.monetization_on,
                                  color: Colors.yellow[800]),
                              title: Text(
                                DemoLocalizations.of(context).Price,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Padding(child: Text('${_price}',
                                  style: TextStyle(
                                    fontSize: 17.0,
                                  )),padding: EdgeInsets.only(top: 3.0,bottom: 4.0)),
                            ),
                            Container(
                              child: Divider(
                                indent: 57.8,
                              ),
                              padding: EdgeInsets.only(left: 12.0),
                            ),
                                    ListTile(
                                leading: Icon(Icons.description,
                                    color: Colors.yellow[800]),
                                title: Text(
                                  'Description',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Padding(child: Text('${_requestedDescription}',
                                    style: TextStyle(
                                      fontSize: 17.0,
                                    )),padding: EdgeInsets.only(top: 3.0,bottom: 4.0))),
                                     
                            Container(
                              child: Divider(
                                indent: 57.8,
                              ),
                              padding: EdgeInsets.only(left: 12.0),
                            ),
                            
                            ListTile(onTap: (){
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => NavigationMaps(
                                                latitude: _latitude,
                                                longitude: _longitude,
                                                serviceProviderName:
                                                    _serviceProviderName,
                                                phoneNumber:
                                                    _serviceProviderNamePhone,
                                              )));
                            },
                              trailing: Padding(
                                child: Icon(
                                  Icons.chevron_right,
                                  color: Colors.yellow[900],
                                  size: 25.0,
                                ),
                                padding: EdgeInsets.only(left: 56.0)
                              ),
                              leading: Icon(Icons.location_on,
                                  color: Colors.yellow[800]),
                              title: Text(
                                  DemoLocalizations.of(context).Location,
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Padding(child:Text(_location,
                                  style: TextStyle(
                                    fontSize: 17.0,
                                  )), padding: EdgeInsets.only(top: 3.0,bottom: 4.0)),
                            ),
                            Container(
                              child: Divider(
                                indent: 57.8,
                              ),
                              padding: EdgeInsets.only(left: 12.0),
                            ),
                            
                            ListTile(
                              onTap: (){
                               showReviews(_uid);
                              },
                              trailing: Padding(
                                child: Icon(
                                  Icons.chevron_right,
                                  color: Colors.yellow[900],
                                  size: 25.0,
                                ),
                                padding: EdgeInsets.only(left: 56.0)
                              ),
                                leading: Icon(FontAwesomeIcons.starHalfAlt,
                                    color: Colors.yellow[800]),
                                title: Text(
                                  'Reviews',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Padding(child: Text('$_commentRate',
                                    style: TextStyle(
                                      fontSize: 17.0,
                                    )),padding: EdgeInsets.only(top: 3.0,bottom: 4.0),)),
                                      Container(
                              child: Divider(
                                indent: 57.8,
                              ),
                              padding: EdgeInsets.only(left: 12.0),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
}
  

  @override
dispose(){
  super.dispose();
}

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Service Provider',
            style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w900,fontSize: 17),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          elevation: 1.0,
        ),
        body: StreamBuilder(builder: (BuildContext context, connect){
          if(connect.hasError) return Text('Check your internet connection');
          switch(connect.connectionState){
            case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator(),);
            break;
            default:
               return connect.data.toString() == 'ConnectivityResult.none' ? 
               Center(child: Text('Check your internet connection'),): mainWView();
          }
        },stream: Connectivity().checkConnectivity().asStream(),),
                  // I will be back 
        bottomNavigationBar:  StreamBuilder(builder: (BuildContext context, connect){
          if(connect.hasError) return Text('Check your internet connection');
          switch(connect.connectionState){
            case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator(),);
            break;
            default:
               return connect.data.toString() == 'ConnectivityResult.none' ? 
               Center(child: Text('Check your internet connection'),): bottomBarButton();
          }
        },stream: Connectivity().checkConnectivity().asStream(),),
        backgroundColor: Colors.white);
  }
}