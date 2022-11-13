import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:vrecorder/message.dart';
import 'package:vrecorder/message_list.dart';
import "audiowaveform_response.dart";

/*
 * This is an example showing how to record to a Dart Stream.
 * It writes all the recorded data from a Stream to a File, which is completely stupid:
 * if an App wants to record something to a File, it must not use Streams.
 *
 * The real interest of recording to a Stream is for example to feed a
 * Speech-to-Text engine, or for processing the Live data in Dart in real time.
 *
 */

///
const int tSampleRate = 16000;
typedef _Fn = void Function();

/// Example app.
class RecordToStreamExample extends StatefulWidget {
  const RecordToStreamExample({super.key});

  @override
  _RecordToStreamExampleState createState() => _RecordToStreamExampleState();
}

class _RecordToStreamExampleState extends State<RecordToStreamExample> {
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  String? _mPath;
  String? filename;
  StreamSubscription? _mRecordingDataSubscription;

  Future<void> _openRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _mRecorder!.openRecorder();

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    setState(() {
      _mRecorderIsInited = true;
    });
  }

  @override
  void initState() {
    super.initState();
    // Be careful : openAudioSession return a Future.
    // Do not access your FlutterSoundPlayer or FlutterSoundRecorder before the completion of the Future
    _mPlayer!.openPlayer().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });
    _openRecorder();
  }

  @override
  void dispose() {
    _mPlayer!.closePlayer();
    _mPlayer = null;

    stopRecorder();
    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

  Future<String> createFile() async {
    var tempDir = await getExternalStorageDirectory();
    var timestamp = '${DateTime.now().millisecondsSinceEpoch}.wav';
    setState(() {
      filename = timestamp;
      _mPath = '${tempDir!.path}/$timestamp';
    });
    return _mPath!;
  }

  Future<void> record() async {
    assert(_mRecorderIsInited && _mPlayer!.isStopped);
    var fileName = await createFile();

    await _mRecorder!.startRecorder(
      toFile: fileName,
      codec: Codec.pcm16WAV,
      numChannels: 1,
      sampleRate: tSampleRate,
    );
    setState(() {});
  }

  sendRequest(String audioPath) async {
    var postUri = Uri.parse("https://2a72-14-139-207-163.ngrok.io/audiowave");
    var request = http.MultipartRequest("POST", postUri);
    try {
      Uint8List fileBuffer = await File(audioPath).readAsBytes();
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        audioPath,
        contentType: MediaType('audio', 'mp3'),
      ));

      print('Porcessing!');
      final response = await request.send();

      if (response.statusCode == 201) {
        print("Request Sent!");
        final respStr = await response.stream.bytesToString();
        AudiowaveFormResponse audiowaveFormResponse =
            audiowaveFormResponseFromJson(respStr);

        var res = calculateResult(audiowaveFormResponse.data);

        Provider.of<MessageList>(context, listen: false)
            .addNewPost(Message(message: res.toString(), sender: 'Bot'));

        Provider.of<MessageList>(context, listen: false).addNewPost(
            Message(message: "Do you want something else?", sender: 'Bot'));
        // debugPrint(audiowaveFormResponse.data.toString());
      } else {
        print("Request Failed!");
        Provider.of<MessageList>(context, listen: false).addNewPost(
            Message(message: 'Request failed. Try again!', sender: 'Bot'));
      }
    } catch (e) {
      print(e);
    }
  }

  int calculateResult(List<double> data) {
    // execute util functions
    return 1;
  }

  Future<void> stopRecorder() async {
    await _mRecorder!.stopRecorder();
    if (_mRecordingDataSubscription != null) {
      await _mRecordingDataSubscription!.cancel();
      _mRecordingDataSubscription = null;
    }
    _mplaybackReady = true;

    Provider.of<MessageList>(context, listen: false)
        .addNewPost(Message(message: filename!, sender: 'Me'));

    Future.delayed(const Duration(milliseconds: 500), () {
      Provider.of<MessageList>(context, listen: false).addNewPost(Message(
          message: 'Please wait! Processing your request.', sender: 'bot'));
    });

    sendRequest(_mPath!);
  }

  _Fn? getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer!.isStopped) {
      return null;
    }
    return _mRecorder!.isStopped
        ? record
        : () {
            stopRecorder().then((value) => setState(() {}));
          };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(3),
      padding: const EdgeInsets.all(3),
      height: 70,
      width: 70,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade500,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(
          onPressed: getRecorderFn(),
          color: Colors.white,
          icon: Icon(
            _mRecorder!.isRecording
                ? Icons.stop_circle_rounded
                : Icons.mic_rounded,
            size: 30,
          ),
        ),
      ]),
    );
  }
}
