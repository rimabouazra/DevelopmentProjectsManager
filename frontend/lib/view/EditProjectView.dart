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
  String _title = '';
  String _description = '';
  List<User> _developers = [];
  List<User> availableDevelopers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _fetchProjectDetails();
    await _fetchAvailableDevelopers();
  }

  Future<void> _fetchProjectDetails() async {
    final projectModel = Provider.of<ProjectModel>(context, listen: false);

    // Correction : utilisation de orElse pour éviter le crash
    final project = projectModel.projects.cast<Project?>().firstWhere(
      (proj) => proj?.projectId == widget.projectId,
      orElse: () => null,
    );

    if (project == null) {
      setState(() {
        errorMessage = 'Projet introuvable. Il a peut-être été supprimé.';
        isLoading = false;
      });
      return;
    }

    setState(() {
      _title = project.title;
      _description = project.description;
      _developers = List<User>.from(project.developers);
      isLoading = false;
    });
  }

  Future<void> _fetchAvailableDevelopers() async {
    final developerModel = Provider.of<DeveloperModel>(context, listen: false);
    try {
      await developerModel.fetchDevelopers();
      if (mounted) {
        setState(() {
          availableDevelopers = developerModel.developers;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de charger les développeurs')),
        );
      }
    }
  }

  Future<void> _updateProject() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState!.save();

    final projectModel = Provider.of<ProjectModel>(context, listen: false);
    final updatedProject = Project(
      widget.projectId,
      _title,
      _description,
      [],
      _developers,
      null,
    );

    try {
      await projectModel.updateProject(updatedProject);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Projet mis à jour avec succès')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
      );
    }
  }

  void _toggleDeveloper(User developer) {
    setState(() {
      if (_developers.any((d) => d.idUtilisateur == developer.idUtilisateur)) {
        _developers.removeWhere((d) => d.idUtilisateur == developer.idUtilisateur);
      } else {
        _developers.add(developer);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Modifier le projet')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Retour'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le projet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Titre du projet',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  if (value.length > 200) {
                    return 'Le titre ne peut pas dépasser 200 caractères';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!.trim();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) {
                  _description = value?.trim() ?? '';
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Développeurs assignés',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: availableDevelopers.isEmpty
                    ? const Center(child: Text('Aucun développeur disponible'))
                    : ListView.builder(
                        itemCount: availableDevelopers.length,
                        itemBuilder: (context, index) {
                          final developer = availableDevelopers[index];
                          final isSelected = _developers.any(
                            (d) => d.idUtilisateur == developer.idUtilisateur,
                          );
                          return CheckboxListTile(
                            title: Text(developer.nomUtilisateur),
                            subtitle: Text(developer.email),
                            value: isSelected,
                            onChanged: (_) => _toggleDeveloper(developer),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _updateProject,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer les modifications'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}