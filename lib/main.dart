import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vrecorder/home_page.dart';
import 'package:vrecorder/message_list.dart';

// import 'package:record_example/audio_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: MessageList(),
      child: MaterialApp(
        title: 'V-Recorder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightGreen,
        ),
        home: HomePage(),
      ),
    );
  }
}
