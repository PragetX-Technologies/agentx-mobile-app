import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/connect_controller.dart';

class ConnectView extends GetView<ConnectController> {
  const ConnectView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConnectController>(
      init: ConnectController(),
      assignId: true,
      builder: (logic) {
        return Scaffold(
          backgroundColor: const Color(0xff0F1015),
          appBar: AppBar(
            backgroundColor: const Color(0xff0F1015),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Color(0xff0F1015), // Set your desired color
              statusBarIconBrightness: Brightness.light, // Adjust icon brightness
            ),
            title: const Text('AgentX', style: TextStyle(color: Colors.white)),
            centerTitle: true,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Handle the tap event here
                    print('Circle tapped!');
                    controller.join();
                  },
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      gradient: RadialGradient(
                        colors: [Colors.white.withOpacity(0.1), Color(0xff1E1F28), Color(0xff1E1F28)],
                        center: Alignment.center,
                        radius: 0.8,
                      ),
                    ),
                    child: Icon(Icons.mic, size: 50, color: Colors.white.withOpacity(0.5)),
                  ),
                ),
              ),
              // SoundWaveformWidget(key: ValueKey(activeAudioTrack!.hashCode), audioTrack: activeAudioTrack!, width: 8)
              Obx(() {
                if (controller.isloading.value) {
                  return Text("Connecting", style: TextStyle(color: Colors.white));
                }
                if (controller.room.value?.connectionState.toString() == "ConnectionState.connected") {
                  return Text("Conneted", style: TextStyle(color: Colors.white));
                }

                return Text(controller.room.value?.connectionState.toString() ?? "Not Connected", style: TextStyle(color: Colors.white));
              }),
              SizedBox(height: 150),
              Text('AgentX Pragetx Softwares PVT. LTD.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }
}
