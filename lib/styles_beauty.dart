import './storiesComments.dart';
import './stylesbyuser.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:random_string/random_string.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:transparent_image/transparent_image.dart';
import './viewfull_image.dart';
import './comments.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './watchvideo.dart';
import 'app_services/localizer.dart';
import 'package:connectivity/connectivity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:file_utils/file_utils.dart';
import 'dart:ui' as ui;

class StylesBeauty {
  final String fullName;
  final String servicePhoto;
  final String userId;
  final String uid;
  final String rating;
  final String profilePicture;
  final String doc_id;

  StylesBeauty(
      {this.fullName,
      this.servicePhoto,
      this.userId,
      this.uid,
      this.rating,
      this.profilePicture,
      this.doc_id});
  factory StylesBeauty.fromJson(Map<String, dynamic> json) {
    return StylesBeauty(
        fullName: json['fullName'],
        servicePhoto: json['servicePhoto'],
        userId: json['userId'],
        uid: json['doc_id'],
        rating: '${json['rating']}',
        profilePicture: json['profilePicture'],
        doc_id: json['doc_id']);
  }
}

class StylesBeautyWidget extends StatefulWidget {
  @override
  StylesBeautyWidgetState createState() => StylesBeautyWidgetState();
}

class StylesBeautyWidgetState extends State<StylesBeautyWidget> {
  File beautyPhotoUpload;
  bool notAvailable = false;
  bool isRequestedError = false;
  File _beautyPhoto;
  int likes = 0;
  final _saved = new Set();
  final _toggleText = new Set();
  final shouldTogglePlay = new Set();
  final isAlreadyDownloading = new Set();
  String objectId;
  Flushbar flushbar;
final TextEditingController controller = TextEditingController();
  List<StylesBeauty> resultsFetched = List();
  double paddingTitle = 67.0;
  File fileToBeUploaded;
  bool checkIfVideo;
  bool isTextValid = false;
  StreamSubscription<ConnectivityResult> subscription;
  String _actualName = 'Someone you know';
  bool downloading = false;
    var progress = "";
    var path = "No Data";
    var platformVersion = "Unknown";

 downloadFile(String url,int index,String fullName, String docId) async {
  setState(() {
    shouldTogglePlay.add(index); // imediately show downloder con
    downloading = true;
    progress = '1';
  });
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
      // isAlreadyDownloading.remove(index);
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
   await Firestore.instance.collection('userService').document(docId)
   .setData({'path':path},merge: true);
    if(mounted){
      setState((){
        downloading = false; // honcho
      });
    }
   }else{
     _handleInvalidPermissions(permissionStatus);
   }
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


  @override
  initState() {
    getName();
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
  removeNots();
    super.initState();
  }

removeNots() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
 await Firestore.instance.collection('users').document(prefs.getString('uid')).setData({
   'tvCount': 0
 },merge: true);
  }

 @override
  void dispose() {
    
    if(flushbar != null){
      flushbar.dismiss();
    }
    if(subscription != null){
      subscription.cancel();
    }
    super.dispose();
  }
getName() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  _actualName = prefs.getString('fullName');
}

sendNotificationsToAll() async {

String url = 'https://onesignal.com/api/v1/notifications';
Map<dynamic, dynamic> body = {
'app_id': '0a2fc101-4f5a-44c2-97b9-c8eb8f420e08',
'contents': {"en": "Stories"},
'included_segments': ["All"],
'headings': {"en": "$_actualName shared a new style"},
'data': {"type": "new-stories"},
 "small_icon": "@mipmap/ic_launcher",
 "large_icon": "@mipmap/ic_launcher"
}; // 'small_icon': '' ... final response =
 await http.post(url,
body: json.encode(body),
headers: {HttpHeaders.authorizationHeader: "Basic OThhY2RlNTEtZTE5YS00Y2E2LWE3NWUtYTUwOWY0MTJmNzIz",
"accept": "application/json",
"content-type": "application/json"
}
);
//  if(response.statusCode == 200 || response.statusCode == 201){
//    print('Passed');
//    print(response.body);
//  }else{
//    print('Failed')
//    print(response.body);
//  }


}

  shouldPickImage() async {
    FocusScope.of(context).unfocus(focusPrevious: true);
    ImagePicker.pickImage(source: ImageSource.camera).then((image) {
      if(image == null){
      return;
      } 
         checkIfVideo = false;
        _beautyPhoto = image;
        fileToBeUploaded = image;
      // setState(() {
        
      // });
    }).catchError((err) {
      print(err);
    });
  }

stringChopper(String word) {
  if(word.length > 41){
    return word.substring(0, 41) + '...';
  }else{
    return word;
  }
}

  shouldPickVideo() async {
    ImagePicker.pickVideo(source: ImageSource.gallery).then((image) {
      if(image == null){
      return;
      }
      setState(() {
         checkIfVideo = true;
        _beautyPhoto = image;
        fileToBeUploaded = image;
      });
    });
  }



shouldPickImageFull(BuildContext context) async {
FocusScope.of(context).unfocus(focusPrevious: true);
ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      if(image == null){
      return;
      } 
      print('state of image ${controller.text}');
         checkIfVideo = false;
        _beautyPhoto = image;
        fileToBeUploaded = image;
    }).catchError((err) {
      print(err);
    });
  
  }



    Widget inputBar(){
return  Padding(child:Padding(
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
            SizedBox(width: 8.0),
            InkWell(child: Icon(FontAwesomeIcons.camera,
                size: 20.0, color: Color(0xff203152)),onTap: (){
         shouldPickImage();
                },),
            SizedBox(width: 8.0),
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
                  errorText: isTextValid ? 'Storie Can\'t Be Blank' : null,
                  hintText: 'Type a message',
                  border: InputBorder.none,
                ),
              ),
            ),
            InkWell(child: Icon(FontAwesomeIcons.image,
                size: 20.0, color: Color(0xff203152),),onTap: (){
                  
                  shouldPickImageFull(context);
                },),
            SizedBox(width: 8.0),
            // InkWell(
            //   onTap: (){
            //      shouldPickVideo();
            //   },
            //   child: Icon(FontAwesomeIcons.video,
            //     size: 20.0, color: Color(0xff203152)),),
            SizedBox(width: 8.0),
          ],
        ),
      ),
    ),
          ),
          SizedBox(
            width: 5.0,
          ),
          GestureDetector(
            onTap: () {
             postImage(fileToBeUploaded, checkIfVideo);
            },
            child: CircleAvatar(
              child: Icon(FontAwesomeIcons.paperPlane),
            ),
          ),
        ],
      ),
    ),          padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom));
    } 


  void _settingModalBottomSheet(context) {
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
            Center(child: Padding(child: 
            Text('What\'s new ?',style: 
            TextStyle(color: Colors.white,
            fontWeight: FontWeight.w600,fontSize: 28.6,
            letterSpacing: .9,
            fontFamily:'Merienda'),
            textAlign: TextAlign.center),padding: EdgeInsets.only(top:18.0,bottom: 1.0,left: 18.0,right: 18.0),)),
            Padding(child: 
            Text('Share with the world',style: 
            TextStyle(
              wordSpacing: -0.800,
              color: Colors.white,
            fontWeight: FontWeight.w400,fontSize: 17.3,
            letterSpacing: .9,
            fontFamily:'NunitoSans'),
            textAlign: TextAlign.center),padding: EdgeInsets.all(1.0),),
            SizedBox(height: 78.0,),
            // ListView.builder(itemBuilder: (BuildContext),) inputBar()
           //  FocusScope.of(context).unfocus(focusPrevious: true);
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
            SizedBox(width: 8.0),
            InkWell(child: Icon(FontAwesomeIcons.camera,
                size: 20.0, color: Color(0xff203152)),onTap: (){
                  ImagePicker.pickImage(source: ImageSource.camera).then((image) {
      if(image == null){
      return;
      } 
      setState(() {
         checkIfVideo = false;
        _beautyPhoto = image;
        fileToBeUploaded = image;
      });
    }).catchError((err) {
      print(err);
    });
                },),
            SizedBox(width: 8.0),
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
                  errorText: isTextValid ? 'Storie Can\'t Be Blank' : null,
                  hintText: 'Type a message',
                  border: InputBorder.none,
                ),
              ),
            ),
            InkWell(child: Icon(FontAwesomeIcons.image,
                size: 20.0, color: Color(0xff203152),),onTap: (){
                  shouldPickImageFull(context);
                },),
            SizedBox(width: 8.0),
            // InkWell(
            //   onTap: (){
            //      shouldPickVideo();
            //   },
            //   child: Icon(FontAwesomeIcons.video,
            //     size: 20.0, color: Color(0xff203152)),),
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
             postImage(fileToBeUploaded, checkIfVideo);
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
        });
  }

  likePhoto(uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // /rate-style/:uid/:rating
    final response = await http.get(
        'https://viking-250012.appspot.com/api/rate-style/${uid}/${likes}/${prefs.getString('uid')}');

    if (response.statusCode == 200 || response.statusCode == 201) {
//      getStylesBeauty();
      return resultsFetched;
    } else {
      print('something went wrong');
    }
  }

  unlikePhoto(uid) async {
    // /rate-style/:uid/:rating
    final response = await http.get(
        'https://viking-250012.appspot.com/api/unrate-style/${uid}/${likes}');
    if (response.statusCode == 200 || response.statusCode == 201) {
//      getStylesBeauty();
      return resultsFetched;
    } else {
      print('something went wrong');
    }
  }

  



  postImage(File image, bool isVideo) async {
    // final url = randomAlpha(10);
    // setState(() {
     
    // });
     controller.text.isEmpty ? isTextValid = true : isTextValid = false;
     print('check if checked ${controller.text.isEmpty} ${isTextValid}');
     print(isTextValid);
     print(controller.text);

    if(isTextValid){
      return;
    }
    Navigator.of(context).pop();
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
                      '${DemoLocalizations.of(context).processing}',
                      style: TextStyle(fontSize: 17.0),
                    ),),
                  ),
                )
              ],
            ),
          );
        });
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final url = randomAlpha(10);
    final defaultVideo = 'https://firebasestorage.googleapis.com/v0/b/esalonbusiness-d3f3d.appspot.com/o/snowyscreen.gif?alt=media&token=35458d60-5e73-4e7e-ae13-aad26ff095ec';
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('${url}');
    final StorageUploadTask task =  firebaseStorageRef.putFile(image);


    task.onComplete.then((image) {
      firebaseStorageRef.getDownloadURL().then((result) {
        final Map<String, dynamic> service = {
          'servicePhoto': result.toString(),
          'userId': prefs.getString('uid'),
          'fullName': prefs.getString('fullName'),
          'profilePicture': prefs.getString('profilePicture'),
          'isVideo': isVideo,
          'storyTitle': controller.text,
          'hours': DateTime.now().hour,
          'doc_id': url,
          'videoDefault': defaultVideo,
          'path': 'N/A',
          'isChat': false
        };

        final Map<String, dynamic> transcoderPayload = {
          'uid': url,
          'imageUrl': result.toString(),
          'isBusiness': false,
          'path': 'N/A',
          'isChat': false,
          'messageId': 'N/A'
        };

        http.post('https://viking-250012.appspot.com/api/upload-feed',
            body: json.encode(service),
            headers: {
              "accept": "application/json",
              "content-type": "application/json"
        }).then((response) {
          if (response.statusCode == 200 || response.statusCode == 201) {

            Navigator.of(context,rootNavigator: true).pop();
              Fluttertoast.showToast(
        msg: "Uploaded Successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.greenAccent,
        textColor: Colors.white,
        fontSize: 15.0
    );
    sendNotificationsToAll();
        if(isVideo){
          print('I got firead in videos clause');
   http.post('http://35.246.43.91/crucken-transcord',
            body: json.encode(transcoderPayload),
            headers: {
              "accept": "application/json",
              "content-type": "application/json"
   }).then((onValue){
print('transcoded image');
            }).catchError((onError){
print('failed to transcord image');
            });

        }
                controller.clear();
          } else {
             Navigator.of(context,rootNavigator: true).pop();
             Fluttertoast.showToast(
        msg: "Oops something went wrong!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 15.0
    );
            print('succ*********');
            throw Exception('Oops something wrong');
          }
        });
      });
    });
  }

Future<ui.Image> _getImage(String imageUrl) {
     Completer<ui.Image> completer = new Completer<ui.Image>();
    new NetworkImage('$imageUrl')
      .resolve(new ImageConfiguration())
      .addListener(ImageStreamListener((ImageInfo image, bool synchronousCall) {
        // var myImage = image.image;
        // Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
        completer.complete(image.image);
      }));
    return completer.future;
  }
  Widget build(BuildContext context) {
    // double deviceHeight = MediaQuery.of(context).size.height;
    return WillPopScope(child: SafeArea(child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Stories',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Merienda', fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black87),
            centerTitle: true,
            elevation: 0.4,
            
          ),
          body: StreamBuilder(
              stream: Firestore.instance.collection('userService')
              .orderBy('created_time', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
          return new Center(child: Text('Check your internet connection'),);
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(strokeWidth: 5.0),
                  );
                  break;
                  default:
                  return ListView.builder(itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  final _isAlreadySaved = _saved.contains(index);
                  final _istoggled = _toggleText.contains(index);
                  return Card(
                              margin: EdgeInsets.only(top: 3.0),
                              elevation: 0.3,
                              child: new Column(
                                 mainAxisAlignment: MainAxisAlignment.start,
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  // crossAxisAlignment:
                                  //     CrossAxisAlignment.stretch,
                                  children: [
                                    Wrap(
                                      spacing: -1.0,
                                      children: <Widget>[
                                        SizedBox(height: 20.0),
                                        ListTile(

                                          contentPadding: EdgeInsets.symmetric(horizontal: 3.0),
                                          leading: Padding(
                                          child: Container(
                                            width: 44.0,
                                            height: 44.0,
                                            margin: EdgeInsets.only(top:1.8),
                                      //       decoration: new BoxDecoration(
                                      //         gradient: new LinearGradient(
                                      //             colors: [
                                      //               Colors.purple,
                                      //               Colors.yellow
                                      // ]),
                                      //         borderRadius: new BorderRadius
                                      //                 .all(
                                      //             new Radius.circular(50.0)),
                                      //         border: new Border.all(
                                      //           color: Colors.white,
                                      //           width: 1.3,
                                      //           style: BorderStyle.solid
                                      //         ),

                                      //       ),
                                            child: InkWell(child: Container(
                                              width: 44.0,
                                              height: 44.0,
                                              decoration: new BoxDecoration(

                                                color: Colors.white,
                                                image: new DecorationImage(
                                                  image: new CachedNetworkImageProvider(
                                                      '${snapshot.data.documents[index]['profilePicture']}'),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius: new BorderRadius
                                                        .all(
                                                    new Radius.circular(50.0)),
                                                border: new Border.all(
                                                  color: Colors.white,
                                                  width: 0.0,
                                                ),
                                              ),
                                            ),onTap: (){
                                              Navigator.
                                              push(context, MaterialPageRoute(
                                                builder: (BuildContext context) => 
                                                StylesByUser(targetUid: '${snapshot.data.documents[index]['userId']}',fullName: '${snapshot.data.documents[index]['fullName']}',)));
                                            },),
                                          ),
                                          padding: EdgeInsets.only(
                                              top: 5.0,
                                              left: 5.0,
                                              right: 0,
                                              bottom: 8.0),
                                        )
,
                                          title: RichText(
  text: TextSpan(
    text: '@',
    style: TextStyle(
             wordSpacing: 0.1,
             color: Colors.blue[300],
             fontSize: 14,
             fontWeight: FontWeight.bold,
             fontFamily: 'NunitoSans',letterSpacing: .4),
    children: <TextSpan>[
      TextSpan(text: '${snapshot.data.documents[index]['fullName']}', 
      style: TextStyle(color: Colors.black87)
    ),

    ],
  ),
), subtitle: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
       Text('${snapshot.data.documents[index]['full_date']} • ',style: TextStyle(
      color: Colors.grey[500],
      wordSpacing: -0.900,
      fontSize: 13.7,
      fontFamily: 'Rukie',
      fontWeight: FontWeight.w400)),
      Icon(FontAwesomeIcons.globeAfrica,
      color: Colors.grey[500],size: 13.0,)
                                        ]),),
                                   _istoggled ? InkWell(
                                     onTap: (){
                                        setState(() {
                                          _toggleText.remove(index);
                                        });
                                     },
                                     child: Padding(child: Text(
                                          '${snapshot.data.documents[index]['storyTitle']}',
                                          style: TextStyle(
                                            color: Color(0xFF404040),
                                            letterSpacing: .2,
                                            fontWeight: FontWeight.w100,
                                              fontSize: 15.0,
                                              fontFamily: 'Rukie'),
                                        ),padding: EdgeInsets.only(top:1.0,left: 7.0),),): InkWell(
                                          onTap: (){
                                            // am coming back
                                            setState(() {
                                              _toggleText.add(index);
                                            });
                                          },
                                          child: Padding(child: snapshot.data.documents[index]['storyTitle'].toString().length > 200 ?  RichText(
  text: TextSpan(
    text: '${snapshot.data.documents[index]['storyTitle'].toString().length > 200 ? snapshot.data.documents[index]['storyTitle'].toString().substring(0,200): snapshot.data.documents[index]['storyTitle']}',
    style: TextStyle(color: Color(0xFF484848),
                                            letterSpacing: .2,
                                            fontWeight: FontWeight.w100,
                                              fontSize: 14.0,
                                              fontFamily: 'Rukie',height: 1.2),
    children: <TextSpan>[
      TextSpan(text: ' Read more...', style: TextStyle(fontWeight: FontWeight.w100,color: Color(0xFF484848)))
    ],
  ),
) : Text(
                                          '${snapshot.data.documents[index]['storyTitle']}',
                                          style: TextStyle(
                                           color: Color(0xFF484848),
                                            letterSpacing: .2,
                                            fontWeight: FontWeight.w100,
                                              fontSize: 15.0,
                                              fontFamily: 'Rukie'),
                                        ),padding: EdgeInsets.only(top:1.0,left: 7.0),),)
                                      ],
                                    ),

                                    Flexible(
                                      fit: FlexFit.loose,
                                      flex: 500,
                                      child:
                                          snapshot.data.documents[index]
                                                  ['isVideo'] == true 
                                              ? InkWell( // to be back
                                                  child: CachedNetworkImage(
        imageUrl: "${snapshot.data.documents[index]['videoDefault']}",
        placeholder: (context, url) => Image.memory(kTransparentImage),
        errorWidget: (context, url, error) => Icon(Icons.image,color: Colors.grey),
     ),
      
                                                  onTap: () {
                                                    if('${snapshot.data.documents[index]['path']}' == 'N/A'){
downloadFile('${snapshot.data.documents[index]['servicePhoto']}',index,
                                                              '${snapshot.data.documents[index]['fullName']}',
                                                              '${snapshot.data.documents[index]['doc_id']}'
     );
                                                    }else{
                              Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    WatchVideo(
                                                          serviceName: snapshot
                                                                      .data
                                                                      .documents[
                                                                  index][
                                                              'fullName'],
                                                          photoUrl: snapshot
                                                                      .data
                                                                      .documents[
                                                                  index][
                                                              'path'],
                                                          isVideo: snapshot
                                                              .data
                                                              .documents[
                                                          index][
                                                          'isVideo'],
 )));   
                                                    }

                                                  },
                                                ) : InkWell(
                                                  child: CachedNetworkImage(
        imageUrl: "${snapshot.data.documents[index]['servicePhoto']}",
        placeholder: (context, url) => Image.memory(kTransparentImage),
        errorWidget: (context, url, error) => Icon(Icons.image,color: Colors.grey),
     ),
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    ViewImage(
                                                                      photoUrl: snapshot
                                                                          .data
                                                                          .documents[index]['servicePhoto'],
                                                                      serviceName: snapshot
                                                                          .data
                                                                          .documents[index]['fullName'],
                                                                          isVideo: snapshot
                                                                          .data
                                                                          .documents[index]['isVideo'],
                                                                    )));
                                                  },
                                                ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                         children: <Widget>[
                                       Container(height:31.0,child: Row(
                                              
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                       
                                                        _isAlreadySaved
                                                            ? IconButton(
                                                                icon: Icon(
                                                                  Icons
                                                                      .favorite,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                                onPressed: () {
                                                                  if (_isAlreadySaved) {
                                                                    setState(
                                                                        () {
                                                                      likes = 0;
                                                                      _saved.remove(
                                                                          index);
                                                                    });
                                                                    unlikePhoto(snapshot
                                                                            .data
                                                                            .documents[index]
                                                                        [
                                                                        'doc_id']);
                                                                  }
                                                                })
                                                            : IconButton(
                                                              color: Color(0xFF202020),
                                                                icon: Icon(Icons
                                                                    .favorite_border),
                                                                onPressed: () {
                                                                 likes = 1;
                                                                    _saved.add(
                                                                        index);
                                                                  likePhoto(snapshot
                                                                          .data
                                                                          .documents[
                                                                      index]['doc_id']);
                                                                }),
                                                                      
                                                                     IconButton(
                                                          icon: Icon(
                                                              FontAwesomeIcons
                                                                  .comment,color: Color(0xFF202020)),
                                                          onPressed: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            StoriesComments(
                                                                              uid: snapshot.data.documents[index]['doc_id'],
                                                                            )));
                                                          },
                                                        ),
                                                        
                                                      ]),
                                                      IconButton(icon: Icon(Icons.visibility),onPressed: (){
                                                        /// navigation goes here 
                                                        Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    ViewImage(
                                                                      photoUrl: snapshot
                                                                          .data
                                                                          .documents[index]['servicePhoto'],
                                                                      serviceName: snapshot
                                                                          .data
                                                                          .documents[index]['fullName'],
                                                                          isVideo: snapshot
                                                                          .data
                                                                          .documents[index]['isVideo'],
                                                                    )));
                                                      },),
                                                      
                                                ]),),
                                         Padding(
                                           padding: EdgeInsets.symmetric(horizontal: 14.0,vertical: 3.0),
                                           child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      snapshot.data.documents[index]['rating'] >= 1 ?
                      Text(
                    "Likes  ${snapshot.data.documents[index]['rating'] == '0' ? '' : snapshot.data.documents[index]['rating']}",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.w200,fontSize: 12.0,
                     fontFamily: 'Rukie',letterSpacing:0.4,color: Color(0xFF484848)
                    ),
                  ): SizedBox.shrink(),
                   snapshot.data.documents[index]['rating'] >= 1 ? SizedBox(height: 5.0,): SizedBox.shrink(),
                  snapshot.data.documents[index]['count'] >= 1 ?
                   InkWell(child: Text(
                    "View all ${snapshot.data.documents[index]['count']} comments",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.w200,fontSize: 13.0,
                     fontFamily: 'Rukie',letterSpacing: 0.4,color: Color(0xFF404040)
                    ),
                  ),onTap: (){
                    Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            CommentsWid(
                                                                              uid: snapshot.data.documents[index]['doc_id'],
                                                                            )));
                  },): SizedBox.shrink(),
                 snapshot.data.documents[index]['count'] >= 1 ? Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   mainAxisAlignment: MainAxisAlignment.start,
                   children: <Widget>[
                     SizedBox(height: 4.4,),
Row(children: <Widget>[
  
Container(
                                        
                                        margin: EdgeInsets.only(right: 5.0),      width: 21,
                                              height: 21,
                                              decoration: new BoxDecoration(
                                                color: Colors.white,
                                                image: new DecorationImage(
                                                  image: CachedNetworkImageProvider(
                                                      '${snapshot.data.documents[index]['photoUrl']}'),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius: new BorderRadius
                                                        .all(
                                                    new Radius.circular(50.0)),
                                                border: new Border.all(
                                                  color: Colors.white,
                                                  width: 0.0,
                                                ),
                                              ),
                                            ),
Text('${snapshot.data.documents[index]['commenter_name']}',style: TextStyle(fontSize: 12.0,fontWeight: FontWeight.bold),)
],),
                   Container(
                   margin: EdgeInsets.only(top: 3.0,bottom: 3.0),
                   height: 23.0,child: FlatButton(
                   
                   shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                   color: Colors.grey[100],child: Text(
                    "${stringChopper(snapshot.data.documents[index]['comment_sample'])}",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.w300,fontSize: 14.2,
                     fontFamily: 'Rukie',letterSpacing:0.4, color: Colors.black54
                    ),
                  ),onPressed: (){
                      Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            CommentsWid(
                                                                              uid: snapshot.data.documents[index]['doc_id'],
                                                                            )));
                  },),padding: EdgeInsets.only(left: 0),)
                 ],): SizedBox.shrink()
                  ],),
                                         ),
              snapshot.data.documents[index]['count'] >= 1 ?  SizedBox(height: 6.5,): SizedBox.shrink(),
                                      ],
                                    )
                                  ]));
                }
                );
                }
              }),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
               _settingModalBottomSheet(context);
            },
            child: Icon(
              Icons.cloud_upload,
              color: Colors.blue[600]
            ),
            backgroundColor: Colors.white,focusElevation: 4.0,
          ),),),onWillPop: (){
            Navigator.popAndPushNamed(context, '/home'); // riskingi
            return Future.value(false);
          },);
  }
}
