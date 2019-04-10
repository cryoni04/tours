import 'package:flutter/material.dart';
import 'package:tours/map_screen.dart';
import 'package:tours/maps.dart';
import 'package:tours/myNavigator.dart';
import 'package:tours/searchUI.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var routes = <String, WidgetBuilder>{
  "/search": (BuildContext context) => SearchUI()
};
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: MyPage()),
      // home: new AppBarBottomSample(),
      // home: new MapScreen(),
      debugShowCheckedModeBanner: false,
      routes: routes,
    );
  }
}

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final PageController ctrl = PageController(viewportFraction: 0.8);
  Stream slides;
  String activeTag = 'Bar';
  List<dynamic> map = new List();
  List<String> categories = new List();
  Firestore db = Firestore.instance;
  // Keep track of current page to avoid unnecessary renders
  int currentPage = 0;
  Stream _stream;

  @override
  void initState() {
    getCategories();
    _queryDb();
    // Set state when page changes
    ctrl.addListener(() {
      int next = ctrl.page.round();

      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: slides,
        initialData: [],
        builder: (context, AsyncSnapshot snap) {
          List slideList = snap.data.toList();
          return PageView.builder(
              controller: ctrl,
              itemCount: slideList.length + 1,
              itemBuilder: (context, int currentIdx) {
                if (currentIdx == 0) {
                  return _buildTagPage();
                } else if (slideList.length >= currentIdx) {
                  // Active page
                  bool active = currentIdx == currentPage;
                  return _buildStoryPage(slideList[currentIdx - 1], active);
                }
              });
        });
  }

  _queryDb({String tag = 'Hotel'}) async {
    // List<dynamic> map = new List();
    // Make a Query
    print("$tag");
    await db
        .collection('categories')
        .where('name', isEqualTo: tag)
        .getDocuments()
        .then((QuerySnapshot docs) {
      if (docs.documents.isNotEmpty) {
        print("something as found");
        String id = docs.documents[0].documentID;
        Query query = db.collection('places').where('categorie', isEqualTo: id);

        // Map the documents to the data payload
        slides = query
            .snapshots()
            .map((list) => list.documents.map((doc) => doc.data));
      }
    });

    // Update the active tag
    setState(() {
      activeTag = tag;
    });
  }

  getCategories() async {
    categories = new List();
    await db.collection('categories').getDocuments().then((QuerySnapshot docs) {
      if (docs.documents.isNotEmpty) {
        for (var i = 0; i < docs.documents.length; i++) {
          categories.add(docs.documents[i].data['name']);
        // print(docs.documents[i].data['name']);
        }
      }print("categories as found");
    });

    // Update the active tag
    setState(() {
      categories = categories;
    });
  }

  _buildStoryPage(Map data, bool active) {
    // Animated Properties
    final double blur = active ? 30 : 0;
    final double offset = active ? 20 : 0;
    final double top = active ? 100 : 200;

    return GestureDetector(
      onLongPress: () {
        _buildDialog(context, data);
      },
      onTap: () {
        print("Location ${data['geo']}");
        GeoPoint geo =data['geo'];
        print("selected lat ${geo.latitude} and long ${geo.longitude}");
          Map<String, double> destination = Map();
          destination['latitude'] = geo.latitude;
          destination['longitude'] = geo.longitude;
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new Maps(
                      nom: data['titre'],
                      img: data['images'],
                      destination: destination,
                      desc: data['description'],
                    )));
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOutQuint,
        margin: EdgeInsets.only(top: top, bottom: 50, right: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(data['images']),
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black87,
                  blurRadius: blur,
                  offset: Offset(offset, offset))
            ]),
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                      child: Text(data['titre'],
                          style: TextStyle(fontSize: 40, color: Colors.white))),
                  SizedBox(
                    height: 5,
                  ),
                  Text(data['description'],
                      style: TextStyle(fontSize: 14, color: Colors.white))
                ]),
          ),
        ),
      ),
    );
  }

  _buildTagPage() {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tours\nTools',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text('MENU', style: TextStyle(color: Colors.black26)),
        categories.length == 0
            ? _buildButton('wait')
            : Column(
              children: _getButton(),
            )
      ],
    ));
  }

  List<Widget> _getButton(){
    return new List<Widget>.generate(categories.length, (int index){
      return   _buildButton(categories[index].toString());
    });
  }

  _buildButton(tag) {
    Color color = tag == activeTag ? Colors.purple : Colors.white;
    return SizedBox(
      width: 150.0,
      child: FlatButton(
        color: Colors.blueAccent,
        child: Text('$tag'),
        onPressed: () => _queryDb(tag: tag)),
    );
  }

  _buildButtonSearch(tag) {
    Color color = tag == activeTag ? Colors.purple : Colors.white;
    return FlatButton(
        color: color,
        child: Text('$tag'),
        onPressed: () {
          MyNavigator.gotTo(context, '/search');
        });
  }

  _buildDialog(BuildContext context, Map data) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(contentPadding: EdgeInsets.zero, children: [
            Image.network(
              data['images'],
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(data['titre'],
                      style: TextStyle(fontSize: 20, color: Colors.black54)),
                  new Text(data['description'])
                ],
              ),
            )
          ]);
        });
  }
}
