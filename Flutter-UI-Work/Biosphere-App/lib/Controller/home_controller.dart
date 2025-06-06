import 'package:biosphere_app/Export/export.dart';
import 'package:biosphere_app/Helper/base_controller.dart';
import 'package:video_player/video_player.dart';

class HomeController extends BaseController {
  VideoPlayerController? videoController;
  var isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    videoController = VideoPlayerController.asset('assets/dna.mp4');
    videoController!
        .initialize()
        .then((_) {
          videoController!.setLooping(true);
          videoController!.play();
          isInitialized.value = true; // Notify UI to rebuild
        })
        .catchError((e) {
          print("Video initialization failed: $e");
        });
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }
}
