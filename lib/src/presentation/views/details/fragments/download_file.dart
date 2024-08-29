// import 'dart:async';
// import 'dart:io';
//
// import '/utils/ads_helper.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
//
// import 'package:nb_utils/nb_utils.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';
// import 'package:dio/dio.dart';
// import 'package:provider/provider.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';
//
// import '../../../state/configs.dart';
// import '../../../state/data_state.dart';
// import '../../home/fragments/navs/downloads_nav.dart';
// import '../../home/home_screen.dart';
//
// class DownloadFile extends StatefulWidget {
//   const DownloadFile({super.key, required this.url, required this.title});
//
//   final String url;
//   final String title;
//
//   @override
//   State<DownloadFile> createState() => _DownloadFileState();
// }
//
// class _DownloadFileState extends State<DownloadFile> {
//   final Completer<Directory?> _tempDirCompleter = Completer();
//   double progress = 0.0;
//   String downloadedBytes = '';
//   String downloadSpeed = '';
//   String remainingTime = '';
//   int receivedBytes = 0;
//   int totalBytes = 0;
//   String totalBytesInKB = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _getTemporaryDirectory();
//     _downloadFile(widget.url, widget.title);
//   }
//
//   Future<void> _initDownloads() async {
//     Map<String, dynamic> downloads =
//         getJSONAsync('downloads', defaultValue: {});
//
//     if (downloads.isEmpty) {
//       downloads = {"movies": {}, "series": {}};
//     }
//
//     await setValue("downloads", downloads);
//   }
//
//   Future<Directory?> _getTemporaryDirectory() async {
//     if (!_tempDirCompleter.isCompleted) {
//       final tempDir = await getApplicationDocumentsDirectory();
//       _tempDirCompleter.complete(tempDir);
//     }
//     return _tempDirCompleter.future;
//   }
//
//   var dio = Dio();
//
//   Future<void> _downloadFile(String url, String fileName) async {
//     WakelockPlus.enable();
//     await _initDownloads();
//     final Map<String, dynamic> downloads =
//         getJSONAsync('downloads', defaultValue: {});
//     final DataState state = Provider.of<DataState>(context, listen: false);
//
//     if (state.currentIsMovie) {
//       if (downloads['movies'].containsKey(state.currentMovieTitle)) {
//         await showDialog(
//             context: context,
//             barrierDismissible: false,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: const Text('Download Error'),
//                 content: const Text('This movie has already been downloaded.'),
//                 actions: <Widget>[
//                   TextButton(
//                     child: const Text('Go to Downloads'),
//                     onPressed: () => Navigator.of(context).push(
//                       MaterialPageRoute(
//                           builder: (context) => const DownloadsNav()),
//                     ),
//                   ),
//                   TextButton(
//                     child: const Text('Go Back'),
//                     onPressed: () => WidgetsBinding.instance
//                         .addPostFrameCallback(
//                             (_) => Navigator.pushAndRemoveUntil(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => const HomeScreen()),
//                                   (Route<dynamic> route) => false,
//                                 )),
//                   ),
//                 ],
//               );
//             });
//       }
//     }
//
//     if (state.currentIsSeries) {
//       fileName =
//           '${state.currentSeriesTitle}_${state.currentSeasonTitle}_${state.currentEpisodeTitle}';
//       if (downloads['series'].containsKey(state.currentSeriesTitle)) {
//         if (downloads['series'][state.currentSeriesTitle]["seasons"]
//             .containsKey(state.currentSeasonTitle)) {
//           if (downloads['series'][state.currentSeriesTitle]["seasons"]
//                   [state.currentSeasonTitle]["episodes"]
//               .containsKey(state.currentEpisodeTitle)) {
//             await showDialog(
//                 context: context,
//                 barrierDismissible: false,
//                 builder: (BuildContext context) {
//                   return AlertDialog(
//                     title: const Text('Download Error'),
//                     content:
//                         const Text('This episode has already been downloaded.'),
//                     actions: <Widget>[
//                       TextButton(
//                         child: const Text('Go to Downloads'),
//                         onPressed: () => Navigator.of(context).push(
//                           MaterialPageRoute(
//                               builder: (context) => const DownloadsNav()),
//                         ),
//                       ),
//                       TextButton(
//                         child: const Text('Go Back'),
//                         onPressed: () => WidgetsBinding.instance
//                             .addPostFrameCallback((_) =>
//                                 Navigator.pushAndRemoveUntil(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => const HomeScreen()),
//                                   (Route<dynamic> route) => false,
//                                 )),
//                       ),
//                     ],
//                   );
//                 });
//           }
//         }
//       }
//     }
//
//     try {
//       final dir = await getApplicationDocumentsDirectory();
//       final savePath = '${dir.path}/$fileName';
//       File file = File(savePath);
//
//       if (await file.exists()) await file.delete();
//
//       int oldReceivedBytes = receivedBytes;
//       Timer timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
//         if (mounted) {
//           setState(() {
//             downloadSpeed = ((receivedBytes - oldReceivedBytes) / 1024 / 5)
//                 .toStringAsFixed(2);
//             double remainingTimeInMinutes = (((totalBytes - receivedBytes) /
//                     (receivedBytes - oldReceivedBytes)) /
//                 60); // Convert to minutes
//             remainingTime = formatTime(remainingTimeInMinutes);
//           });
//         }
//         oldReceivedBytes = receivedBytes;
//       });
//
//       await dio.download(
//         url,
//         savePath,
//         onReceiveProgress: (rBytes, tBytes) {
//           setState(() {
//             receivedBytes = rBytes;
//             totalBytes = tBytes;
//             progress = (receivedBytes / totalBytes).clamp(0.0, 1.0);
//             downloadedBytes = (receivedBytes / 1024 / 1024)
//                 .toStringAsFixed(2); // Convert to MB
//             totalBytesInKB =
//                 (totalBytes / 1024 / 1024).toStringAsFixed(2); // Convert to MB
//           });
//         },
//       );
//
//       if (state.currentIsMovie) {
//         downloads['movies'][state.currentMovieTitle] = {
//           "title": state.currentMovieTitle,
//           "poster": state.currentPoster,
//           "path": savePath,
//         };
//       }
//       if (state.currentIsSeries) {
//         // Check if the series exists
//         if (!downloads['series'].containsKey(state.currentSeriesTitle)) {
//           downloads['series'][state.currentSeriesTitle] = {
//             "title": state.currentSeriesTitle,
//             "poster": state.currentPoster,
//             "seasons": {},
//           };
//         }
//         // Check if the season exists within the series
//         if (!downloads['series'][state.currentSeriesTitle]["seasons"]
//             .containsKey(state.currentSeasonTitle)) {
//           downloads['series'][state.currentSeriesTitle]["seasons"]
//               [state.currentSeasonTitle] = {
//             "title": state.currentSeasonTitle,
//             "episodes": [],
//           };
//         }
//         // Add the episode to the season
//         downloads['series'][state.currentSeriesTitle]["seasons"]
//                 [state.currentSeasonTitle]["episodes"]
//             .add({
//           'title': state.currentEpisodeTitle,
//           'path': savePath,
//         });
//       }
//
//       await setValue("downloads", downloads);
//
//       await showDialog(
//         context: _scaffoldKey.currentContext ?? context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           //after download is complete lets save its path to shared prefs
//           //and show a dialog to the user
//           return AlertDialog(
//             title: const Text('Download Complete'),
//             content: const Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.check_circle, color: Colors.green, size: 100),
//                 Text('The file has been downloaded successfully.'),
//               ],
//             ),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text('Go to Downloads'),
//                 onPressed: () async {
//                   createInterstitialAd();
//                   showInterstitialAd();
//                   WidgetsBinding.instance
//                       .addPostFrameCallback((_) => Navigator.pushAndRemoveUntil(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const DownloadsNav(
//                                       pushedFromDownloads: true,
//                                     )),
//                             (Route<dynamic> route) => false,
//                           ));
//                 },
//               ),
//               TextButton(
//                 child: const Text('Go Back'),
//                 onPressed: () async {
//                   WidgetsBinding.instance
//                       .addPostFrameCallback((_) => Navigator.pushAndRemoveUntil(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const HomeScreen()),
//                             (Route<dynamic> route) => false,
//                           ));
//                 },
//               ),
//             ],
//           );
//         },
//       );
//
//       timer.cancel();
//       WakelockPlus.disable();
//     } catch (e) {
//       if (kDebugMode) print('Download error: $e');
//       String errorMessage = 'Unknown error occurred';
//
//       if (e is DioException) {
//         switch (e.type) {
//           case DioExceptionType.cancel:
//             errorMessage = 'Download cancelled';
//             break;
//           case DioExceptionType.sendTimeout:
//           case DioExceptionType.receiveTimeout:
//           case DioExceptionType.connectionTimeout:
//             errorMessage =
//                 'Connection timeout, please check your internet connection';
//             break;
//           case DioExceptionType.badResponse:
//             errorMessage = 'Server error, please try again later';
//             break;
//           case DioExceptionType.badCertificate:
//             errorMessage = 'Invalid SSL certificate';
//             break;
//           case DioExceptionType.connectionError:
//             errorMessage =
//                 'Connection error, please check your internet connection';
//             break;
//           case DioExceptionType.unknown:
//           default:
//             errorMessage = 'Unknown error occurred';
//             break;
//         }
//       }
//
//       showDialog(
//         context: _scaffoldKey.currentContext ?? context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Download Error'),
//             content: Text(errorMessage),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text('Restart'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   _downloadFile(url, fileName);
//                 },
//               ),
//               TextButton(
//                 onPressed: mounted
//                     ? () => WidgetsBinding.instance.addPostFrameCallback(
//                         (_) => Navigator.pushAndRemoveUntil(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => const HomeScreen()),
//                               (Route<dynamic> route) => false,
//                             ))
//                     : null,
//                 child: const Text('Exit'),
//               ),
//             ],
//           );
//         },
//       );
//       WakelockPlus.disable();
//     }
//   }
//
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   Widget build(BuildContext context) {
//     final configsProvider = context.watch<ConfigsProvider>();
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (value, _) {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text('Warning'),
//               content: const Text(
//                   'If you exit, the file will stop downloading and you will have to start over. Do you want to exit?'),
//               actions: <Widget>[
//                 TextButton(
//                   child: const Text('Stay'),
//                   onPressed: () {
//                     Navigator.of(context).pop(false);
//                   },
//                 ),
//                 TextButton(
//                   child: const Text('Exit'),
//                   onPressed: () => WidgetsBinding.instance
//                       .addPostFrameCallback((_) => Navigator.pushAndRemoveUntil(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const HomeScreen()),
//                             (Route<dynamic> route) => false,
//                           )),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//       child: Scaffold(
//         bottomNavigationBar: configsProvider.showBannerAds
//             ? bannerAd != null
//                 ? Container(
//                     height: 52,
//                     margin: const EdgeInsets.only(bottom: 12),
//                     child: AdWidget(ad: bannerAd!),
//                   )
//                 : null
//             : null,
//         key: _scaffoldKey,
//         body: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 150),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 RichText(
//                     text: TextSpan(
//                   text: 'Downloading ... ',
//                   style: const TextStyle(color: Colors.grey),
//                   children: [
//                     TextSpan(
//                         text: '\n${widget.title}',
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 20,
//                             color: Colors.white)),
//                   ],
//                 )),
//                 CircularPercentIndicator(
//                   radius: 150,
//                   percent: progress,
//                   center: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text('Downloaded: $downloadedBytes MB'),
//                       Text('Total: $totalBytesInKB MB'),
//                       Text('Speed: $downloadSpeed KB/s'),
//                       Text('Remaining time: $remainingTime'),
//                     ],
//                   ),
//                 ),
//                 const Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Please do not exit the app while downloading.',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     Text(
//                       'For better download experience, use ADM.',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   String formatTime(double timeInMinutes) {
//     if (timeInMinutes.isInfinite || timeInMinutes.isNaN) {
//       return 'waiting ...'; // Default value
//     }
//
//     if (timeInMinutes >= 60) {
//       return '${(timeInMinutes / 60).floor()} hours'; // Convert to hours and remove decimals
//     } else if (timeInMinutes >= 1) {
//       return '${timeInMinutes.floor()} minutes'; // Convert to minutes and remove decimals
//     } else {
//       return '${(timeInMinutes * 60).floor()} seconds'; // Convert to seconds and remove decimals
//     }
//   }
// }
