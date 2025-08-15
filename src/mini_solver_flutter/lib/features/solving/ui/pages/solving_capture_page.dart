import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/solving_capture_cubit/solving_capture_cubit.dart';
import '../../cubits/solving_capture_cubit/solving_capture_state.dart';

class SolvingCapturePage extends StatefulWidget {
  const SolvingCapturePage({super.key});

  @override
  State<SolvingCapturePage> createState() => _SolvingCapturePageState();
}

class _SolvingCapturePageState extends State<SolvingCapturePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SolvingCaptureCubit()..init(),
      child: Builder(
        builder: (context) {
          return BlocBuilder<SolvingCaptureCubit, SolvingCaptureState>(
            builder: (context, state) {
              final cubit = context.read<SolvingCaptureCubit>();
              final controller = cubit.controller;

              Widget content;
              if (state.isInitializing) {
                content = const Center(child: CircularProgressIndicator());
              } else if (!state.isCameraReady || controller == null || !controller.value.isInitialized) {
                content = const Center(child: Text('Camera not available'));
              } else {
                content = CameraPreview(controller);
              }

              Future<void> _handleFile(File? file) async {
                if (!context.mounted || file == null) return;
                Navigator.of(context).pop<File?>(file);
              }

              return Scaffold(
                backgroundColor: Colors.black,
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    content,
                    // Top controls
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: cubit.toggleFlash,
                              icon: Icon(
                                state.isFlashOn ? Icons.flash_on : Icons.flash_off,
                                color: Colors.white,
                              ),
                              tooltip: 'Flash',
                            ),
                            IconButton(
                              onPressed: state.canSwitchCamera ? cubit.switchCamera : null,
                              icon: const Icon(Icons.cameraswitch, color: Colors.white),
                              tooltip: 'Switch Camera',
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom controls
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0, left: 24.0, right: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Pick from gallery
                              _RoundButton(
                                onPressed: () async {
                                  final File? file = await cubit.pickFromGallery();
                                  await _handleFile(file);
                                },
                                child: const Icon(Icons.photo, color: Colors.white),
                              ),
                              // Capture button
                              GestureDetector(
                                onTap: () async {
                                  final File? file = await cubit.captureImage();
                                  await _handleFile(file);
                                },
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 4),
                                  ),
                                ),
                              ),
                              // Placeholder to balance row
                              const SizedBox(width: 56, height: 56),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.onPressed, required this.child});
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      radius: 28,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}
