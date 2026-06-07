import 'dart:io';
import 'package:flutter/material.dart';

Widget buildUserImage(
  String photoUrl, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  double iconSize = 40,
  Color fallbackBgColor = const Color(0xFFF1F5F9), // AppColors.cardBg equivalent
  Color fallbackIconColor = const Color(0xFF94A3B8), // AppColors.textLight equivalent
}) {
  if (photoUrl.isEmpty) {
    return Container(
      width: width,
      height: height,
      color: fallbackBgColor,
      child: Icon(Icons.person_rounded, size: iconSize, color: fallbackIconColor),
    );
  }

  if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://') || photoUrl.startsWith('blob:')) {
    return Image.network(
      photoUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: fallbackBgColor,
        child: Icon(Icons.person_rounded, size: iconSize, color: fallbackIconColor),
      ),
    );
  } else {
    try {
      return Image.file(
        File(photoUrl),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: fallbackBgColor,
          child: Icon(Icons.person_rounded, size: iconSize, color: fallbackIconColor),
        ),
      );
    } catch (e) {
      return Container(
        width: width,
        height: height,
        color: fallbackBgColor,
        child: Icon(Icons.person_rounded, size: iconSize, color: fallbackIconColor),
      );
    }
  }
}

ImageProvider getUserImageProvider(String photoUrl) {
  if (photoUrl.isEmpty) {
    return const AssetImage('assets/images/placeholder.png'); // fallback
  }
  if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://') || photoUrl.startsWith('blob:')) {
    return NetworkImage(photoUrl);
  } else {
    try {
      return FileImage(File(photoUrl));
    } catch (e) {
      return const AssetImage('assets/images/placeholder.png');
    }
  }
}
