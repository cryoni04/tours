import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:location/location.dart' as loc;
import 'package:tours/utils/gps_util.dart';
import 'package:tours/map_screen.dart';
import 'package:tours/model/route.dart';
import 'package:tours/network/networ_util.dart';
import 'dart:async';

class MapUtil implements GpsUtilListener {
  var staticMapProvider;
    Completer<GoogleMapController> _controller = Completer();
  CameraPosition cameraPosition;
  loc.Location location;
  var zoomLevel = 18.0;
  GoogleMap mapView;
  Map<String, double> _currentLocation = Map();
  NetworkUtil network = new NetworkUtil();
  GpgUtils gpgUtils;
  ScreenListener _screenListener;
  List<Map<String, double>> ccc;

  MapUtil(this._screenListener);

  init() {
    gpgUtils = new GpgUtils(this);
    gpgUtils.init();
  }

  getDirectionSteps(double destinationLat, double destinationLng) {
    network
        .get("origin=" +
            _currentLocation["latitude"].toString() +
            "," +
             _currentLocation["longitude"].toString() +
            "&destination=" +
            destinationLat.toString() +
            "," +
            destinationLng.toString() +
            "&key=google_map_key")
        .then((dynamic res) {
      List<Steps> rr = res;
      print(res.toString());

      ccc = new List();
      for (final i in rr) {
        ccc.add(i.startLocation);
        ccc.add(i.endLocation);
      }

      // mapView.onMapReady.listen((_) {
      //   mapView.setMarkers(getMarker(_currentLocation["latitude"],_currentLocation["longitude"],destinationLat,destinationLng));
      //   mapView(new Polyline("12", ccc, width: 15.0));
      // });
      
      _screenListener.dismissLoader();
      showMap();
    }).catchError((Exception error) => _screenListener.dismissLoader());
  }


 Future<void> _getLocation(LatLng latLng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 15, tilt: 50.0, bearing: 45.0)));
  }

  CameraPosition getCamera() {
    cameraPosition = new CameraPosition(target: LatLng(
                    _currentLocation['latitude'], _currentLocation['longitude']),
            zoom: 17);
    return cameraPosition;
  }

  showMap() {
    return GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: getCamera(),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: {getMaker("id", _currentLocation)},
      );
    // mapView.show(
    //     new MapOptions(
    //         mapViewType: MapViewType.normal,
    //         initialCameraPosition: getCamera(),
    //         showUserLocation: true,
    //         title: "Draw route"),
    //     toolbarActions: [new ToolbarAction("Close", 1)]);
    // mapView.onToolbarAction.listen((id) {
    //   if (id == 1) {
    //     mapView.dismiss();
    //   }
    // });
  }
  // Marker makers = Marker(
  //     markerId: MarkerId('id'),
  //     position: LatLng(
  //                   _currentLocation['latitude'], _currentLocation['longitude']),
  //     infoWindow: InfoWindow(title: 'Ihusi'),
  //     icon: BitmapDescriptor.defaultMarkerWithHue(
  //       BitmapDescriptor.hueViolet,
  //     ));
  Marker getMaker(String id, Map<String, dynamic> _current){
    return Marker(
      markerId: MarkerId(id),
      position: LatLng(
                    _current['latitude'], _current['longitude']),
      infoWindow: InfoWindow(title: 'Ihusi'),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueViolet,
      ));
  }
  // updateLocation(Location location) {
  //   this.location = location;
  // }

  updateZoomLevel(double zoomLevel) {
    this.zoomLevel = zoomLevel;
  }

  @override
  onLocationChange(Map<String, double> currentLocation) {
    _currentLocation["latitude"] = currentLocation["latitude"];
    _currentLocation["longitude"] = currentLocation["longitude"];
    _screenListener.updateScreen(currentLocation);
  }

  cameraUpdate(CameraPosition cameraPosition) {
    print("campera position changed $cameraPosition");
  }

  // void manageMapProperties() {
  //   mapView.zoomToFit(padding: 100);

  //   mapView.onLocationUpdated.listen((location) => updateLocation(location));

  //   mapView.onTouchAnnotation.listen((marker) => print("marker tapped"));

  //   mapView.onMapTapped.listen((location) => updateLocation(location));

  //   mapView.onCameraChanged
  //       .listen((cameraPosition) => cameraUpdate(cameraPosition));
  // }
}
