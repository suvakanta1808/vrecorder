// To parse this JSON data, do
//
//     final audiowaveFormResponse = audiowaveFormResponseFromJson(jsonString);

import 'dart:convert';

AudiowaveFormResponse audiowaveFormResponseFromJson(String str) =>
    AudiowaveFormResponse.fromJson(json.decode(str));

String audiowaveFormResponseToJson(AudiowaveFormResponse data) =>
    json.encode(data.toJson());

class AudiowaveFormResponse {
  AudiowaveFormResponse({
    required this.version,
    required this.channels,
    required this.sampleRate,
    required this.samplesPerPixel,
    required this.bits,
    required this.length,
    required this.data,
  });
  final int version;
  final int channels;
  final int sampleRate;
  final int samplesPerPixel;
  final int bits;
  final int length;
  final List<double> data;

  factory AudiowaveFormResponse.fromJson(Map<String, dynamic> json) =>
      AudiowaveFormResponse(
        version: json["version"],
        channels: json["channels"],
        sampleRate: json["sample_rate"],
        samplesPerPixel: json["samples_per_pixel"],
        bits: json["bits"],
        length: json["length"],
        data: List<double>.from(
            json["data"].map((x) => double.parse(x.toString()))),
      );

  Map<String, dynamic> toJson() => {
        "version": version,
        "channels": channels,
        "sample_rate": sampleRate,
        "samples_per_pixel": samplesPerPixel,
        "bits": bits,
        "length": length,
        "data": List<dynamic>.from(data.map((x) => x)),
      };
}
