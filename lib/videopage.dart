import 'dart:convert';
import 'dart:io';
import './orderpage.dart';
import './spinner_animation.dart';
import './swiper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:share/share.dart';
import 'app_services/localizer.dart';
import 'appicons.dart';
import 'audiospinner.dart';
import 'comments.dart';
import 'contacts.dart';
import 'dimen.dart';
import 'home_header.dart';

class VideoPageWidget extends StatefulWidget {

  @override
  _VideoPageWidgetState createState() => new _VideoPageWidgetState();
}

class _VideoPageWidgetState extends State<VideoPageWidget> {
final TextEditingController controller = TextEditingController();
bool isTextValid = false;
File fileToBeUploaded;
String uid;
String countryCode = 'UG';
@override
initState(){
  super.initState();
  _getPhoneNumber();
}

_getPhoneNumber() async{
   SharedPreferences prefs = await SharedPreferences.getInstance();
   setState(() {
     uid = prefs.getString('uid');
     countryCode = prefs.getString('countryCode') ?? 'UG';
   });
}

  Widget VideoPageWidget(BuildContext context){
    return StreamBuilder(stream: Firestore.instance.collection('servicesvideofeed').where('country',isEqualTo: '$countryCode')
              .orderBy('created_at', descending: true).snapshots(),builder: (BuildContext context,AsyncSnapshot<QuerySnapshot>snapshot){
                if(snapshot.hasError) return Center(child: Text('Oops something went wrong'),);
                
               switch (snapshot.connectionState) {
          case ConnectionState.waiting: return SpinKitPulse(
  color: Colors.white,
  size: 66.0,
);
          default:
            return snapshot.data.documents.length > 0 ? PageView.builder(
        scrollDirection: Axis.vertical,
        itemBuilder: (context, position) {
          // AppVideoPlayer().
          return Container(
            color: Colors.black,
            child: Stack(
              children: <Widget>[AppVideoPlayer(url: '${snapshot.data.documents[position]['servicePhotoUrl']}',index: position,), 
           onScreenControls(docID: '${snapshot.data.documents[position]['docID']}',
           commentRate: '',fcmToken: '${snapshot.data.documents[position]['fcm_token']}',
           description: '${snapshot.data.documents[position]['description']}',
           duration: '${snapshot.data.documents[position]['time']}',shippingAddress: '${snapshot.data.documents[position]['shippingAddress']}',
           latitude: '${snapshot.data.documents[position]['latitude']}',
           longitude: '${snapshot.data.documents[position]['longitude']}',
           location: '${snapshot.data.documents[position]['location']}',
           price: '${snapshot.data.documents[position]['price']}',
           serviceOffered: '${snapshot.data.documents[position]['serviceOffered']}',
           serviceProviderName: '${snapshot.data.documents[position]['fullName']}',
           serviceProviderNamePhone: '${snapshot.data.documents[position]['phoneNumber']}',
           serviceProviderPhoto: '${snapshot.data.documents[position]['profilePicture']}',
           serviceProviderToken: '${snapshot.data.documents[position]['serviceProviderToken']}',
           uid: '${snapshot.data.documents[position]['uid']}',userId: uid,website: '${snapshot.data.documents[position]['website']}',)],
            ),
          );
        },
        itemCount: snapshot.data.documents.length): Center(
          child: Text('Looks like no story has been shared.',style: TextStyle(color: Colors.white),),);
        }

                
              });
  }

  
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(child: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: <Widget>[
      VideoPageWidget(context)],),
      
      ),onWillPop: (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Swiper()));
        return Future.value(false);
      },);
  }
}

class AppVideoPlayer extends StatefulWidget {
  final String url;
  final int index;
  AppVideoPlayer({this.url,this.index});
  @override
  _AppVideoPlayerState createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
 VideoPlayerController _controller;
  Set isPlaying = new Set();
  @override
  void initState() {
    // print(widget.url);
    super.initState();
    _controller = VideoPlayerController.network(
        '${widget.url}')
      ..initialize().then((_) {
        _controller.play();
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.initialized
          ? InkWell(child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),onTap: (){
              setState(() {
      if (_controller.value.isPlaying) {
        setState(() {
          isPlaying.add(widget.index);
        });
        _controller.pause();
      } else {
        setState(() {
          isPlaying.remove(widget.index);
        });
        _controller.play();
      }
    });
            },)
          : SpinKitPulse(
  color: Colors.white,
  size: 66.0,
),
    );
  }

  @override
  void dispose() {
    super.dispose();
     _controller.pause();
    _controller.dispose();
  }
}


class onScreenControls extends StatefulWidget {
final String serviceProviderPhoto;
final String latitude;
final String longitude;
final String serviceProviderName;
final String serviceProviderNamePhone;
final String docID;
final String commentRate;
final String uid;
final String serviceOffered;
final String userId;
final String location;
final String price;
final String serviceProviderToken;
final String duration;
final String description;
final String website;
final String shippingAddress;
final String fcmToken;
  onScreenControls({this.serviceProviderPhoto, this.latitude, this.longitude, this.serviceProviderName, 
  this.serviceProviderNamePhone, this.docID, this.commentRate, this.uid, this.serviceOffered, this.userId, this.location, this.price, this.serviceProviderToken, this.duration, this.description, this.website, this.shippingAddress, this.fcmToken});
  @override
  _onScreenControlsState createState() => new _onScreenControlsState();
}

class _onScreenControlsState extends State<onScreenControls> {

  Widget videoControlAction({IconData icon, String label, double size = 35}) {
  return Padding(
    padding: EdgeInsets.only(top: 10, bottom: 10),
    child: Column(
      children: <Widget>[
        Icon(
          icon,
          color: Colors.white,
          size: size,
        ),
        Padding(
          padding: EdgeInsets.only(
              top: Dimen.defaultTextSpacing, bottom: Dimen.defaultTextSpacing),
          child: Text(
            label ?? "",
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
        )
      ],
    ),
  );
}

Widget videoDesc(String username,String caption,String comment) {
  return Container(
    padding: EdgeInsets.only(left: 16, bottom: 60),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 7, bottom: 3),
          child: Text(
            widget.serviceOffered,
            style: TextStyle(
                fontSize: 16.5, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
        Flexible(child: Padding(
          padding: EdgeInsets.only(top: 1, bottom: 3),
          child: AutoSizeText(
  widget.price,overflow: TextOverflow.ellipsis,
 style: TextStyle(color: Colors.yellow[800],
fontSize: 14,
fontWeight: FontWeight.w300),wrapWords: true,softWrap: true,
 maxLines: 1,
),
        ),),Flexible(child: Padding(
          padding: EdgeInsets.only(top: 1, bottom: 7),
          child: AutoSizeText(
  widget.description,overflow: TextOverflow.ellipsis,
 style: TextStyle(color: Colors.white,
fontSize: 14,
fontWeight: FontWeight.bold),wrapWords: true,softWrap: true,
 maxLines: 1,
),
        ),),
        Row(
          children: <Widget>[
           comment.isNotEmpty ? Icon(
              Icons.alarm,
              size: 19,
              color: Colors.white,
            ): SizedBox.shrink(),
            Flexible(child: Text(
    widget.duration,
    style: TextStyle(color: Colors.white,
fontSize: 14,
fontWeight: FontWeight.w300),
    
  ),)
          ],
        ),
      ],
    ),
  );
}

Widget userProfile() {
  return Padding(
    padding: EdgeInsets.only(top: 10, bottom: 10),
    child: Column(
      children: <Widget>[
        Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                image:   DecorationImage(
                        image: new CachedNetworkImageProvider(
                       widget.serviceProviderPhoto),
                          fit: BoxFit.cover,
                            ), // to be back here 
                  border: Border.all(
                      color: Colors.white,
                      width: 1.0,
                      style: BorderStyle.solid),
                  color: Colors.black,
                  shape: BoxShape.circle),
            ),
            Container(
              margin: EdgeInsets.only(top: 50),
              height: 18,
              width: 18,
              child: Icon(Icons.add, size: 10, color: Colors.white),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 42, 84, 1),
                  shape: BoxShape.circle),
            )
          ],
        )
      ],
    ),
  );
}
String numberFormatter(String count){
 try{
int convertCount = int.parse(count);
 if(convertCount > 999){
   return '${convertCount/1000}k';
 }else if (convertCount > 999999){
   return '${convertCount/1000000}m';
 }

 return convertCount == 0 ? '': convertCount;
 }catch(err){
return '';
 }
 
}
  @override
  Widget build(BuildContext context) {
    return new Container(
    child: Row(
      children: <Widget>[
        Expanded(flex: 5, child: videoDesc(widget.serviceOffered, widget.price, widget.description)),
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.only(bottom: 60, right: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                InkWell(child: userProfile(),onTap: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrderPage(
                                                  serviceProviderPhoto: widget.serviceProviderPhoto,
                                                  latitude: 4.0,
                                                  longitude: 4.0,
                                                  serviceProviderName: widget.serviceProviderName,
                                                  serviceProviderNamePhone: widget.serviceProviderName,
                                                  docID: widget.docID,
                                                  commentRate: widget.commentRate,
                                                  uid:
                                                      widget.uid,
                                                  serviceOffered:
                                                      widget.serviceOffered,
                                                  userId: widget.userId,
                                                  location:
                                                      widget.location,
                                                  price:
                                                      widget.price,
                                                  serviceProviderToken:
                                                      widget.serviceProviderToken,
                                                  duration:
                                                      widget.serviceProviderToken,
                                                  description:
                                                      widget.description,
                                                      website: widget.website,
                                                      shippingAddress: widget.shippingAddress,
                                                      fcmToken: widget.fcmToken ,
                                                )));
                },),
                 InkWell(child: 
                videoControlAction(icon: Icons.shopping_cart, label: ''), onTap: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ServicesContacts(
                                                  serviceProviderPhoto: widget.serviceProviderPhoto,
                                                  latitude: 4.0,
                                                  longitude: 4.0,
                                                  serviceProviderName: widget.serviceProviderName,
                                                  serviceProviderNamePhone: widget.serviceProviderName,
                                                  docID: widget.docID,
                                                  commentRate: widget.commentRate,
                                                  uid:
                                                      widget.uid,
                                                  serviceOffered:
                                                      widget.serviceOffered,
                                                  userId: widget.userId,
                                                  location:
                                                      widget.location,
                                                  price:
                                                      widget.price,
                                                  serviceProviderToken:
                                                      widget.serviceProviderToken,
                                                  duration:
                                                      widget.serviceProviderToken,
                                                  description:
                                                      widget.description,
                                                      website: widget.website,
                                                      shippingAddress: widget.shippingAddress,
                                                      fcmToken: widget.fcmToken ,
                                                )));
                },),
               

              ],
            ),
          ),
        )
      ],
    ),
  );
  }
}