import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final items = [
              {'icon': Icons.home, 'label': 'Home'},
              {'icon': Icons.shopping_bag, 'label': 'Trips'},
              {'icon': Iconsax.heart, 'label': 'Favorites'},
              {'icon': Iconsax.message, 'label': 'Blogs'},
              {'icon': Iconsax.user, 'label': 'Pro'},
            ];

            final isSelected = currentIndex == index;

            return GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color.fromARGB(255, 238, 128, 139)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[index]['icon'] as IconData,
                      size: 24,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[index]['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
