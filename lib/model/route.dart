

class Steps {


  Map<String, double> startLocation = new Map();
  Map<String, double> endLocation = new Map();

  Steps({this.startLocation, this.endLocation});

  factory Steps.fromJson(Map<String, dynamic> json) {
    Map<String, double> start = new Map();
    start['latitude'] = json["start_location"]["lat"];
    start['longitude'] = json["start_location"]["lng"];

    Map<String, double> last = new Map();
    last['latitude'] = json["end_location"]["lat"];
    last['longitude'] = json["end_location"]["lng"];
    return new Steps(

        startLocation: start,
        endLocation: last);
  }
}
