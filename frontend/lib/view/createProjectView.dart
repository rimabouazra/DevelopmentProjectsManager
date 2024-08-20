import 'package:flutter/material.dart';
import 'package:frontend/model/Project.dart';
import 'package:provider/provider.dart';
import '../provider/ProjectModel.dart';
import '../provider/DeveloperModel.dart';
import '../model/User.dart';

class CreateProjectView extends StatefulWidget {
  const CreateProjectView({Key? key}) : super(key: key);

  @override
  State<CreateProjectView> createState() => _CreateProjectViewState();
}

class _CreateProjectViewState extends State<CreateProjectView> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<User> _selectedDevelopers = [];

  @override
  Widget build(BuildContext context) {
    final developerModel = Provider.of<DeveloperModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(labelText: 'Project ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project description';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<User>(
                value: _selectedDevelopers.isNotEmpty
                    ? _selectedDevelopers.first
                    : null,
                decoration: InputDecoration(labelText: 'Select Developers'),
                items: developerModel.getDevelopers().map((developer) {
                  return DropdownMenuItem<User>(
                    value: developer,
                    child: Text(developer.nomUtilisateur),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    if (value != null && !_selectedDevelopers.contains(value)) {
                      _selectedDevelopers.add(value);
                    }
                  });
                },
                validator: (value) {
                  if (_selectedDevelopers.isEmpty) {
                    return 'Please select at least one developer';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState!.save();
                    final newProject = Project(
                      _idController.text,
                      _titleController.text,
                      _descriptionController.text,
                      [],
                      _selectedDevelopers,
                    );
                    final currentUser =
                        Provider.of<User>(context, listen: false).currentUser;
                    try {
                      Provider.of<ProjectModel>(context, listen: false)
                          .addProject(newProject, currentUser!);
                      Navigator.pop(context);
                    } catch (e) {
                      // Handle the exception if the user does not have permission
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  }
                },
                child: Text('Create Project'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
