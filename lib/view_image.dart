import 'dart:io';

import 'package:flutter/material.dart';

class ViewImage extends StatelessWidget {
  const ViewImage({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Image'),
      ),
      body: Center(
        child: Image.file(
          File(imageUrl),
        ),
      ),
    );
  }
}
