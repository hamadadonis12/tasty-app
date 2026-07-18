import 'dart:io';

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../state/app_state.dart';

/// Avatar shown wherever the profile photo appears. Prefers a locally picked
/// photo (file), then a chosen/curated network avatar.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.radius = 36});
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        final ImageProvider image = s.avatarFilePath != null
            ? FileImage(File(s.avatarFilePath!))
            : NetworkImage(s.avatarUrl) as ImageProvider;
        return CircleAvatar(radius: radius, backgroundImage: image);
      },
    );
  }
}

final ImagePicker _imagePicker = ImagePicker();

/// Pick a photo from the camera or gallery and set it as the avatar.
///
/// Pops [sheetCtx] (the picker sheet) first so the result snackbar shows over
/// the profile screen. Errors (cancelled, permission denied) surface a
/// snackbar rather than crashing.
Future<void> _pickPhoto(BuildContext sheetCtx, ImageSource source) async {
  HapticFeedback.selectionClick();
  final messenger = ScaffoldMessenger.of(sheetCtx);
  try {
    final XFile? file = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null) return; // user cancelled
    AppState.instance.setAvatarFile(file.path);
    if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
    messenger.showSnackBar(const SnackBar(
      content: Text('Profile photo updated'),
      behavior: SnackBarBehavior.floating,
    ));
  } catch (_) {
    messenger.showSnackBar(SnackBar(
      content: Text(source == ImageSource.camera
          ? "Couldn't open the camera. Check app permissions."
          : "Couldn't open your photos. Check app permissions."),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

/// Opens the profile-photo picker. Lets the customer take a photo, choose one
/// from their gallery, pick a curated avatar, or remove their current photo.
Future<void> showProfilePhotoPicker(BuildContext context) async {
  HapticFeedback.lightImpact();
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(TastyRadii.xxl)),
    ),
    builder: (sheetCtx) {
      final scheme = Theme.of(sheetCtx).colorScheme;
      final text = Theme.of(sheetCtx).textTheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TastySpacing.marginPage,
            TastySpacing.stackMd,
            TastySpacing.marginPage,
            TastySpacing.sectionGap,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: TastyRadii.fullRadius,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text('Change your photo', style: text.titleLarge),
              const SizedBox(height: TastySpacing.stackMd),

              // ── Upload from the phone ──
              Row(
                children: [
                  Expanded(
                    child: _PhotoSourceButton(
                      icon: Icons.photo_camera_outlined,
                      label: 'Take photo',
                      onTap: () => _pickPhoto(sheetCtx, ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: TastySpacing.stackMd),
                  Expanded(
                    child: _PhotoSourceButton(
                      icon: Icons.photo_library_outlined,
                      label: 'Choose from gallery',
                      onTap: () => _pickPhoto(sheetCtx, ImageSource.gallery),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: TastySpacing.sectionGap),
              Text('Or pick an avatar',
                  style: text.labelLarge
                      ?.copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: TastySpacing.stackMd),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final url in AppState.avatarChoices)
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        AppState.instance.setAvatarUrl(url);
                        Navigator.of(sheetCtx).pop();
                      },
                      child: ListenableBuilder(
                        listenable: AppState.instance,
                        builder: (context, _) {
                          final selected = AppState.instance.avatarUrl == url &&
                              AppState.instance.avatarFilePath == null;
                          return Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? scheme.primary
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: CircleAvatar(
                                radius: 30, backgroundImage: NetworkImage(url)),
                          );
                        },
                      ),
                    ),
                ],
              ),

              // ── Remove a locally uploaded photo ──
              ListenableBuilder(
                listenable: AppState.instance,
                builder: (context, _) {
                  if (AppState.instance.avatarFilePath == null) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: TastySpacing.stackSm),
                    child: TextButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        AppState.instance
                            .setAvatarUrl(AppState.avatarChoices.first);
                        Navigator.of(sheetCtx).pop();
                      },
                      icon: Icon(Icons.delete_outline, color: scheme.error),
                      label: Text('Remove photo',
                          style: TextStyle(color: scheme.error)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PhotoSourceButton extends StatelessWidget {
  const _PhotoSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: TastyRadii.lgRadius,
      child: InkWell(
        borderRadius: TastyRadii.lgRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: scheme.primary, size: 26),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: text.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
