import 'package:find_home/favourites_page/favourites_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class DetailsPage extends StatelessWidget {
  final String imagePath;
  final String name;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final int balconies;
  final String description;
  final int price; // Change to int


  DetailsPage({
    required this.imagePath,
    required this.name,
    required this.bedrooms,
    required this.bathrooms,
    required this.balconies,
    required this.description,
    required this.location,
    required this.price, // Include price here

  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Handle sharing functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header Section
            Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              child: Image.network(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),

            // Property Title and Location
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    location,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      _buildIconInfo(context, Icons.bed, '$bedrooms Beds'),
                      SizedBox(width: 16),
                      _buildIconInfo(context, Icons.bathtub, '$bathrooms Baths'),
                      SizedBox(width: 16),
                      _buildIconInfo(context, Icons.balcony, '$balconies Balconies'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Price Information Section
            _buildInfoSection(context, 'Price Information', [
              _buildInfoRow(context, 'Price', price == 0 ? 'Negotiable' : '$price TK'),
              _buildInfoRow(context, 'Price For', 'Monthly'),
            ]),

            // Basic Information Section
            _buildInfoSection(context, 'Basic Information', [

              _buildInfoRow(context, 'Category', name), // Dynamic house type/category
            ]),

            // Details Section
            _buildInfoSection(context, 'Details', [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  description,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ]),

            // Add to Favourites Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    FavouriteItem item = FavouriteItem(
                      imagePath: imagePath,
                      name: name,
                      location: location,
                      bedrooms: bedrooms,
                      bathrooms: bathrooms,
                      balconies: balconies,
                      price: price,
                    );
                    Provider.of<FavouritesProvider>(context, listen: false)
                        .addFavourite(item);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$name added to favourites')),
                    );
                  },
                  child: Text('Add to Favourites'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconInfo(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isLocked = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          isLocked
              ? Row(
            children: [
              Icon(Icons.lock, size: 16, color: Colors.red),
              SizedBox(width: 4),
              Text(value, style: TextStyle(color: Colors.red)),
            ],
          )
              : Text(value, style: TextStyle(fontSize: 16, color: Colors.grey[800])),
        ],
      ),
    );
  }
}
