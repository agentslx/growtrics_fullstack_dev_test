import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'solving_capture_state.dart';

class SolvingCaptureCubit extends Cubit<SolvingCaptureState> {
  SolvingCaptureCubit() : super(const SolvingCaptureState());

  final ImagePicker _imagePicker = ImagePicker();
  CameraController? controller;
  List<CameraDescription> _cameras = const [];

  Future<void> init() async {
    try {
      emit(state.copyWith(isInitializing: true));
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        emit(state.copyWith(
          isInitializing: false,
          isCameraReady: false,
          totalCameras: 0,
          errorMessage: 'No cameras available',
        ));
        return;
      }
      await _initControllerForIndex(0);
      emit(state.copyWith(
        isInitializing: false,
        isCameraReady: true,
        totalCameras: _cameras.length,
      ));
    } catch (e) {
      emit(state.copyWith(
        isInitializing: false,
        isCameraReady: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _initControllerForIndex(int index) async {
    final description = _cameras[index];
    final newController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await controller?.dispose();
    controller = newController;
    await controller!.initialize();
    // Default flash off
    await controller!.setFlashMode(FlashMode.off);
    emit(state.copyWith(selectedCameraIndex: index, isFlashOn: false));
  }

  Future<void> switchCamera() async {
    if (!state.canSwitchCamera || controller == null) return;
    final nextIndex = (state.selectedCameraIndex + 1) % _cameras.length;
    emit(state.copyWith(isCameraReady: false));
    await _initControllerForIndex(nextIndex);
    emit(state.copyWith(isCameraReady: true));
  }

  Future<void> toggleFlash() async {
    final c = controller;
    if (c == null) return;
    try {
      final nextOn = !state.isFlashOn;
      await c.setFlashMode(nextOn ? FlashMode.torch : FlashMode.off);
      emit(state.copyWith(isFlashOn: nextOn));
    } catch (e) {
      if (kDebugMode) {
        print('toggleFlash error: $e');
      }
    }
  }

  Future<File?> captureImage() async {
    final c = controller;
    if (c == null || !c.value.isInitialized || c.value.isTakingPicture) return null;
    try {
      final xfile = await c.takePicture();
      return File(xfile.path);
    } catch (e) {
      return null;
    }
  }

  Future<File?> pickFromGallery() async {
    try {
      final xfile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (xfile == null) return null;
      return File(xfile.path);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> close() async {
    await controller?.dispose();
    return super.close();
  }
}

