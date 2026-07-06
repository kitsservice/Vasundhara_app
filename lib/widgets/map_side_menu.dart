import 'package:flutter/material.dart';

class MapSideMenu extends StatelessWidget {
  const MapSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 120, // Below search bar
      left: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.mic, color: Colors.black54),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.layers, color: Colors.black54),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black54),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.feedback_outlined, color: Colors.black54),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black54),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
