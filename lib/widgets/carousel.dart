import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageCarousel extends StatelessWidget {
  final List<String> imageUrls;

  ImageCarousel({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Calculate dynamic width and height based on the screen size
    double carouselHeight = screenHeight * 0.15; // 15% of the screen height
    double carouselWidth = screenWidth * 0.9; // 90% of the screen width

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        height: carouselHeight,
        width: carouselWidth,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CarouselSlider.builder(
            itemCount: imageUrls.length,
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: screenWidth > 600 ? 2.0 : 1.5, // Adjust aspect ratio for different screen sizes
              enlargeCenterPage: true,
            ),
            itemBuilder: (context, index, realIndex) {
              return Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                width: carouselWidth,
                height: carouselHeight,
              );
            },
          ),
        ),
      ),
    );
  }
}
