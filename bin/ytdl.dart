
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final YoutubeExplode client = YoutubeExplode();
String extension = "mp3";
bool listMode = false;

Future<void> main(List<String> arguments) async {
  // first check for potentials modifiers :
  // ADD ARGS LISTS :P
  // -ogg   downloads the video in ogg
  // -mp3   downloads the video in mp3
  // -ls    lists the videos

  // stdin.readLineSync();

  if(arguments.any((element) => element == "-mp3")) extension = "mp3";
  if(arguments.any((element) => element == "-ogg")) extension = "ogg";
  listMode = arguments.any((element) => element == "-ls" || element == "-list");

  if(arguments.isEmpty){
    print("please provide at least one argument for the search");
    return;
  }

  final String title = arguments.join(" ")
      .replaceAll("-ogg", "")
      .replaceAll("-mp3", "")
      .replaceAll("-ls", "")
      .replaceAll("-list", "")
      .replaceFirst(" ", "");

  try{
    if(listMode){
      print("Searching for \"$title\"...");
      Map<int, List<Video>> resultPages = {};
      VideoSearchList results = await client.search.search(title.isNotEmpty ? title : "Rick Astley - Never Gonna Give You Up (Official Music Video)");
      int i = 0;
      const int pageLength = 5;
      for(Video vid in results){
        var previous = resultPages[i];
        resultPages[i] = [...?previous, vid];
        if(results.indexOf(vid)%pageLength == pageLength-1) i++;
      }
      final String resultMessage = "Videos found while searching for \"$title\" : ";
      print(resultMessage);
      int pageIndex = 0;
      await showVideoSelectionPage(
          pages: resultPages,
          pageIndex: pageIndex,
          resultMessage: resultMessage,
          pageLength: pageLength,
          source: results
      );
    } else {
      final Video video = await getFirstVideo(title.isNotEmpty ? title : "Rick Astley - Never Gonna Give You Up (Official Music Video)");
      await downloadVideo(video.id.value, video);
    }

  } on StateError catch(e){
    print(e.message);
  } on OSError catch(e){
    print("OS error, please report this at https://github.com/Sawors/Simple-Youtube-Downloader/issues/new");
    print("--v--COPY AND PASTE THIS--v--");
    print(e);
    print("--^--COPY AND PASTE THIS--^--");
  }





  client.close();
}

Future<void> showVideoSelectionPage({
    required Map<int, List<Video>> pages,
    required int pageIndex,
    String resultMessage = "Videos found while searching for \"Placeholder Title\"",
    int pageLength = 5,
    VideoSearchList? source}) async{

  List<Video> pageContent = pages[pageIndex] ?? [];
  for(Video resultVideo in pageContent){
    String duration = resultVideo.duration.toString();
    int startIndex = duration.startsWith("0:") ? 2 : 0;
    if(duration.contains(".")) duration = duration.substring(startIndex,duration.indexOf("."));
    print("  [${(pageIndex*pageLength)+pageContent.indexOf(resultVideo)+1}] \"${resultVideo.title}\" - $duration");
  }
  String pageMessageSpacer = "";
  for(int f = 0; f<(resultMessage.length~/2)-10; f++){
    pageMessageSpacer += " ";
  }
  print("$pageMessageSpacer${pageIndex > 0 ? "<-p-" : ""} [page ${pageIndex+1}] -n->");
  print("\nEnter \"N\", \"n\" or \"next\" to go to the next page,");
  print("Enter \"P\", \"p\" or \"previous\" to go to the previous page,");
  print("Enter \"x\", \"e\" or \"exit\" to exit");
  print("Or enter the number of the video you want to download");
  stdout.write("\nAction : ");
  String selection = stdin.readLineSync(encoding: utf8) ?? "exit";
  switch(selection){
    case "N":
    case "n":
    case "next":
    case "NEXT":
    int i = pageIndex+1;
      if((pages[i] == null || (pages[i]?.length ?? 0) <= 0) && source != null){

        await source.nextPage();
        for(Video vid in source){
          var previous = pages[i];
          pages[i] = [...?previous, vid];
          if(source.indexOf(vid)%pageLength == pageLength-1) i++;
        }
      }
      print(pages);
      await showVideoSelectionPage(
          pages: pages,
          pageIndex: pageIndex+1,
          resultMessage: resultMessage,
          pageLength: pageLength,
          source: source
      );
      break;
    case "P":
    case "p":
    case "previous":
    case "PREVIOUS":
      if(pageIndex > 0){
        await showVideoSelectionPage(
            pages: pages,
            pageIndex: pageIndex-1,
            resultMessage: resultMessage,
            pageLength: pageLength,
            source: source
        );
      } else {
        await showVideoSelectionPage(
            pages: pages,
            pageIndex: pageIndex,
            resultMessage: resultMessage,
            pageLength: pageLength,
            source: source
        );
      }
      break;
    case "exit":
    case "EXIT":
    case "x":
    case "e":
      return;
    default:
      int? selectionValue = int.tryParse(selection);
      if(selectionValue != null){
        // the user selected a video
        selectionValue = selectionValue-(1+(pageIndex*pageLength));
        if(selectionValue >= 0 && selectionValue < pageContent.length){
          Video video = pageContent[selectionValue];
          await downloadVideo(video.id.value,video);
          break;
        }
      } else {
        // the user did nothing
        await showVideoSelectionPage(
            pages: pages,
            pageIndex: pageIndex,
            resultMessage: resultMessage,
            pageLength: pageLength,
            source: source
        );
        break;
      }
  }
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
  print("Downloading \"${video?.title ?? videoId}\"...");

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

    print("\nSuccessfully downloaded \"${video?.title ?? videoId}\" !");
    print("\nFile located at ${file.path}");
    if(video != null){
      String duration = video.duration.toString();
      int startIndex = duration.startsWith("0:") ? 2 : 0;
      if(duration.contains(".")) duration = duration.substring(startIndex,duration.indexOf("."));

      print("Channel : ${video.author}");
      print("Duration : $duration");
    }

    return file;
  }

  return null;
}

enum WorkingMode {
  firstOnly, listed
}
