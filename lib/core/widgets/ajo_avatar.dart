import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AjoAvatar extends StatelessWidget {
  const AjoAvatar({super.key, required this.name, this.avatarUrl, this.radius = 22});

  final String name;
  final String? avatarUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          image: DecorationImage(
            image: NetworkImage(avatarUrl!),
            fit: BoxFit.cover,
            onError: (_, __) {},
          ),
        ),
      );
    }

    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts
        .take(2)
        .map((part) => part.isEmpty ? '' : part[0])
        .join()
        .toUpperCase();

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFD8E8DF), Color(0xFF7DA892)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? 'AF' : initials,
        style: TextStyle(
          color: AppColors.primaryDark,
          fontSize: radius * 0.52,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
