import 'package:find_home/catagories_pages/other_pages.dart';
import 'package:find_home/catagories_pages/sublet_page.dart';
import 'package:flutter/material.dart';
import 'package:find_home/catagories_pages/bachelor_page.dart'; // BachelorsPage
import 'package:find_home/catagories_pages/family_page.dart'; // FamilyPage
import 'package:find_home/catagories_pages/helping_hand/helping_hand_page.dart'; // MaidPage

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final List<Map<String, dynamic>> options = [
    {'icon': Icons.family_restroom, 'label': 'Family', 'route': FamilyPage()},
    {'icon': Icons.person, 'label': 'Bachelors', 'route': BachelorsPage()},
    {'icon': Icons.house_siding, 'label': 'Sublets', 'route': SubletPage()},
    {'icon': Icons.cleaning_services, 'label': 'Maid', 'route': MaidPage()},
    {'icon': Icons.miscellaneous_services, 'label': 'Others', 'route': OtherPage()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.cyan[50],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.cyan.shade100,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Adjusted logo space
            SizedBox(height: 100.0),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 columns
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return OptionCard(
                    icon: options[index]['icon'],
                    label: options[index]['label'],
                    route: options[index]['route'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget route;

  const OptionCard({required this.icon, required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => route),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.cyan, // Button color cyan
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          height: 100,
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CategoryPage(),
  ));
}
