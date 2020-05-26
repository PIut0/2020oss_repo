import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

enum city { seoul, busan , daegu , ansan }

const cityList = {
  "city.seoul":"서울",
  "city.busan":"부산",
  "city.daegu":"대구",
  "city.ansan":"안산",
};

class Weather {
  final int day;
  final String date;
  final String state;
  final int high_temp;
  final int row_temp;

  const Weather({
    this.day,
    this.date,
    this.state,
    this.high_temp,
    this.row_temp
  });
}

class WeatherAPI{
  final List list;
  WeatherAPI({this.list});

  factory WeatherAPI.fromJson(Map<String, dynamic> json) {
    return WeatherAPI(
      list: json['list']
    );
  }
}

Future<WeatherAPI> fetchWeather() async {
  final url = 'http://api.openweathermap.org/data/2.5/forecast/daily?id=1835847&mode=json&units=metric&cnt=7&appid=5fd2f2cde90c1533efb95b19c048a528';
  final response = await http.get(url);
  
  if (response.statusCode == 200) {
    // 만약 서버로의 요청이 성공하면, JSON을 파싱합니다.
    return WeatherAPI.fromJson(json.decode(response.body));
  } else {
    // 만약 요청이 실패하면, 에러를 던집니다.
    throw Exception('Failed to load post');
  }
}


const imgSet = {
  "Clear":"./src/img/sun.png", //맑음
  "fewClouds":"./src/img/sky.png", //구름조금
  "Clouds":"./src/img/cloud.png", //흐림
  "Rain":"./src/img/hail.png", //비
  "Drizzle":"./src/img/hail.png", //비
  "Thunderstorm":"./src/img/storm.png", //태풍
  "Snow":"./src/img/snow.png", //눈
  "Atmosphere":"./src/img/rain.png" //안개
};
const stateSet = {
  "Clear":"맑음", //맑음
  "fewClouds":"구름조금", //구름조금
  "Clouds":"흐림", //흐림
  "Rain":"비", //비
  "Drizzle":"비", //비
  "Thunderstorm":"태풍", //태풍
  "Snow":"눈", //눈
  "Atmosphere":"안개" //안개
};
const daySet = ["월","화","수","목","금","토","일"];
const citySet = {
  "city.seoul":"1835848",
  "city.busan":"1838524",
  "city.daegu":"1835327",
  "city.ansan":"1846918",
};

final baseTextStyle = const TextStyle(
  fontFamily: 'NanumSquareRound'
);
final headerTextStyle = baseTextStyle.copyWith(
  color: Colors.white,
  fontSize: 22.0,
  fontWeight: FontWeight.w800
);
final subHeaderText = regularTextStyle.copyWith(
  fontSize: 18.0
);
final regularTextStyle = baseTextStyle.copyWith(
  color: Colors.white,
  fontSize: 14.0,
  fontWeight: FontWeight.w400
);

Future<List> fetchAPI(city) async{
  final url = 'http://api.openweathermap.org/data/2.5/forecast/daily?id='+city+'&mode=json&units=metric&cnt=7&appid=5fd2f2cde90c1533efb95b19c048a528';
  final response = await http.get(url);
  if(response.statusCode == 200){
    final jsonBody = json.decode(response.body);
    List<List<String>> result = [[],[],[],[],[],[],[]];
    for (var i = 0; i < 7; i++) {
      String day = jsonBody['list'][i]['temp']['day'].toString();
      String night = jsonBody['list'][i]['temp']['night'].toString();
      String state = jsonBody['list'][i]['weather'][0]['main'];
      result[i].add(day);
      result[i].add(night);
      result[i].add(state);
    }
    // return jsonBody['list'][0]['temp']['day'].toString();
    // print(result);
    return result;
    // return "TEST";
  }else{
    throw Exception('fail to load api');
  }
}

Future<List<Weather>> initWeather(city) async{
  List apiList = await fetchAPI(city);
  var now = DateTime.now();

  List<Weather> result = List<Weather>();

  for (var i = 0; i < 7; i++) {
    Weather w = Weather(
        day: now.weekday,
        date: now.month.toString() + " / " + now.day.toString(),
        state: apiList[i][2],
        high_temp: double.parse(apiList[i][0]).round(),
        row_temp: double.parse(apiList[i][1]).round()
    );
    result.add(w);
    now = now.add(Duration(days: 1));

  }
  print("initWeather");
  return result;
  // print(apiList);
}



class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Future<WeatherAPI> api;
  Future<List<Weather>> weathers;

  void initState(){
    print("!");
    api = fetchWeather();
    weathers = initWeather(citySet[_city.toString()]);
  }
  
  static city _city = city.seoul;

  var appBarTitleText = new Text(cityList[_city.toString()],style: headerTextStyle);

  Future<Null> refreshList() async{
    await Future.delayed(Duration(seconds: 1));
    print("ref");
    // _city = city.busan;
    setState(() {
      weathers = initWeather(citySet[_city.toString()]);
      weathers = weathers;
    });
    return null;
  }
  static var now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBarTitleText,
      ),
      backgroundColor: Color.fromRGBO(22,77,135, 1),

      body: RefreshIndicator(
        // child: WeatherRow(w),
        child: FutureBuilder<List<Weather>>(
          future: weathers,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: 7,
                itemBuilder: (context, i)=>WeatherRow(snapshot.data[i]));
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
            return Center(child:CircularProgressIndicator());
          },
        ),
        onRefresh: refreshList,
        // onRefresh: (){},
      ),

      // body: Center(
      //   // child: WeatherRow(w),
      //   child: FutureBuilder<List<Weather>>(
      //     future: weathers,
      //     builder: (context, snapshot) {
      //         if (snapshot.hasData) {
      //           return ListView.builder(
      //             itemCount: 7,
      //             itemBuilder: (context, i){
      //               // print(snapshot.data[i].state);
      //               return WeatherRow(snapshot.data[i]);
      //             });
      //         } else if (snapshot.hasError) {
      //           return Text("${snapshot.error}");
      //         }
      //       return Center(child:CircularProgressIndicator());
      //     },
      //   ),
      // ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showDialog(context);
        },
        // onPressed: refreshList,
        tooltip: 'city',
        child: Icon(Icons.location_city),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _showDialog(BuildContext context) { 
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Radio(
                        value: city.seoul,
                        groupValue: _city,
                        onChanged: (city value){
                          setState(() => {
                            _city = value
                          });
                        },
                      ),
                      Text("서울")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Radio(
                        value: city.busan,
                        groupValue: _city,
                        onChanged: (city value){
                          setState(() => {
                            _city = value
                          });
                        },
                      ),
                      Text("부산")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Radio(
                        value: city.daegu,
                        groupValue: _city,
                        onChanged: (city value){
                          setState(() => {
                            _city = value
                          });
                        },
                      ),
                      Text("대구")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Radio(
                        value: city.ansan,
                        groupValue: _city,
                        onChanged: (city value){
                          setState(() => {
                            _city = value
                          });
                        },
                      ),
                      Text("안산")
                    ],
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[ 
            new FlatButton(
              child: new Text("선택"),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  appBarTitleText = Text(cityList[_city.toString()],style: headerTextStyle);
                  weathers = initWeather(citySet[_city.toString()]);
                });
              },
            ),
          ],
        );
      },
    );
  }

}


class WeatherRow extends StatefulWidget {

  final Weather weather;

  WeatherRow(this.weather);
  @override
  _WeatherRowState createState() => _WeatherRowState();
}

class _WeatherRowState extends State<WeatherRow> {

  Weather weather;

  static String date;
  static String img = "./src/img/snow";
  static int day;
  static int high;
  static int row;
  static String state;

  @override
  void initState() {
    weather = widget.weather;
    img = imgSet[weather.state];
    date = weather.date;
    day = weather.day-1;
    high = weather.high_temp;
    row = weather.row_temp;
    state = stateSet[weather.state];
    super.initState();
  }
  
  Widget build(BuildContext context) {
    weather = widget.weather;
    img = imgSet[weather.state];
    date = weather.date;
    day = weather.day-1;
    high = weather.high_temp;
    row = weather.row_temp;
    state = stateSet[weather.state];
    return Container(
      height: 120.0,
      margin: const EdgeInsets.symmetric(
        vertical: 14.0,
        horizontal: 18.0
      ),
      child: new Stack(
        children: <Widget>[
          new Container(
            height: 100.0,
            margin: new EdgeInsets.only(left: 46.0),
            decoration: new BoxDecoration(
              color: Color.fromRGBO(72, 100, 205, 1),
              shape: BoxShape.rectangle,
              borderRadius: new BorderRadius.circular(8.0),
              boxShadow: <BoxShadow>[
                new BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10.0,
                  offset: new Offset(0.0, 10.0)
                )
              ]
            ),
            child: new Stack(
              children: <Widget>[
                new Container(
                  margin: new EdgeInsets.fromLTRB(62.0, 16.0, 16.0, 16.0),
                  constraints: new BoxConstraints.expand(),
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 110.0,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Container(height: 4.0),
                            new Text('$date (${daySet[day]})',
                              style: headerTextStyle,
                            ),
                            new Container(height: 8.0),
                            new Text(state,
                              style: headerTextStyle
                            ),
                          ],
                        ),
                      ),
                      new Container(width: 24.0,),
                      new Container(
                        margin: EdgeInsetsDirectional.only(top: 4.0),
                        child: new Text("${high.toString()}℃ / ${row.toString()}℃",
                          style: subHeaderText,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          new Container(
            margin: EdgeInsets.only(bottom: 16.0),
            alignment: FractionalOffset.centerLeft,
            child: new Image(
              image: new AssetImage(img),
              height: 92.0,
              width: 92.0,
            ),
          )
        ]
      )
    );
  }

  // final weatherCard = new Container(
  //   height: 100.0,
  //   margin: new EdgeInsets.only(left: 46.0),
  //   decoration: new BoxDecoration(
  //     color: Color.fromRGBO(72, 100, 205, 1),
  //     shape: BoxShape.rectangle,
  //     borderRadius: new BorderRadius.circular(8.0),
  //     boxShadow: <BoxShadow>[
  //       new BoxShadow(
  //         color: Colors.black12,
  //         blurRadius: 10.0,
  //         offset: new Offset(0.0, 10.0)
  //       )
  //     ]
  //   ),
  //   child: new Stack(
  //     children: <Widget>[
  //       weatherCardContent
  //     ],
  //   ),
  // );

  // static final weatherCardContent = new Container(
  //   margin: new EdgeInsets.fromLTRB(62.0, 16.0, 16.0, 16.0),
  //   constraints: new BoxConstraints.expand(),
  //   child: new Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //       Container(
  //         width: 110.0,
  //         child: new Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             new Container(height: 4.0),
  //             new Text('$date',
  //               style: headerTextStyle,
  //             ),
  //             new Container(height: 8.0),
  //             new Text("구름조금",
  //               style: headerTextStyle
  //             ),
  //           ],
  //         ),
  //       ),
  //       new Container(width: 24.0,),
  //       new Container(
  //         margin: EdgeInsetsDirectional.only(top: 4.0),
  //         child: new Text("-16℃ / -18℃",
  //           style: subHeaderText,
  //         ),
  //       ),
  //     ],
  //   ),
  // );


}