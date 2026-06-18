import 'dart:io';

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

/// Opens the profile-photo picker. Lets the customer choose one of the
/// curated avatars or remove their current photo. (Camera/gallery capture is
/// added in the image_picker integration.)
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
      return Padding(
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
            Text('Choose your photo', style: text.titleLarge),
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
                              color: selected ? scheme.primary : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: CircleAvatar(radius: 30, backgroundImage: NetworkImage(url)),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
