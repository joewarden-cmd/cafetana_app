import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageCarousel extends StatelessWidget {
  final List<String> imageUrls;

  const ImageCarousel({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double carouselHeight = screenHeight * 0.20;
    double carouselWidth = screenWidth * 0.9;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        height: carouselHeight,
        width: carouselWidth,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CarouselSlider.builder(
            itemCount: imageUrls.length,
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: screenWidth > 600 ? 2.0 : 1.5,
              enlargeCenterPage: false,
              viewportFraction: 1.0,
            ),
            itemBuilder: (context, index, realIndex) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                    width: carouselWidth,
                    height: carouselHeight,
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      color: Colors.black.withOpacity(0.5),
                      child: const Text(
                        'Popular',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
