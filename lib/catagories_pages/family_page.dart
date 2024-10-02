import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_home/home_pages/home_details_page.dart';
import 'package:flutter/material.dart';

class FamilyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Houses')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('homes')
            .where('houseType', isEqualTo: 'Family Flat')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No family houses available.'));
          }

          final familyHomes = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Show 2 houses in a row
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2 / 3,
            ),
            itemCount: familyHomes.length,
            itemBuilder: (context, index) {
              final homeData = familyHomes[index].data() as Map<String, dynamic>;
              final images = homeData['images'] as List<dynamic>;
              final imageUrl = images.isNotEmpty ? images[0] : '';
              final location = homeData['location'] ?? 'No location';
              final description = homeData['description'] ?? 'No description';

              // Ensure the price and other fields are properly cast to int
              final price = (homeData['price'] is int)
                  ? homeData['price']
                  : (homeData['price'] as double?)?.toInt() ?? 0;
              final bedrooms = (homeData['bedrooms'] is int)
                  ? homeData['bedrooms']
                  : (homeData['bedrooms'] as double?)?.toInt() ?? 0;
              final bathrooms = (homeData['bathrooms'] is int)
                  ? homeData['bathrooms']
                  : (homeData['bathrooms'] as double?)?.toInt() ?? 0;
              final balconies = (homeData['balconies'] is int)
                  ? homeData['balconies']
                  : (homeData['balconies'] as double?)?.toInt() ?? 0;

              return GestureDetector(
                onTap: () {
                  // Navigate to DetailsPage, passing home details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsPage(
                        imagePath: imageUrl,
                        name: 'Family House',
                        location: location,
                        bedrooms: bedrooms,
                        bathrooms: bathrooms,
                        balconies: balconies,
                        description: description,
                        price: price,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image section
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: imageUrl.isNotEmpty
                            ? Image.network(imageUrl,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover)
                            : Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.grey,
                          child: const Icon(Icons.image, color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$price TK',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
