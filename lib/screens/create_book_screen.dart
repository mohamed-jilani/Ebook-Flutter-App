import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateBookScreen extends StatefulWidget {
  const CreateBookScreen({super.key});
  @override
  _CreateBookScreenState createState() => _CreateBookScreenState();
}

class _CreateBookScreenState extends State<CreateBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategoryId;
  File? _selectedImage;

  // Liste fictive des catégories
  final List<Map<String, String>> _categories = [
    {'id': '68018fc51f80969f0be18d6c', 'name': 'Science'},
    {'id': '68018fc51f80969f0be18d6d', 'name': 'Histoire'},
    {'id': '68018fc51f80969f0be18d6e', 'name': 'Technologie'},
    {'id': '68018fc51f80969f0be18d6f', 'name': 'Art'},
    {'id': '68018fc51f80969f0be18d70', 'name': 'Musique'},
    {'id': '68018fc51f80969f0be18d71', 'name': 'Cuisine'},
    {'id': '68018fc51f80969f0be18d72', 'name': 'Voyage'},
    {'id': '68018fc51f80969f0be18d73', 'name': 'Fiction'},
    {'id': '68018fc51f80969f0be18d74', 'name': 'Non-fiction'},
    {'id': '68018fc51f80969f0be18d75', 'name': 'Biographie'},
    {'id': '68018fc51f80969f0be18d76', 'name': 'Enfance'},
    {'id': '68018fc51f80969f0be18d77', 'name': 'Poésie'},
    {'id': '68018fc51f80969f0be18d78', 'name': 'Philosophie'},
    {'id': '68018fc51f80969f0be18d79', 'name': 'Psychologie'},
    {'id': '68018fc51f80969f0be18d7a', 'name': 'Sociologie'},
    {'id': '68018fc51f80969f0be18d7b', 'name': 'Économie'},
    {'id': '68018fc51f80969f0be18d7c', 'name': 'Politique'},
    {'id': '68018fc51f80969f0be18d7d', 'name': 'Religion'},
    {'id': '68018fc51f80969f0be18d7e', 'name': 'Santé'},
    {'id': '68018fc51f80969f0be18d7f', 'name': 'Environnement'},
    {'id': '68018fc51f80969f0be18d80', 'name': 'Sport'},
    {'id': '662e6cbd4321efgh', 'name': 'Informatique'},
    {'id': '662e6cbd4321efgh', 'name': 'Littérature'},
  ];

  Future<void> _pickImage() async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission refusée pour accéder à la galerie')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _selectedImage == null ||
        _selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Remplissez tous les champs')));
      return;
    }

    final uri = Uri.parse(
      'http://192.168.1.17:3000/books',
    ); // Remplace par ton backend

    final request = http.MultipartRequest('POST', uri);
    request.fields['title'] = _titleController.text;
    request.fields['description'] = _descriptionController.text;
    request.fields['price'] = _priceController.text;
    request.fields['category'] = _selectedCategoryId!;

    final mimeType = lookupMimeType(_selectedImage!.path)!.split('/');
    request.files.add(
      await http.MultipartFile.fromPath(
        'cover', // doit correspondre au nom attendu dans le backend
        _selectedImage!.path,
        contentType: MediaType(mimeType[0], mimeType[1]),
      ),
    );

    final response = await request.send();
    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Livre créé !')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors de l\'envoi')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Créer un Livre')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Titre'),
                validator: (value) => value!.isEmpty ? 'Entrez un titre' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Prix'),
                validator: (value) => value!.isEmpty ? 'Entrez un prix' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                hint: Text('Choisir une catégorie'),
                items:
                    _categories
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat['id'],
                            child: Text(cat['name']!),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) => setState(() => _selectedCategoryId = value),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text('Choisir une image'),
              ),
              if (_selectedImage != null)
                Image.file(_selectedImage!, height: 150),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Créer le Livre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
