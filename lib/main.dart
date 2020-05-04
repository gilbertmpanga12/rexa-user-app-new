import 'dart:async';
import 'dart:io';
import 'package:rexa/video_stories.dart';

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
import 'globals/config.dart';


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
   // for IOS -> 043cf2de-40cc-4010-b431-4e02a950f75f  - Business
   // for Android -> 01d9552f-a5c7-49a1-bf05-6886d9ccc944 -> User
   // for New Android  -> 306a55a3-92f5-4aac-9cb5-21fff19320e5
  WidgetsFlutterBinding.ensureInitialized();
   OneSignal.shared.init(
  Configs.appIdnewAdroidWorker,
  iOSSettings: {
    OSiOSSettings.autoPrompt: true,
    OSiOSSettings.inAppLaunchUrl: true
  }
);

OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
// OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
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
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
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
        '/': (BuildContext context) => VideoStories(),
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
