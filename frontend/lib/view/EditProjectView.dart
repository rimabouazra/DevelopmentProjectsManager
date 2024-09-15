import 'package:flutter/material.dart';
import 'package:frontend/model/Project.dart';
import 'package:frontend/model/User.dart';
import 'package:frontend/provider/DeveloperModel.dart';
import 'package:frontend/provider/ProjectModel.dart';
import 'package:provider/provider.dart';

class EditProjectView extends StatefulWidget {
  final String projectId;

  const EditProjectView({Key? key, required this.projectId}) : super(key: key);

  @override
  _EditProjectViewState createState() => _EditProjectViewState();
}

class _EditProjectViewState extends State<EditProjectView> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  List<User> _developers = [];
   List<User> availableDevelopers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProjectDetails();
    _fetchAvailableDevelopers();
  }

  Future<void> _fetchProjectDetails() async {
    final projectModel = Provider.of<ProjectModel>(context, listen: false);
    final project = projectModel.projects
        .firstWhere((proj) => proj.projectId == widget.projectId);

    setState(() {
      _title = project.title;
      _description = project.description;
      _developers = project.developers;
      isLoading = false;
    });
  }
 Future<void> _fetchAvailableDevelopers() async {
    final developerModel = Provider.of<DeveloperModel>(context, listen: false);
    await developerModel.fetchDevelopers();  
    setState(() {
      availableDevelopers = developerModel.developers;
    });
  }

  Future<void> _updateProject() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    final projectModel = Provider.of<ProjectModel>(context, listen: false);
    Project updatedProject = Project(
      widget.projectId, 
      _title,
      _description,
      [],
      _developers,
    );

    try {
      await projectModel.updateProject(updatedProject);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update project: $e')),
      );
    }
  }
}

   void _toggleDeveloper(User developer) {
    setState(() {
      if (_developers.contains(developer)) {
        _developers.remove(developer);
      } else {
        _developers.add(developer);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Project')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _title,
                      decoration: InputDecoration(labelText: 'Project Title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _title = value!;
                      },
                    ),
                    TextFormField(
                      initialValue: _description,
                      decoration: InputDecoration(labelText: 'Description'),
                      onSaved: (value) {
                        _description = value!;
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Developers',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: availableDevelopers.length,
                        itemBuilder: (context, index) {
                          final developer = availableDevelopers[index];
                          return CheckboxListTile(
                            title: Text(developer.nomUtilisateur),
                            value: _developers.contains(developer),
                            onChanged: (bool? selected) {
                              _toggleDeveloper(developer);
                            },
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _updateProject,
                      child: Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}