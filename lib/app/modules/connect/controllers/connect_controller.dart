import 'dart:async';
import 'dart:convert';

import 'package:agentx/utils/exts.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../../room.dart';
import '../../../../utils/widgets/participant_info.dart';

class ConnectController extends GetxController {
  List<MediaDevice> _audioInputs = [];
  List<MediaDevice> _videoInputs = [];
  StreamSubscription? _subscription;

  bool _busy = false;
  bool _enableVideo = true;
  bool _enableAudio = true;
  LocalAudioTrack? _audioTrack;
  LocalVideoTrack? _videoTrack;

  MediaDevice? _selectedVideoDevice;
  MediaDevice? _selectedAudioDevice;
  VideoParameters _selectedVideoParameters = VideoParametersPresets.h720_169;
  List<ParticipantTrack> participantTracks = [];
  late EventsListener<RoomEvent> _listener;

  final room = Rx<Room?>(null);
  RxBool isloading = false.obs;
  @override
  void onInit() {
    _subscription = Hardware.instance.onDeviceChange.stream.listen(_loadDevices);
    Hardware.instance.enumerateDevices().then(_loadDevices);
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void _loadDevices(List<MediaDevice> devices) async {
    _audioInputs = devices.where((d) => d.kind == 'audioinput').toList();
    _videoInputs = devices.where((d) => d.kind == 'videoinput').toList();

    if (_audioInputs.isNotEmpty) {
      if (_selectedAudioDevice == null) {
        _selectedAudioDevice = _audioInputs.first;
        Future.delayed(const Duration(milliseconds: 100), () async {
          await _changeLocalAudioTrack();
        });
      }
    }

    if (_videoInputs.isNotEmpty) {
      if (_selectedVideoDevice == null) {
        _selectedVideoDevice = _videoInputs.first;
        Future.delayed(const Duration(milliseconds: 100), () async {
          await _changeLocalVideoTrack();
        });
      }
    }
  }

  Future<void> _setEnableVideo(value) async {
    _enableVideo = value;
    if (!_enableVideo) {
      await _videoTrack?.stop();
      _videoTrack = null;
    } else {
      await _changeLocalVideoTrack();
    }
  }

  Future<void> _setEnableAudio(value) async {
    _enableAudio = value;
    if (!_enableAudio) {
      await _audioTrack?.stop();
      _audioTrack = null;
    } else {
      await _changeLocalAudioTrack();
    }
  }

  Future<void> _changeLocalAudioTrack() async {
    if (_audioTrack != null) {
      await _audioTrack!.stop();
      _audioTrack = null;
    }

    if (_selectedAudioDevice != null) {
      _audioTrack = await LocalAudioTrack.create(AudioCaptureOptions(deviceId: _selectedAudioDevice!.deviceId));
      await _audioTrack!.start();
    }
  }

  Future<void> _changeLocalVideoTrack() async {
    if (_videoTrack != null) {
      await _videoTrack!.stop();
      _videoTrack = null;
    }

    if (_selectedVideoDevice != null) {
      _videoTrack = await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(deviceId: _selectedVideoDevice!.deviceId, params: _selectedVideoParameters),
      );
      await _videoTrack!.start();
    }
  }

  join() async {
    isloading.value = true;
    _busy = true;

    // var args = widget.args;

    try {
      //create new room
      var cameraEncoding = const VideoEncoding(maxBitrate: 5 * 1000 * 1000, maxFramerate: 30);

      var screenEncoding = const VideoEncoding(maxBitrate: 3 * 1000 * 1000, maxFramerate: 15);

      E2EEOptions? e2eeOptions;
      // if (args.e2ee && args.e2eeKey != null) {
      //   final keyProvider = await BaseKeyProvider.create();
      //   e2eeOptions = E2EEOptions(keyProvider: keyProvider);
      //   await keyProvider.setKey(args.e2eeKey!);
      // }

      room?.value = Room(
        roomOptions: RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultAudioPublishOptions: const AudioPublishOptions(name: 'custom_audio_track_name'),
          defaultCameraCaptureOptions: const CameraCaptureOptions(maxFrameRate: 30, params: VideoParameters(dimensions: VideoDimensions(1280, 720))),
          defaultScreenShareCaptureOptions: const ScreenShareCaptureOptions(
            useiOSBroadcastExtension: true,
            params: VideoParameters(dimensions: VideoDimensionsPresets.h1080_169),
          ),
          defaultVideoPublishOptions: VideoPublishOptions(
            simulcast: true,
            videoCodec: 'VP8',
            backupVideoCodec: BackupVideoCodec(enabled: ['VP9', 'AV1'].contains('VP8')),
            videoEncoding: cameraEncoding,
            screenShareEncoding: screenEncoding,
          ),
          e2eeOptions: e2eeOptions,
        ),
      );
      // Create a Listener before connecting
      var response = await Dio().post("https://api.agentx.pragetx.com/agent/dispatch_agent/", data: {"language": "English"});
      print("fsdkfghdsjkfhfkjd");
      print(response.data);
      print(response.data["token"]);
      _listener = room.value!.createListener();
      await room?.value?.prepareConnection("wss://webcall-0dz77e97.livekit.cloud", response.data["token"]);

      // Try to connect to the room
      // This will throw an Exception if it fails for any reason.
      await room?.value?.connect(
        "wss://webcall-0dz77e97.livekit.cloud",
        response.data["token"],
        fastConnectOptions: FastConnectOptions(microphone: TrackOption(track: _audioTrack), camera: TrackOption(track: _videoTrack)),
      );
      update();
      // print("fjsgsjfhsgdjg");
      // print(room?.value?.connectionState);
      // room?.value?.addListener(_onRoomDidUpdate);
      // // add callbacks for finer grained events
      // _listener = room.value!.createListener();
      // _setUpListeners();
      // _sortParticipants();
      //
      // WidgetsBindingCompatible.instance?.addPostFrameCallback((_) {
      //   if (!(room?.value?.engine.fastConnectOptions != null)) {
      //     _askPublish();
      //   }
      // });
      // if (lkPlatformIs(PlatformType.android)) {
      //   Hardware.instance.setSpeakerphoneOn(true);
      // }
      //
      // if (lkPlatformIsDesktop()) {
      //   onWindowShouldClose = () async {
      //     unawaited(room?.value?.disconnect());
      //     await _listener.waitFor<RoomDisconnectedEvent>(duration: const Duration(seconds: 5));
      //   };
      // }
      isloading.value = false;
      Get.to(() => RoomPage(room?.value ?? Room(), _listener));
      // await Navigator.push<void>(Get.context!, MaterialPageRoute(builder: (_) => RoomPage(room, listener)));
    } catch (error) {
      isloading.value = false;
      print('Could not connect $error');
      await Get.context!.showErrorDialog(error);
    } finally {
      _busy = false;
    }
  }

  void _setUpListeners() =>
      _listener
        ..on<RoomConnectedEvent>((event) {
          print("fgjhdgsjdfdf");
          update();
        })
        ..on<RoomReconnectedEvent>((event) async {
          update();
        })
        ..on<RoomDisconnectedEvent>((event) async {
          if (event.reason != null) {
            print('Room disconnected: reason => ${event.reason}');
          }
          // TODO  add disconnect event here
          // WidgetsBindingCompatible.instance?.addPostFrameCallback((timeStamp) => Navigator.popUntil(context, (route) => route.isFirst));
        })
        ..on<ParticipantEvent>((event) {
          // sort participants on many track events as noted in documentation linked above
          _sortParticipants();
        })
        ..on<RoomRecordingStatusChanged>((event) {
          Get.context!.showRecordingStatusChangedDialog(event.activeRecording);
        })
        ..on<RoomAttemptReconnectEvent>((event) {
          print(
            'Attempting to reconnect ${event.attempt}/${event.maxAttemptsRetry}, '
            '(${event.nextRetryDelaysInMs}ms delay until next attempt)',
          );
        })
        ..on<LocalTrackSubscribedEvent>((event) {
          print('Local track subscribed: ${event.trackSid}');
        })
        ..on<LocalTrackPublishedEvent>((_) => _sortParticipants())
        ..on<LocalTrackUnpublishedEvent>((_) => _sortParticipants())
        ..on<TrackSubscribedEvent>((_) => _sortParticipants())
        ..on<TrackUnsubscribedEvent>((_) => _sortParticipants())
        ..on<TrackE2EEStateEvent>(_onE2EEStateEvent)
        ..on<ParticipantNameUpdatedEvent>((event) {
          print('Participant name updated: ${event.participant.identity}, name => ${event.name}');
          _sortParticipants();
        })
        ..on<ParticipantMetadataUpdatedEvent>((event) {
          print('Participant metadata updated: ${event.participant.identity}, metadata => ${event.metadata}');
        })
        ..on<RoomMetadataChangedEvent>((event) {
          print('Room metadata changed: ${event.metadata}');
        })
        ..on<DataReceivedEvent>((event) {
          String decoded = 'Failed to decode';
          try {
            decoded = utf8.decode(event.data);
          } catch (err) {
            print('Failed to decode: $err');
          }
          Get.context!.showDataReceivedDialog(decoded);
        })
        ..on<AudioPlaybackStatusChanged>((event) async {
          if (!(room!.value!.canPlaybackAudio)) {
            print('Audio playback failed for iOS Safari ..........');
            bool? yesno = await Get.context!.showPlayAudioManuallyDialog();
            if (yesno == true) {
              await room?.value?.startAudio();
            }
          }
        });

  void _onE2EEStateEvent(TrackE2EEStateEvent e2eeState) {
    print('e2ee state: $e2eeState');
  }

  void _askPublish() async {
    final result = await Get.context!.showPublishDialog();
    if (result != true) return;
    // video will fail when running in ios simulator
    try {
      await room?.value?.localParticipant?.setCameraEnabled(true);
    } catch (error) {
      print('could not publish video: $error');
      await Get.context!.showErrorDialog(error);
    }
    try {
      await room?.value?.localParticipant?.setMicrophoneEnabled(true);
    } catch (error) {
      print('could not publish audio: $error');
      await Get.context!.showErrorDialog(error);
    }
  }

  void _onRoomDidUpdate() {
    _sortParticipants();
  }

  void _sortParticipants() {
    List<ParticipantTrack> userMediaTracks = [];
    List<ParticipantTrack> screenTracks = [];
    for (var participant in room!.value!.remoteParticipants.values) {
      for (var t in participant.videoTrackPublications) {
        if (t.isScreenShare) {
          screenTracks.add(ParticipantTrack(participant: participant, type: ParticipantTrackType.kScreenShare));
        } else {
          userMediaTracks.add(ParticipantTrack(participant: participant));
        }
      }
    }
    // sort speakers for the grid
    userMediaTracks.sort((a, b) {
      // loudest speaker first
      if (a.participant.isSpeaking && b.participant.isSpeaking) {
        if (a.participant.audioLevel > b.participant.audioLevel) {
          return -1;
        } else {
          return 1;
        }
      }

      // last spoken at
      final aSpokeAt = a.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;
      final bSpokeAt = b.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;

      if (aSpokeAt != bSpokeAt) {
        return aSpokeAt > bSpokeAt ? -1 : 1;
      }

      // video on
      if (a.participant.hasVideo != b.participant.hasVideo) {
        return a.participant.hasVideo ? -1 : 1;
      }

      // joinedAt
      return a.participant.joinedAt.millisecondsSinceEpoch - b.participant.joinedAt.millisecondsSinceEpoch;
    });

    final localParticipantTracks = room?.value?.localParticipant?.videoTrackPublications;
    if (localParticipantTracks != null) {
      for (var t in localParticipantTracks) {
        if (t.isScreenShare) {
          screenTracks.add(ParticipantTrack(participant: room!.value!.localParticipant!, type: ParticipantTrackType.kScreenShare));
        } else {
          userMediaTracks.add(ParticipantTrack(participant: room!.value!.localParticipant!));
        }
      }
    }

    participantTracks = [...screenTracks, ...userMediaTracks];
  }
}
