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
  double _price = 0;
  final picker = ImagePicker();
  String? _selectedLocation;
  final TextEditingController _descriptionController = TextEditingController();
  bool _uploading = false;

  final List<String> _locations = [
    'Abdullahpur', 'Adabor', 'Agargaon', 'Airport', 'Banani',
    'Bashabo', 'Bashundhara R/A', 'Badda', 'Cantonment', 'Dhanmondi',
    'ECB', 'Farmgate', 'Gulshan-1', 'Gulshan-2', 'Hazaribagh', 'Jatrabari',
    'Kafrul', 'Khilgaon', 'Khilkhet', 'Kotoali','Lalbag', 'Mirpur',
    'Mohakhali', 'Mohammadpur', 'Mohanagar Project', 'Modhubag', 'Motijheel',
    'Nikunja', 'Niketon', 'Paltan', 'Rajabazar', 'Ramna',
    'Sadarghat', 'Shabujbagh', 'Shyamoli', 'Tejgaon', 'Tikatuli',
    'Uttara', 'Uttara East', 'Uttara West', 'Wari', 'West Dhanmondi',

  ];

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
          pickedFiles.map((pickedFile) => File(pickedFile.path)).toList(),
        );
      });
    }
  }

  Future<void> _uploadDetails() async {
    setState(() {
      _uploading = true;
    });

    try {
      List<String> imageUrls = [];
      for (File image in _images) {
        String fileName = image.path.split('/').last;
        Reference ref = FirebaseStorage.instance.ref().child('images/$fileName');
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
        'location': _selectedLocation,
        'description': _descriptionController.text,
        'images': imageUrls,
        'price': _price,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Details uploaded successfully!')),
      );

      setState(() {
        _houseType = null;
        _bedrooms = 1;
        _bathrooms = 1;
        _balconies = 0;
        _images.clear();
        _selectedLocation = null;
        _descriptionController.clear();
        _price = 0;
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
        title: Text('Add Your Home', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown for house type
            _buildSectionTitle('House Type'),
            _buildDropdownButton(
              _houseType,
              'Select House Type',
              ['Family Flat', 'Sub-late Room', 'Bachelor Seat'],
                  (value) {
                setState(() {
                  _houseType = value;
                });
              },
            ),
            SizedBox(height: 20.0),

            // Dropdown for location selection
            _buildSectionTitle('Location'),
            _buildDropdownButton(
              _selectedLocation,
              'Select Location',
              _locations,
                  (value) {
                setState(() {
                  _selectedLocation = value;
                });
              },
            ),
            SizedBox(height: 20.0),

            // Input for description
            _buildSectionTitle('Description'),
            _buildDescriptionInput(),
            SizedBox(height: 20.0),

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
                  SizedBox(height: 20.0),
                  _buildCounterRow('Bathrooms', _bathrooms, () {
                    setState(() {
                      if (_bathrooms > 1) _bathrooms--;
                    });
                  }, () {
                    setState(() {
                      _bathrooms++;
                    });
                  }),
                  SizedBox(height: 20.0),
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
            SizedBox(height: 20.0),

            // Slider for price selection
            _buildSectionTitle('Price'),
            Text(
              'Price: ${_price.toStringAsFixed(2)} TK',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Slider(
              value: _price,
              min: 0,
              max: 50000,
              onChanged: (double value) {
                setState(() {
                  _price = value;
                });
              },
              divisions: 100,
              activeColor: Colors.indigo,
              inactiveColor: Colors.indigo[100],
              label: '${_price.round()} TK',
            ),
            SizedBox(height: 20.0),

            // Image picking button
            ElevatedButton.icon(
              onPressed: _getImages,
              icon: Icon(Icons.add_a_photo),
              label: Text('Add Images'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: 20.0),

            // Display selected images
            _images.isNotEmpty
                ? Column(
              children: _images
                  .map((image) => Container(
                margin: EdgeInsets.only(bottom: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ))
                  .toList(),
            )
                : Container(),
            SizedBox(height: 20.0),

            // Upload button
            ElevatedButton(
              onPressed: _uploadDetails,
              child: _uploading
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : Text('Upload Details'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.indigo,
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: Colors.indigo,
      ),
    );
  }

  Widget _buildDropdownButton(String? value, String hint, List<String> items,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      ),
      hint: Text(hint),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDescriptionInput() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
       // labelText: 'Description',
        alignLabelWithHint: true,
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
      ),
      maxLines: 5,
    );
  }

  Widget _buildCounterRow(
      String label,
      int value,
      VoidCallback onDecrement,
      VoidCallback onIncrement,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            IconButton(
              onPressed: onDecrement,
              icon: Icon(Icons.remove_circle_outline),
              color: Colors.indigo,
            ),
            Text(
              value.toString(),
              style: TextStyle(fontSize: 16.0),
            ),
            IconButton(
              onPressed: onIncrement,
              icon: Icon(Icons.add_circle_outline),
              color: Colors.indigo,
            ),
          ],
        ),
      ],
    );
  }
}
