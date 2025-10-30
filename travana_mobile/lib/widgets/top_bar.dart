import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;

  const TopBar({super.key, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ), // vertical-ийг өгсөн
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'images/topbar_logo.png',
                    width: 150,
                    height: 174,
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              InkWell(
                onTap: onNotificationTap,
                borderRadius: BorderRadius.circular(20),
                child: const Icon(
                  Iconsax.notification,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100); // өндөр багасгасан
}
