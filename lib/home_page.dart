import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vrecorder/message_list.dart';
import 'package:vrecorder/own_message_card.dart';
import 'package:vrecorder/reply_card.dart';
import 'package:vrecorder/sound_recorder.dart';
import 'message.dart';

class HomePage extends StatelessWidget {
  //Declare Globaly
  String? directory;
  List<io.FileSystemEntity> files = [];
  final ScrollController _scrollController = ScrollController();
  List<Message>? messages;

  void sendBotReply(BuildContext context) {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    Future.delayed(const Duration(milliseconds: 1000), () {
      Provider.of<MessageList>(context, listen: false).addMessage(Message(
          message: 'Please wait! Processing your request.', sender: 'bot'));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    messages = Provider.of<MessageList>(context).posts;
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
                  itemCount: messages!.length,
                  itemBuilder: (context, index) {
                    if (index == messages!.length) {
                      return Container(
                        height: 70,
                      );
                    }
                    if (messages![index].sender == "Me") {
                      return OwnMessageCard(
                        message: messages![index].message,
                      );
                    } else {
                      return ReplyCard(
                        message: messages![index].message,
                      );
                    }
                  },
                ),
              ),
              RecordToStreamExample(
                scrollController: _scrollController,
              ),
              // SizedBox(
              //   height: 150,
              //   width: MediaQuery.of(context).size.width,
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [RecordToStreamExample()],
              //   ),
              // )
            ],
          ),
          // onWillPop: () {
          //   return true;
          //   ;
          // },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: const Color(0xFF128C7E),
      //   onPressed: () {
      //     Provider.of<MessageList>(context, listen: false)
      //         .addNewPost(Message(message: 'Recording Done', sender: 'Me'));
      //     sendBotReply(context);
      //   },
      //   tooltip: 'Record',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

// Navigator.push(context, MaterialPageRoute(builder: (c) {
//             return const AudioRecorder();
//           }));
