import 'package:flutter/material.dart';

import 'pages/basic_example_page.dart';
import 'pages/expandable_example_page.dart';
import 'pages/youtube_example_page.dart';

void main() => runApp(MyApp());

class RouteNames {
  static const String root="/";
  static const String simple="/simple";
  static const String expandable="/expandable";
  static const String youtube="/youtube";
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrollable Timeline Demo',
      initialRoute: RouteNames.root,
      routes: {
        RouteNames.root: (context) => MainScreen(),
        RouteNames.simple: (context) => BasicExamplePage(),
        RouteNames.expandable: (context) => ExpandableExamplePage(),
        RouteNames.youtube: (context) => YoutubeExamplePage(),
      },
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  final ButtonStyle btnStyle =
  ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20),backgroundColor: Colors.green);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text("ScrollableTimeline example")),
        body: Center(
      child: Column(
        children: [
          const SizedBox(height: 10),
          ElevatedButton(
              style: btnStyle,
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.simple);
              },
              child: Text("simple example")),
          const SizedBox(height: 10),
          ElevatedButton(
              style: btnStyle,
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.expandable);
              },
              child: Text("expandable example")),
          const SizedBox(height: 10),
          ElevatedButton(
              style: btnStyle,
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.youtube);
              },
              child: Text("youtube example")),
        ],
      ),
    ));
  }
}
