import 'dart:async';
import 'dart:io';
import './terms_and_conditions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import './home.dart';
import './placeholder.dart';
import './requests.dart';
import './userprofile.dart';
import './success.dart';
import './error.dart';
import './welcome.dart';
import './help.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import './terms_and_conditions.dart';
import './rating.dart';
// import './viewList.dart';
import './app_services/localizer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import './auth.dart';
import './styles_beauty.dart';
import './videopage.dart';
import './searchedfeature.dart';
import 'package:flutter/services.dart';
import './swiper.dart';
import './changeCountry.dart';
import 'app_services/auth_service.dart';
import 'default_shell.dart';


class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification(
      {@required this.id,
      @required this.title,
      @required this.body,
      @required this.payload});
}


Future<void>main() async {
   // for IOS -> 01d9552f-a5c7-49a1-bf05-6886d9ccc944
   // for Android -> 0a2fc101-4f5a-44c2-97b9-c8eb8f420e08
  WidgetsFlutterBinding.ensureInitialized();
   OneSignal.shared.init(
  "01d9552f-a5c7-49a1-bf05-6886d9ccc944",
  iOSSettings: {
    OSiOSSettings.autoPrompt: false,
    OSiOSSettings.inAppLaunchUrl: true
  }
);

OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
  runApp(MyApp());
}




 Widget getErrorWidget(BuildContext context, FlutterErrorDetails error) {
   return Scaffold(body:  Container(margin: EdgeInsets.only(top: 200.0),child: Center(
     child: Column(
       children: <Widget>[
         Padding(child: Column(children: <Widget>[
Text(
          
       "Oops something went wrong,",
       style: Theme.of(context).textTheme.title.copyWith(color: Colors.black, fontFamily: 'Caveat',fontSize: 25.0),textAlign: TextAlign.center,
     ),
     Text(
          
       "try again by tapping OK and reopen the app",
       style: Theme.of(context).textTheme.title.copyWith(color: Colors.black, fontFamily: 'Caveat',fontSize: 25.0),textAlign: TextAlign.center,
     )
         ],),padding: EdgeInsets.all(28.0),),
     RaisedButton(child: Padding(padding: EdgeInsets.only(top:13.5,bottom: 13.5,left:25.5,right: 25.5),child: Text('OK',
     style: TextStyle(color: Colors.white, fontFamily: 'NunitoSans',fontWeight: FontWeight.w700))),onPressed: (){
      //  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewList()));
            SystemNavigator.pop();
     
     },color: Colors.blue[600],shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)))
       ],
     ),
   )),backgroundColor: Colors.white,);
 }


class MyApp extends StatefulWidget {
  MyAppState createState() => MyAppState();
}


class MyAppState extends State<MyApp>  { // with WidgetsBindingObserver
  // AppLifecycleState _lastLifecycleState;

//   final bool x = true;
//   String uid;
//   StreamSubscription<ConnectivityResult> subscription;
//   allowPhone() async{
//   await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);  
//   // await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
//   await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
//   await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
//   }
  
// setRateCount() async{
// SharedPreferences prefs =  await SharedPreferences.getInstance();
// Firestore.instance.collection('users').document(prefs.getString('uid'))
// .setData({
//   'ratingCount' : 1
// }, merge: true).then((onValue){
//   print('Rating done');
// });
//   }

//   setStatusOff(String status) async {
//   SharedPreferences prefs =  await SharedPreferences.getInstance();
  
//   await Firestore.instance.collection('users').document(prefs.getString('uid'))
// .setData({
//   'current_status' : status
// }, merge: true);
//   }

//   setTvCount() async {
//     SharedPreferences prefs =  await SharedPreferences.getInstance();
// Firestore.instance.collection('users').document(prefs.getString('uid'))
// .setData({
//   'tvCount' : FieldValue.increment(1)
// }, merge: true).then((onValue){
//   print('Styles done');
// });
//   }

// checkUserStatus() async {
//   DateTime now = DateTime.now();
//   SharedPreferences prefs =  await SharedPreferences.getInstance();
//    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
//      if(result.toString() == 'ConnectivityResult.none'){
//        setStatusOff('at ${now.hour}:${now.minute}');
//      }else if(result.toString() == 'ConnectivityResult.mobile'){
//        setStatusOff('Online');
//      }else if(result.toString() == 'ConnectivityResult.wifi'){
//        setStatusOff('Online');
//      }
//    });
// }
// @override
//   initState(){
    
//     // WidgetsBinding.instance.addObserver(this);

//     allowPhone();
    



// OneSignal.shared.setNotificationReceivedHandler((OSNotification result) {
//   if(result.payload.rawPayload['title'].toString().contains('Rate')){
//   // linkerService.linkerListener.add({'type':'rating', 'count': 1});
//   setRateCount();
//   } else if(result.payload.rawPayload['title'].toString().contains('shared a new style')){
//   // linkerService.linkerListener.add({'type':'tv', 'count': 1});
//    setTvCount();
//   }else if(result.payload.additionalData['type'] == 'new-videos'){
//   setTvCount();
//   }

// });
// checkUserStatus();
// // lastSeen();
// super.initState();
//   }
  
// @override
// dispose(){
//   subscription.cancel();
//   //  WidgetsBinding.instance.removeObserver(this);
//   super.dispose();

// }
  
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Color(0xFF2C1CEA),
    scaffoldBackgroundColor: Colors.white,// Color.fromRGBO(240, 240, 240, 1.0)
    fontFamily: 'NunitoSans'
),
builder: (BuildContext context, Widget widget) {
         ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
           return getErrorWidget(context, errorDetails);
         };

         return widget;
       },
      localizationsDelegates: [
        const DemoLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // English
        const Locale('zh'), // Chinese,
        const Locale('ar'),
        const Locale('sw'),
        const Locale('pt'),
        const Locale('af')
      ],
      title: 'Rexa',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (BuildContext context) => ViewSwitcher(),
        '/home': (BuildContext context) => Swiper(),
        '/requests': (BuildContext context) => RequestsWid(),
        '/history': (BuildContext context) => PlaceholderWid(),
        '/profile': (BuildContext context) => UserProfile(),
        '/success': (BuildContext context) => SuccessWidget(),
        '/failed':   (BuildContext context) => FailedWidget(),
        '/welcome': (BuildContext context) => Welcome(),
        '/help': (BuildContext context) => HelpWid(),
        '/rate': (BuildContext context) => RatingWidget(),
        '/categories': (BuildContext context) => Home(),
        '/auth':(BuildContext context) => SignIn(),
        '/styles-beauty': (BuildContext context) => StylesBeautyWidget(),
        '/rating': (BuildContext context) => RatingWidget(),
        '/tv': (BuildContext context) => VideoPageWidget(),
        '/search': (BuildContext context) => SearchWid(),
        '/change-country': (BuildContext context) => OfferChanger(),
        '/terms': (BuildContext context) => TermsWid()
      }
    );
  }
}







class ViewSwitcher extends StatefulWidget{

  @override
  ViewSwitcherState createState() => ViewSwitcherState();

}


class ViewSwitcherState extends State<ViewSwitcher>{
  bool isNew;
  bool isNewUser;
  void checkIfDeviceRegistered() async {
    SharedPreferences prefs =  await SharedPreferences.getInstance();
    setState(() {
    isNew = prefs.getBool('isSignedIn');
    isNewUser = prefs.getBool('isNewUser');
    });
  }

 @override
  void initState(){
   
    checkIfDeviceRegistered();
    super.initState();
  }

@override
void dispose() {
 super.dispose();
}

  @override
  Widget build(BuildContext context){
    return StreamBuilder(stream: authService.user,builder: (context,snapshot){
      switch(snapshot.connectionState){
        case ConnectionState.waiting:
        return DefaultPlaceholder();
        break;
        default:
        if (snapshot.hasData && isNew == true) {
        return  Swiper();
       }else if(snapshot.hasData && isNewUser == true){
        return  SignIn();
       }else {
        return SignIn();
       }
      }
    },);
  }
}
