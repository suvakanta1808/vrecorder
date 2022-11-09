import 'package:flutter/material.dart';

class OwnMessageCard extends StatelessWidget {
  // const OwnMessageCard({required this.message});
  // final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.55,
        ),
        child: Card(
          elevation: 1,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          color: const Color(0xffdcf8c6),
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: const [
                Icon(
                  Icons.audio_file_outlined,
                  size: 15,
                ),
                SizedBox(
                  width: 10,
                ),
                Text('recorded_audio.wav'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
