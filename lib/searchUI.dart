import 'package:flutter/material.dart';

class SearchUI extends StatefulWidget {
  @override
  _SearchUIState createState() => _SearchUIState();
}

class _SearchUIState extends State<SearchUI> {
  List<dynamic> map = new List();
  final PageController ctrl = PageController(viewportFraction: 0.8);
  int currentPage = 0;

  @override
  void initState() {
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
    return Scaffold(
      body: PageView.builder(
        controller: ctrl,
        itemCount: map.length + 1,
        itemBuilder: (context, int currentIdx) {
          if (currentIdx == 0) {
            return _buildSearchTab();
          } else if (map.length >= currentIdx) {
            // Active page
            bool active = currentIdx == currentPage;
           // return _buildStoryPage(map[currentIdx - 1], active);
          }
        })
    );
  }

 _buildStoryPage(Map data, bool active) {
    // Animated Properties
    final double blur = active ? 30 : 0;
    final double offset = active ? 20 : 0;
    final double top = active ? 100 : 200;

    return GestureDetector(
        onTap: (){},
        child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOutQuint,
        margin: EdgeInsets.only(top: top, bottom: 50, right: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(data['image']),
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
            padding: const EdgeInsets.only(left : 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Center(
                  child: Text(data['title'],
                      style: TextStyle(fontSize: 40, color: Colors.white))),
              SizedBox(
                height: 5,
              ),
              Text(data['desc'],
                  style: TextStyle(fontSize: 14, color: Colors.white))
            ]),
          ),
        ),
      ),
    );
  }

_queryDb() {
     List<dynamic> map = new List();
    
     if(currentPage == 0){
        map = new List();
      map.add({
        'title': "Recherche",
        'image':
            "http://codinghelptech.com/blog_post/internet-http-error-404-file-not-found.jpg",
        'desc': "Recherche non trouvé!!",
        'likes': 10
      });
     }

   
    setState(() {  
      map = map;
    });
  }

  _buildSearchTab() {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tours Tools',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text(
          'Recherche',
          style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
        ),
        Text('FILTER', style: TextStyle(color: Colors.black26)),
        new Form(
          child: Theme(
            data: new ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.red,
              inputDecorationTheme: new InputDecorationTheme(
                labelStyle: new TextStyle(
                  color: Colors.red,
                  fontSize: 20.0,
                ),
              ),
            ),
            child: new TextFormField(
              decoration: new InputDecoration(
                  hintText: "Rechercher",
                  suffix: Icon(
                    Icons.search,
                    color: Colors.black45,
                  ),
                  fillColor: Colors.black12,
                  ),
              style: TextStyle(color: Colors.black45),    
              keyboardType: TextInputType.text,
            ),
          ),
        )
      ],
    ));
  }
}
