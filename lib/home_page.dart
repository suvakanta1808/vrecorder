import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vrecorder/sound_recorder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Declare Globaly
  String? directory;
  List<io.FileSystemEntity> files = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listofFiles();
  }

  // Make New Function
  void _listofFiles() async {
    PermissionStatus status = await Permission.storage.status;

    if (!status.isGranted) {
      await Permission.storage.request();
    }

    directory = "/storage/emulated/0"; //Give your folder path
    setState(() {
      files = io.Directory("$directory/vrecorder/")
          .listSync(); //use your folder name insted of resume.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (ctx, i) => ListTile(
          title: Text(files[i].path),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (c) {
            return RecordToStreamExample();
          }));
        },
        tooltip: 'Record',
        child: const Icon(Icons.mic_sharp),
      ),
    );
  }
}
