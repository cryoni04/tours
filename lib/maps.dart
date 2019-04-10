import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tours/map_screen.dart';
import 'package:tours/utils/google_place_util.dart';
import 'package:tours/utils/gps_util.dart';
// import 'package:simple_permissions/simple_permissions.dart';

class Maps extends StatefulWidget {
  Maps({this.nom, this.destination, this.img, this.desc});
  @override
  _MapsState createState() => _MapsState();
  final String nom;
  final Map<String, double> destination;
  final String img;
  final String desc;
}

class _MapsState extends State<Maps>
    implements GpsUtilListener, ScreenListener {
  Completer<GoogleMapController> _controller = Completer();
  // StreamSubscription<Map<String, double>> _locationSubscription;
  // Map<String, double> _currentLocation = Map();
  // Location _location = new Location();
  // bool _permission = false;
  // String error;
  Map<String, double> _currentLocation = Map();
  GpgUtils gpgUtils;
  GooglePlaces googlePlaces;
  double zoomval = 15.0;

  bool _isAsk = false;
  String _platformVersion = 'Unknown';
  ScreenListener _screenListener;
  // Permission permission = Permission.AccessFineLocation;

  @override
  void initState() {
    super.initState();
    _screenListener = this;
    gpgUtils = new GpgUtils(this);
    gpgUtils.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nom.toLowerCase()),
      ),
      body: Stack(
        children: <Widget>[initMap(), _zoomIn(), _zoomOut(), _buildBottom()],
      ),
    );
  }

  Widget initMap() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
            target: LatLng(
                _currentLocation['latitude'], _currentLocation['longitude']),
            zoom: 15),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: {getMyMarker(), getMaker()},
      ),
    );
  }

  Future<void> _getLocation(LatLng latLng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 15, tilt: 50.0, bearing: 45.0)));
  }

  Widget _zoomIn() {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: Icon(
          Icons.zoom_in,
          size: 40,
          color: Colors.blueAccent,
        ),
        onPressed: () {
          zoomval++;
          _zoomMap(zoomval);
        },
      ),
    );
  }

  Widget _zoomOut() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: Icon(
          Icons.zoom_out,
          size: 40,
          color: Colors.blueAccent,
        ),
        onPressed: () {
          zoomval--;
          _zoomMap(zoomval);
        },
      ),
    );
  }

  Future<void> _zoomMap(double val) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(
            widget.destination['latitude'], widget.destination['longitude']),
        zoom: zoomval)));
  }

  Widget _buildBottom() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _boxes(
              widget.img,
              LatLng(widget.destination['latitude'],
                  widget.destination['longitude']),
              widget.nom),
        ),
      ),
    );
  }

  Widget _boxes(String url, LatLng lat, String nom) {
    return GestureDetector(
      onTap: () {
        _getLocation(lat);
      },
      child: Container(
        child: new FittedBox(
          child: Material(
            color: Colors.white,
            elevation: 14.0,
            borderRadius: BorderRadius.circular(24.0),
            shadowColor: Color(0x802196F3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 180,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: new BorderRadius.circular(24.0),
                    child: Image(
                      fit: BoxFit.fill,
                      image: NetworkImage(url),
                    ),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(children :<Widget>[
                      Center(child: Text(widget.nom)),
                      Center(child: Text(widget.desc)),
                    ], ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Marker getMaker() {
    return Marker(
        markerId: MarkerId('id'),
        position: LatLng(
            widget.destination['latitude'], widget.destination['longitude']),
        infoWindow: InfoWindow(title: widget.nom,),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ));
  }

  Marker getMyMarker() {
    return Marker(
        markerId: MarkerId('Ma Position'),
        position:
            LatLng(_currentLocation['latitude'], _currentLocation['longitude']),
        infoWindow: InfoWindow(title: 'Ma Position'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ));
  }

  @override
  onLocationChange(Map<String, double> location) {
    _currentLocation["latitude"] = location["latitude"];
    _currentLocation["longitude"] = location["longitude"];
    _screenListener.updateScreen(location);
    setState(() {});
  }

  @override
  dismissLoader() {
    // TODO: implement dismissLoader
    return null;
  }

  @override
  updateScreen(Map<String, double> currentLocation) {
    _currentLocation = currentLocation;
    // googlePlaces.updateLocation(
    //     _currentLocation['latitude'], _currentLocation['longitude']);
    setState(() {});
  }
}
