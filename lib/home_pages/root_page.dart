import 'package:find_home/app_drawer/drawer_menu.dart';
import 'package:find_home/catagories_pages/category_page.dart';
import 'package:find_home/favourites_page/favourites.dart';
import 'package:find_home/home_pages/home_page.dart';
import 'package:find_home/profile_pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _selectedIndex = 0; // Index of the currently selected tab
  final PageController _pageController = PageController(); // PageController for PageView

  // GlobalKey for accessing Scaffold state
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List of page widgets
  static final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    FavouritesPage(),
    CategoryPage(),
    ProfilePage(),
  ];

  // Method to handle tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose PageController to free up resources
    super.dispose();
  }

  // Method to build the AppBar
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(80.0), // Adjust the height as needed
      child: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Padding(
          padding: EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0), // Adjust padding as needed
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  _scaffoldKey.currentState!.openDrawer(); // Access ScaffoldState to open drawer
                },
                iconSize: 30,
              ),
              Image.asset(
                'assets/images/img.png', // Replace with your logo image path
                height: 60.0, // Adjust the height as needed
                fit: BoxFit.contain,
              ),
              Icon(
                Icons.notifications,
                color: Colors.black,
                size: 30.0,
              ),
            ],
          ),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to Scaffold
      appBar: _selectedIndex == 0 ? _buildAppBar() : null, // Conditionally show AppBar
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(), // Prevent swiping between pages
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _widgetOptions,
      ),
      drawer: const DrawerMenu(), // Use the DrawerMenu widget here
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                gap: 8,
                activeColor: Colors.cyan[500],
                iconSize: 26,
                padding: EdgeInsets.all(20),
                tabBackgroundColor: Colors.cyan[50]!,
                color: Colors.black,
                selectedIndex: _selectedIndex,
                onTabChange: _onItemTapped,
                tabs: const [
                  GButton(
                    icon: Icons.home,
                    text: 'Home',
                  ),
                  GButton(
                    icon: Icons.favorite_border_outlined,
                    text: 'Favourites',
                  ),
                  GButton(
                    icon: Icons.category,
                    text: 'Category',
                  ),
                  GButton(
                    icon: Icons.person,
                    text: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
