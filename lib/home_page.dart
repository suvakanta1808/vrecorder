import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:vrecorder/own_message_card.dart';
import 'package:vrecorder/reply_card.dart';
import 'message.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Declare Globaly
  String? directory;
  List<io.FileSystemEntity> files = [];
  final _isRecorderOn = false;

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> messages = [
    Message(message: "Hello", sender: "bot"),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _listofFiles();
  }

  // Make New Function
  // void _listofFiles() async {
  //   PermissionStatus status = await Permission.storage.status;

  //   if (!status.isGranted) {
  //     await Permission.storage.request();
  //   }

  //   directory = "/storage/emulated/0"; //Give your folder path
  //   setState(() {
  //     files = io.Directory("$directory/vrecorder/")
  //         .listSync(); //use your folder name insted of resume.
  //   });
  // }

  void sendBotReply() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        messages.add(Message(
            message: 'Please wait! Processing your request.', sender: 'bot'));
      });
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.blueGrey.shade600,
        title: const Text(
          'Chat Bot',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.blueGrey.shade900,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(top: 10),
        child: WillPopScope(
          onWillPop: () async => false,
          child: Column(
            children: [
              Expanded(
                // height: MediaQuery.of(context).size.height - 150,
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return Container(
                        height: 70,
                      );
                    }
                    if (messages[index].sender == "Me") {
                      return OwnMessageCard();
                    } else {
                      return ReplyCard(
                        message: messages[index].message,
                      );
                    }
                  },
                ),
              ),
              SizedBox(
                // height: 150,
                // width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [],
                ),
              )
            ],
          ),
          // onWillPop: () {
          //   return true;
          //   ;
          // },
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: const Color(0xFF128C7E),
      //   onPressed: () {
      //     if (_isRecorderOn) {
      //       setState(() {
      //         _isRecorderOn = false;
      //         messages.add(Message(message: 'Recording Done', sender: 'Me'));
      //         sendBotReply();
      //       });
      //     } else {
      //       setState(() {
      //         messages
      //             .add(Message(message: 'Recording started!', sender: 'Bot'));
      //         _isRecorderOn = true;
      //       });
      //     }
      //   },
      //   tooltip: 'Record',
      //   child: _isRecorderOn
      //       ? const Icon(Icons.stop)
      //       : const Icon(Icons.mic_sharp),
      // ),
    );
  }
}

// Navigator.push(context, MaterialPageRoute(builder: (c) {
//             return const AudioRecorder();
//           }));
