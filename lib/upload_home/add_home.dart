import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddHomePage extends StatefulWidget {
  @override
  _AddHomePageState createState() => _AddHomePageState();
}

class _AddHomePageState extends State<AddHomePage> {
  String? _houseType;
  int _bedrooms = 1;
  int _bathrooms = 1;
  int _balconies = 0;
  List<File> _images = [];
  double _price = 0; // Default price starts from 0 TK
  final picker = ImagePicker();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _uploading = false;

  // Function to pick multiple images with a limit of 7
  Future<void> _getImages() async {
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      if (_images.length + pickedFiles.length > 7) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You can only upload up to 7 images.')),
        );
        return;
      }
      setState(() {
        _images.addAll(
            pickedFiles.map((pickedFile) => File(pickedFile.path)).toList());
      });
    }
  }

  // Function to upload details including images and description to Firestore
  Future<void> _uploadDetails() async {
    setState(() {
      _uploading = true;
    });

    try {
      List<String> imageUrls = [];
      for (File image in _images) {
        String fileName = image.path.split('/').last;
        Reference ref =
        FirebaseStorage.instance.ref().child('images/$fileName');
        UploadTask uploadTask = ref.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      await FirebaseFirestore.instance.collection('homes').add({
        'houseType': _houseType,
        'bedrooms': _bedrooms,
        'bathrooms': _bathrooms,
        'balconies': _balconies,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'images': imageUrls,
        'price': _price, // Include price in the uploaded details
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Details uploaded successfully!')),
      );

      // Clear form after successful upload
      setState(() {
        _houseType = null;
        _bedrooms = 1;
        _bathrooms = 1;
        _balconies = 0;
        _images.clear();
        _locationController.clear();
        _descriptionController.clear();
        _price = 0; // Reset price to 0 TK
        _uploading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload details: $e')),
      );
      setState(() {
        _uploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Your Home'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown for house type
            DropdownButtonFormField<String>(
              value: _houseType,
              hint: Text('Select House Type'),
              items: ['Family Flat', 'Sub-late Room', 'Bachelor Seat']
                  .map((type) => DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _houseType = value;
                });
              },
            ),
            SizedBox(height: 16.0),

            // Input for location
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),

            // Input for description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16.0),

            // Bedrooms, Bathrooms, Balconies input
            if (_houseType == 'Family Flat' || _houseType == 'Sub-late Room')
              Column(
                children: [
                  _buildCounterRow('Bedrooms', _bedrooms, () {
                    setState(() {
                      if (_bedrooms > 1) _bedrooms--;
                    });
                  }, () {
                    setState(() {
                      _bedrooms++;
                    });
                  }),
                  SizedBox(height: 16.0),
                  _buildCounterRow('Bathrooms', _bathrooms, () {
                    setState(() {
                      if (_bathrooms > 1) _bathrooms--;
                    });
                  }, () {
                    setState(() {
                      _bathrooms++;
                    });
                  }),
                  SizedBox(height: 16.0),
                  _buildCounterRow('Balconies', _balconies, () {
                    setState(() {
                      if (_balconies > 0) _balconies--;
                    });
                  }, () {
                    setState(() {
                      _balconies++;
                    });
                  }),
                ],
              ),
            SizedBox(height: 16.0),

            // Slider for price selection
            Text('Price: ${_price.toStringAsFixed(2)} TK'),
            Container(
              width: double.infinity, // Make the slider full width
              child: Slider(
                value: _price,
                min: 0, // Start from 0 TK
                max: 50000, // Adjust maximum as necessary
                onChanged: (double value) {
                  setState(() {
                    _price = value;
                  });
                },
                divisions: 100, // Increased divisions for more control
                label: '${_price.round()} TK',
              ),
            ),
            SizedBox(height: 16.0),

            // Image picking button
            ElevatedButton(
              onPressed: _getImages,
              child: Text('Add Images'),
            ),
            SizedBox(height: 16.0),

            // Display selected images
            _images.isNotEmpty
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _images
                  .map((image) => Image.file(
                image,
                height: 200,
                fit: BoxFit.cover,
              ))
                  .toList(),
            )
                : Container(),
            SizedBox(height: 16.0),

            // Upload button
            ElevatedButton(
              onPressed: _uploadDetails,
              child: _uploading
                  ? CircularProgressIndicator()
                  : Text('Upload Details'),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable widget for bedroom, bathroom, and balcony counters
  Widget _buildCounterRow(String label, int count, VoidCallback onDecrement,
      VoidCallback onIncrement) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label: $count'),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: onDecrement,
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: onIncrement,
            ),
          ],
        ),
      ],
    );
  }
}
