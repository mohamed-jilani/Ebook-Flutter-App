import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mime/mime.dart';
import '../../models/book.dart';
import '../../models/category.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;

  const EditBookScreen({Key? key, required this.book}) : super(key: key);

  @override
  _EditBookScreenState createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _authorController;
  String? _selectedCategoryId;
  File? _newImage;
  List<Categorie> _categories = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _descriptionController = TextEditingController(
      text: widget.book.description,
    );
    _priceController = TextEditingController(
      text: widget.book.price.toString(),
    );
    _authorController = TextEditingController(text: widget.book.author);

    // Récupérer les catégories depuis l'API
    fetchCategories();

    // Pré-sélectionner la catégorie du livre actuel
    _selectedCategoryId = widget.book.categoryId;
  }

  Future<void> fetchCategories() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.17:3000/categories'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _categories = data.map((json) => Categorie.fromJson(json)).toList();
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newImage = File(picked.path);
      });
    }
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final uri = Uri.parse('http://192.168.1.17:3000/books/${widget.book.id}');
    final request = http.MultipartRequest('PUT', uri);

    request.fields['title'] = _titleController.text;
    request.fields['description'] = _descriptionController.text;
    request.fields['price'] = _priceController.text;
    request.fields['author'] = _authorController.text;
    request.fields['category'] = _selectedCategoryId ?? '';

    if (_newImage != null) {
      final mimeType = lookupMimeType(_newImage!.path)!.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'cover',
          _newImage!.path,
          contentType: MediaType(mimeType[0], mimeType[1]),
        ),
      );
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Livre modifié avec succès')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors de la mise à jour')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modifier le Livre')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Titre
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Titre'),
                validator: (value) => value!.isEmpty ? 'Entrez un titre' : null,
              ),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              // Prix
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Prix'),
                validator: (value) => value!.isEmpty ? 'Entrez un prix' : null,
              ),
              // Auteur
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(labelText: 'Auteur'),
                validator:
                    (value) => value!.isEmpty ? 'Entrez un auteur' : null,
              ),
              // Dropdown pour la catégorie
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                hint: Text('Choisir une catégorie'),
                items:
                    _categories
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) => setState(() => _selectedCategoryId = value),
              ),
              SizedBox(height: 10),
              // Bouton pour changer l'image
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text('Changer l’image'),
              ),
              SizedBox(height: 10),
              // Affichage de l'image
              _newImage != null
                  ? Container(
                    height: 200,
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _newImage!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                  : widget.book.imageUrl != null &&
                      widget.book.imageUrl!.isNotEmpty
                  ? Container(
                    height: 200,
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: widget.book.imageUrl!,
                        height: 200,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              color: Colors.grey[200],
                              child: Center(child: CircularProgressIndicator()),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: Icon(Icons.broken_image, size: 50),
                            ),
                      ),
                    ),
                  )
                  : Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Center(
                      child: Text(
                        'Aucune image disponible',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
              SizedBox(height: 20),
              // Bouton pour soumettre la mise à jour
              ElevatedButton(
                onPressed: _submitUpdate,
                child: Text('Mettre à jour le livre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
