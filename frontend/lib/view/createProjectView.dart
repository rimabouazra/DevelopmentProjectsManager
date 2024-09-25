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
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<User> _selectedDevelopers = [];
  List<User> managers = [];
  User? _selectedManager;

  @override
  void initState() {
    super.initState();
    _fetchDevelopers();
    _fetchManagers();
  }

  Future<void> _fetchDevelopers() async {
    try {
      await Provider.of<DeveloperModel>(context, listen: false)
          .fetchDevelopers();
      setState(() {});
    } catch (e) {
      print('Failed to fetch developers: $e');
    }
  }
  Future<void> _fetchManagers() async {
  try {
    await Provider.of<DeveloperModel>(context, listen: false).fetchManagers();
    final developerModel = Provider.of<DeveloperModel>(context, listen: false);
    print("Managers fetched: ${developerModel.managers.map((e) => e.nomUtilisateur).toList()}"); // Debugging line
    setState(() {
      managers = developerModel.managers
          .where((user) => user.role == Role.Manager)
          .toList();
    });
  } catch (e) {
    print('Failed to fetch managers: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    final developerModel = Provider.of<DeveloperModel>(context);
    final currentUser = developerModel.user;
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
              ),
              SizedBox(height: 16.0),
              if (currentUser.role == Role.Administrator) ...[
                Text('Select a Manager for the Project'),
                DropdownButtonFormField<User>(
                  value: _selectedManager,
                  items: managers
                      .map((User manager) {
                    return DropdownMenuItem<User>(
                      value: manager,
                      child: Text(manager.nomUtilisateur),
                    );
                  }).toList(),
                  onChanged: (User? newManager) {
                    setState(() {
                      _selectedManager = newManager;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a manager';
                    }
                    return null;
                  },
                ),
              ],
              Expanded(
                child: ListView(
                  children: developerModel.developers.map((developer) {
                    return CheckboxListTile(
                      title: Text(developer.nomUtilisateur),
                      value: _selectedDevelopers.contains(developer),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedDevelopers.add(developer);
                          } else {
                            _selectedDevelopers.remove(developer);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              if (_selectedDevelopers.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Please select at least one developer',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState!.save();
                    final newProject = Project(
                        '',
                        _titleController.text,
                        _descriptionController.text,
                        [],
                        _selectedDevelopers.isNotEmpty
                            ? _selectedDevelopers
                            : [],
                        null);
                    final currentUser =
                        Provider.of<DeveloperModel>(context, listen: false)
                            .user;
                    print("Current user: ${currentUser.toString()}");
                    print(
                        "Can create project: ${currentUser.canCreateProject()}");
                    if (currentUser.canCreateProject()) {
                      try {
                        print("New project title: ${_titleController.text}");
                        print("Selected developers: $_selectedDevelopers");

                        await Provider.of<ProjectModel>(context, listen: false)
                            .addProject(
                                newProject, currentUser, _selectedManager);
                        await Provider.of<ProjectModel>(context, listen: false)
                            .fetchProjects();
                        Navigator.pop(context);
                      } catch (e) {
                        if (e.toString().contains('Failed to create project')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Failed to create project: ${e.toString()}')),
                          );
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'User does not have permission to create projects')),
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
