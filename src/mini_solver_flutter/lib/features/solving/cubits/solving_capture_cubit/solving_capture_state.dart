import 'package:equatable/equatable.dart';

class SolvingCaptureState extends Equatable {
  const SolvingCaptureState({
    this.isInitializing = true,
    this.isCameraReady = false,
    this.isFlashOn = false,
    this.selectedCameraIndex = 0,
    this.totalCameras = 0,
    this.errorMessage,
  });

  final bool isInitializing;
  final bool isCameraReady;
  final bool isFlashOn;
  final int selectedCameraIndex;
  final int totalCameras;
  final String? errorMessage;

  bool get canSwitchCamera => totalCameras > 1;

  SolvingCaptureState copyWith({
    bool? isInitializing,
    bool? isCameraReady,
    bool? isFlashOn,
    int? selectedCameraIndex,
    int? totalCameras,
    String? errorMessage,
  }) {
    return SolvingCaptureState(
      isInitializing: isInitializing ?? this.isInitializing,
      isCameraReady: isCameraReady ?? this.isCameraReady,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      selectedCameraIndex: selectedCameraIndex ?? this.selectedCameraIndex,
      totalCameras: totalCameras ?? this.totalCameras,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isInitializing,
        isCameraReady,
        isFlashOn,
        selectedCameraIndex,
        totalCameras,
        errorMessage,
      ];
}

