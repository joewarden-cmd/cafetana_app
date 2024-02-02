import 'package:flutter/material.dart';
import 'package:flutter_food_ordering/pages/cart/cart.dart';
import 'package:flutter_food_ordering/pages/home/home.dart';
import 'package:flutter_food_ordering/pages/profile/profile.dart';

class NavigationWidget extends StatefulWidget {
  const NavigationWidget({super.key});

  @override
  State<NavigationWidget> createState() => _NavState();
}

class _NavState extends State<NavigationWidget> {

  int selectedNavIcon = 0;

  List<Widget> pageList = [
    HomePage(),
    const CartPage(),
    const ProfilePage()
  ];

  void bottomNavTap(int value) {
    setState(() {
      selectedNavIcon = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageList[selectedNavIcon],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: selectedNavIcon,
          onTap: bottomNavTap,
      ),
    );
  }
}