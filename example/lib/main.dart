import 'package:flutter/material.dart';
import 'package:flutter_adaptive_layout/flutter_adaptive_layout.dart';
import 'package:flutter_adaptive_layout_example/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Demo Home Page'),
        ),
        body: AdaptiveLayout(
          smallBuilder: (context, child) => child!,
          mediumBuilder: (context, child) => Center(
            child: Material(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints.tight(const Size.square(400)),
                child: child,
              ),
            ),
          ),
          largeBuilder: (context, child) => Center(
            child: Material(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints.tight(const Size.square(600)),
                child: child,
              ),
            ),
          ),
          child: const MyHomePage(),
        ),
      ),
    );
  }
}
