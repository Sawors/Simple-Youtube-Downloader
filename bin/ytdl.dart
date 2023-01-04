
import 'dart:io';
import 'dart:math';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final YoutubeExplode client = YoutubeExplode();
String extension = "mp3";

Future<void> main(List<String> arguments) async {
  // first check for potentials modifiers :
  // ADD ARGS LISTS :P
  // -ogg   downloads the video in ogg
  // -mp3   downloads the video in mp3
  // -ls    lists the videos

  // stdin.readLineSync();

  if(arguments.any((element) => element == "-mp3")) extension = "mp3";
  if(arguments.any((element) => element == "-ogg")) extension = "ogg";


  if(arguments.isEmpty){
    print("please provide at least one argument for the search");
    return;
  }

  final String title = arguments.join()
      .replaceAll("-ogg", "")
      .replaceAll("-mp3", "");

  try{
    final Video video = await getFirstVideo(arguments.isNotEmpty ? title : "Rick Astley - Never Gonna Give You Up (Official Music Video)");
    print("Downloading \"${video.title}\"");
    File? resultFile = await downloadVideo(video.id.value, video);
    if(resultFile != null){
      print("\nSuccessfully downloaded \"${video.title}\" !");
      print("\nFile located at ${resultFile.path}");
      String duration = video.duration.toString();
      int startIndex = duration.startsWith("0:") ? 2 : 0;
      if(duration.contains(".")) duration = duration.substring(startIndex,duration.indexOf("."));
      
      print("Channel : ${video.author}");
      print("Duration : $duration");

    }
  } on StateError catch(e){
    print(e.message);
  }

  client.close();
}

Future<Video> getFirstVideo(String searchString) async {
  searchString = searchString.isEmpty ? "Rick Astley - Never Gonna Give You Up (Official Music Video)" : searchString;
  final String emptyErrorMessage = "no matching video found using the search $searchString";

  VideoSearchList result = await client.search.search(searchString);

  if(result.isEmpty){
    print("-> exact video not found, using suggestions instead...");
    List<String> suggestions = await client.search.getQuerySuggestions(searchString);
    if(suggestions.isEmpty){
      throw StateError(emptyErrorMessage);
    }
    print("-> using suggestion \"${suggestions.first}\"");
    result = await client.search.search(suggestions.first);
    if(result.isEmpty){
      throw StateError(emptyErrorMessage);
    }
  }
  return result.first;
}

Future<File?> downloadVideo(String videoId,[Video? video]) async{

  if(videoId.isEmpty) return null;

  var manifest = await client.videos.streamsClient.getManifest(videoId);
  var audioOnly =  manifest.audioOnly;
  audioOnly.toList().sort((e1, e2) => max(e1.bitrate.bitsPerSecond, e2.bitrate.bitsPerSecond));
  if(audioOnly.isNotEmpty){
    AudioOnlyStreamInfo bestBitrate = audioOnly.first;

    var stream = client.videos.streamsClient.get(bestBitrate);
    final String fileName = (video?.title ?? videoId)
        .replaceAll("/", "")
        .replaceAll("\\", "")
        .replaceAll(":", "")
        .replaceAll("*", "")
        .replaceAll("?", "")
        .replaceAll("\"", "")
        .replaceAll("<", "")
        .replaceAll(">", "")
        .replaceAll("|", "");
    var file = File("${Directory.current.path}${Platform.pathSeparator}$fileName.$extension");
    file.createSync(recursive: true);
    var fileStream = file.openWrite();

    await stream.pipe(fileStream);
    await fileStream.flush();
    await fileStream.close();

    return file;
  }

  return null;
}

enum WorkingMode {
  firstOnly, listed
}
