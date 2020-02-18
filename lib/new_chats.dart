import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import './mainTabChat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './chat_view.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InstaStories extends StatefulWidget {
  InstaStoriesState createState() => InstaStoriesState();
}

class InstaStoriesState extends State<InstaStories> {
  String profilePicture;
  String mainUid;
  String defaultPicture =
      'https://firebasestorage.googleapis.com/v0/b/esalonbusiness-d3f3d.appspot.com/o/avatar.png?alt=media&token=53503121-c01f-4450-a5cc-cf25e76f0697';
String _phoneNumber;
var counter = new Set();

 tapNotification(String senderName, int index) async{
   counter.remove(index);
  
}





// IOS CONFIG
  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context){
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
      }

    );
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => MainTabChat()),
    );
}



  localStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('phoneNumber'));
    
    setState(() {
      profilePicture = prefs.getString('profilePicture');
      mainUid = prefs.getString('uid');
      _phoneNumber = prefs.getString('phoneNumber');
    });

  }


  @override
  void initState() {
    localStorage();
    super.initState();
  }

@override
dispose(){
  // to be returned
  super.dispose();
}




  Widget topText(){
    return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Padding(child: Icon(FontAwesomeIcons.comments,size: 19.0,),padding: EdgeInsets.only(left: 12.0,top:1.0),)
    ],
  );

  }
  Widget noChatYet() {
     print('i am apperaring >>***8');
    return new Stack(
      alignment: Alignment.bottomLeft,
      children: <Widget>[
        StreamBuilder(stream: Firestore.instance.collection('users').document('$mainUid').snapshots(),
                    builder: (context,snapshot){
                      if(!snapshot.hasData){
                        return CircularProgressIndicator();
                      }
                      return InkWell(
                              child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Container(
                                    width: 57.0,
                                    height: 57.0,
                                    decoration: new BoxDecoration(
                                      border: new Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                        style: BorderStyle.solid,
                                      ),
                                      // gradient: SweepGradient,
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                          fit: BoxFit.cover,
                                          image: CachedNetworkImageProvider(
                                              '${snapshot.data['profilePicture'] ?? defaultPicture}')),
                                    ),
                                  ),
                                  width: 57.0,
                                  height: 57.0,
                                  decoration: new BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      Color(0xFF833AB4), // Purple
                                      Color(0xFFF77737), // Orange
                                      Color(0xFFE1306C), // Red-pink
                                      Color(0xFFC13584), // Red-purple
                                    ]),
                                    border: new Border.all(
                                      // color: Colors.black,
                                      width: 1.5,
                                      style: BorderStyle.solid,
                                    ),
                                    shape: BoxShape.circle,
                                  )),
                              onTap: () {
                                print('bug **');
                                print(profilePicture);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MainTabChat()));
                              },
                            );
                    },),
        Positioned(
            left: 10.0,
            child: new CircleAvatar(
              backgroundColor: Colors.blueAccent,
              radius: 10.0,
              child: new Icon(
                Icons.add,
                size: 14.0,
                color: Colors.white,
              ),
            ))
      ],
    );
  }

  Widget stories(context) {
    return Expanded(
      child: new Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: StreamBuilder(
          builder: (context, snapshot) {
            try{
              if (!snapshot.hasData) {
               print('Noooo');
              return Center(
                child: new DotsIndicator(
  dotsCount: 5,
  position: 1,
  decorator: DotsDecorator(
    size: const Size.square(9.0),
    activeSize: const Size(18.0, 9.0),
    activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
  ),
),
              );
            }

            if (snapshot.data.documents.length == 0){
            
              return noChatYet();
            }
            
            return new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Stack(children: <Widget>[
                    StreamBuilder(stream: Firestore.instance.collection('users').document('$mainUid').snapshots(),
                    builder: (context,snapshot){
                      if(!snapshot.hasData){
                        return CircularProgressIndicator();
                      }
                      return InkWell(
                              child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Container(
                                    width: 57.0,
                                    height: 57.0,
                                    decoration: new BoxDecoration(
                                      border: new Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                        style: BorderStyle.solid,
                                      ),
                                      // gradient: SweepGradient,
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                          fit: BoxFit.cover,
                                          image: CachedNetworkImageProvider(
                                              '${snapshot.data['profilePicture'] ?? defaultPicture}')),
                                    ),
                                  ),
                                  width: 57.0,
                                  height: 57.0,
                                  decoration: new BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      Color(0xFF833AB4), // Purple
                                      Color(0xFFF77737), // Orange
                                      Color(0xFFE1306C), // Red-pink
                                      Color(0xFFC13584), // Red-purple
                                    ]),
                                    border: new Border.all(
                                      // color: Colors.black,
                                      width: 1.5,
                                      style: BorderStyle.solid,
                                    ),
                                    shape: BoxShape.circle,
                                  )),
                              onTap: () {
                                print('bug **');
                                print(profilePicture);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MainTabChat()));
                              },
                            );
                    },),
                            Positioned(
                              right: 10.0,
                              child: new CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                radius: 10.0,
                                child: new Icon(
                                  Icons.add,
                                  size: 14.0,
                                  color: Colors.white,
                                ),
                              )),
                  ],alignment: Alignment.bottomRight,),
                  Expanded(child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.documents.length, //5
              itemBuilder: (context, index) {
                return new Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                  
                   Stack(
                    alignment: Alignment.bottomRight,
                    children: <Widget>[
                      

//                       StreamBuilder(
//                       stream: CloudFunctions.instance.
//      getHttpsCallable(functionName: 'chatNotifier').call({'uid': mainUid}).asStream(), // to be back xox
//                       builder: (context, snapshot) {
//                         print('outside ****');
//                         if(!snapshot.hasData){
//                           print('it has no data');
//                           return SizedBox.shrink();
//                         }
//                         print('the fullname is ${snapshot.data['fullName']}');
//       try{
//         print(snapshot.data);
//          if(snapshot.data['shouldNotify'] == true){
//            print('Here the plotting works');
//          tapNotification('${snapshot.data['fullName']}');
//          }
//       }catch(err){
//         print('Is erroed');
//            return SizedBox.shrink();
//       }

//                         return SizedBox.shrink();

// })
                     
    StreamBuilder(
                                    stream: Firestore.instance.collection('users')
                                    .document('${snapshot.data.documents[index]['phoneNumber']}').snapshots(),
                                    builder: (context, snapshoty){
                                    if(!snapshoty.hasData){
                                      return SizedBox.shrink();
                                    }
                                    return GestureDetector(child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Container(
                                    width: 57.0,
                                    height: 57.0,
                                    decoration: new BoxDecoration(
                                      border: new Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                        style: BorderStyle.solid,
                                      ),
                                      // gradient: SweepGradient,
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                          fit: BoxFit.cover,
                                          image: new CachedNetworkImageProvider(
                                              '${snapshoty.data['profilePicture']}')),
                                    ),
                                  ),
                                  width: 57.0,
                                  height: 57.0,
                                  decoration: new BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      Color(0xFF833AB4), // Purple
                                      Color(0xFFF77737), // Orange
                                      Color(0xFFE1306C), // Red-pink
                                      Color(0xFFC13584), // Red-purple
                                    ]),
                                    border: new Border.all(
                                      // color: Colors.black,
                                      width: 1.5,
                                      style: BorderStyle.solid,
                                    ),
                                    shape: BoxShape.circle,
                                  )),onTap: () async {
 Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Chat(peerAvatar: '${snapshoty.data['profilePicture']}',
                                        peerId: '${snapshot.data.documents[index]['idTo']}',
                                        fullName: '${snapshot.data.documents[index]['fullName']}',
                                        phoneNumber: '${snapshot.data.documents[index]['phoneNumber']}',
                            status:  '${snapshot.data.documents[index]['current_status']}',currentStatus: snapshot.data.documents[index]['current_status'] == 'Online' ? ChatBarState.ACTIVE :ChatBarState.LASTSEEN
                            )));
                     
                       
await Firestore.instance.collection('LatestNotifications')
.document('${snapshot.data.documents[index]['idTo']}')
 .collection('new_nots').document('$_phoneNumber').setData({
   'chatCount': 0,
 },merge: true);
                                  },);
                                  },)   ,           
                  

                      
                      StreamBuilder(builder: (context,snapnots){
                        try{
                          if(!snapnots.hasData){
                          return Container(child: SizedBox.shrink(),);
                        }
                        if(snapnots.data['chatCount'] >= 1) {
                          // if(snapnots.data['chatCount'] != null && counter.contains(snapnots.data['chatCount'])){
                          //   tapNotification('${snapnots.data['fullName']}', snapnots.data['chatCount']);
                          // }

    return Positioned(
                              right: 10.0,
                              child: new CircleAvatar(
                                backgroundColor: Colors.redAccent,
                                radius: 10.0,
                                child: new Text(
                                  '${snapnots.data['chatCount']}',
                                 style: TextStyle( fontSize: 14.0,
                                  color: Colors.white),
                                ),
                              ));
                        }else{
                          return Container(child: Text(''),);
                        }
                        }catch(err){
                          
                          return Container(child: Text(''),);
                        }
                        
                      },stream: Firestore.instance.collection('LatestNotifications')
                      .document('${snapshot.data.documents[index]['idTo']}').collection('new_nots')
                      .document('${_phoneNumber}').snapshots()
                      ,) // HERE TO
//.where('targetTo',isEqualTo: '${snapshot.data.documents[index]['idTo']}')
                   //   .where('targetFrom',isEqualTo: '${_phoneNumber}').snapshots()
// '${snapshot.data.documents[index]['phoneNumber']}'
                      // index == 0 && snapshot.data.documents[index]['chatCount'] != null
                      //     ? Positioned(
                      //         right: 10.0,
                      //         child: new CircleAvatar(
                      //           backgroundColor: Colors.redAccent,
                      //           radius: 10.0,
                      //           child: new Text(
                      //             '${snapshot.data.documents[index]['chatCount']}',
                      //            style: TextStyle( fontSize: 14.0,
                      //             color: Colors.white),
                      //           ),
                      //         ))
                      //     : new Container()

                    ],
                  )
                ],);
              },
            ),)

            ],);
            }catch(err){
              return SizedBox.shrink();
            }
          },
          stream: Firestore.instance.
          collection('users').document('${mainUid}')
          .collection('verified_contacts')
          .where('isChatted',isEqualTo: true).orderBy('date', descending: true).snapshots(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return new Container(
      margin: const EdgeInsets.all(16.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          topText(),
          stories(context),

        ],
      ),
    );
  }
}
