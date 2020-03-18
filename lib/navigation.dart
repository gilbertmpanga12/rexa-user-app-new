import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import './app_services/localizer.dart';
import 'package:location/location.dart';
class NavigationMaps extends StatefulWidget{
  final double longitude;
  final double latitude;
  final String serviceProviderName;
  final String phoneNumber;
  @override
  NavigationMapsState createState() => NavigationMapsState();
  NavigationMaps({this.latitude, this.longitude,this.serviceProviderName,this.phoneNumber});
}

class NavigationMapsState extends State<NavigationMaps>{
   double _longitude;
   double _latitude;
   String _name;
   String phoneNumber;
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  double latitude;
  double longitude;
  var location = new Location();
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }
  initState(){
   _longitude = widget.longitude ;
   _latitude = widget.latitude;
   _name = widget.serviceProviderName;
   phoneNumber = widget.phoneNumber;
    _addMarker();
    super.initState();
  }

Future<LocationData> getLocation() async {
    var currentLocation;
     currentLocation  = await location.getLocation();
     latitude = currentLocation.latitude;
     longitude = currentLocation.longitude;
    return currentLocation;
  }

  Widget build(BuildContext context){

   return Scaffold(
     appBar: AppBar(
       elevation: 1.3,
       title: Text(DemoLocalizations.of(context).Location,
       style: TextStyle(color: Colors.black,fontFamily: 'NunitoSans',fontWeight: FontWeight.w900),),
       backgroundColor: Colors.white,iconTheme: IconThemeData(color: Colors.black),
       centerTitle: true,
     ),
     body: FutureBuilder(builder: (BuildContext context, snapshot){
       
       if(snapshot.hasError) return Center(child: Text('Check your internet connection'),);
       switch(snapshot.connectionState){
         case ConnectionState.waiting: 
           return Center(child: CircularProgressIndicator(),);
           break;
        default:
           return latitude != null && longitude != null ? GoogleMap(
       markers: Set<Marker>.of(markers.values),
       onMapCreated: _onMapCreated,
       initialCameraPosition: CameraPosition(
         target: LatLng(latitude, longitude),
         zoom: 15.0,
       ),
compassEnabled: true,
       zoomGesturesEnabled: true,scrollGesturesEnabled: true,
       myLocationEnabled: true,tiltGesturesEnabled: true,
     ): SizedBox.shrink();
     break;
       }
     },future: getLocation(),),
   );
  }

  Future<void> _addMarker() async {

  //final GoogleMapController controller = await _controller.future;
  final MarkerId markerId = MarkerId('test_marker');
  final Marker marker = Marker(
  markerId: markerId,
  anchor: Offset(0.5, 0.5),
  position: LatLng(
  _latitude, _longitude
  ),
  infoWindow: InfoWindow(title: 'Service Provider',onTap: (){
    print('tapped');
  },snippet: '    ${_name}'),
  zIndex: 5,
  );

  setState(() {
  markers[markerId] = marker;
  });
  }
}