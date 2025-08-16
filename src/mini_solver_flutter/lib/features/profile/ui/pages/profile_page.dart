import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mini_solver_flutter/generated/colors.gen.dart';
import 'package:mini_solver_flutter/widgets/buttons/app_buttons.dart';

import '../../../../di.dart';
import '../../../auth/services/user_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Center(
        child: AlertDialog(
          title: Text('profile.logout_title'.tr()),
          content: Text('profile.logout_message'.tr()),
          actions: [
            AppBorderButton(onPressed: () => Navigator.of(context).pop(false), label: 'common.cancel'.tr()),
            AppPrimaryButton(onPressed: () => Navigator.of(context).pop(true), label: 'common.confirm'.tr()),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      await getIt<UserService>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userService = getIt<UserService>();
    return Scaffold(
      appBar: AppBar(title: Text('profile.title'.tr()), backgroundColor: ColorName.background, centerTitle: false),
      body: ValueListenableBuilder(
        valueListenable: userService.userNotifier,
        builder: (context, user, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('profile.name'.tr()),
                  subtitle: Text(user?.name ?? '-'),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('profile.email'.tr()),
                  subtitle: Text(user?.email ?? '-'),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('profile.user_id'.tr()),
                  subtitle: Text(user?.id ?? '-'),
                ),
                const SizedBox(height: 24),
                SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: AppBorderButton(onPressed: () => _confirmLogout(context), label: 'profile.logout'.tr()),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
