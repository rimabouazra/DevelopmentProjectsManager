import 'package:flutter/material.dart';
import 'package:frontend/model/Project.dart';
import 'package:frontend/model/Task.dart';
import 'package:frontend/provider/TaskModel.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:frontend/provider/ProjectModel.dart'; 


class AddTasksView extends StatefulWidget {
  final String? projectId;
  const AddTasksView({Key? key, this.projectId}) : super(key: key);

  @override
  State<AddTasksView> createState() => _AddTasksViewState();
}

class _AddTasksViewState extends State<AddTasksView> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptonController = TextEditingController();
  Project? _selectedProject;

  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskModel, ProjectModel>(
      builder: (context, model, projectModel, child) {
      return Scaffold(
      appBar: AppBar(
        title: Text("Add new Task"),
      ),
      body: SingleChildScrollView(
          child: Form(
          key: _formKey,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(children: <Widget>[
            TableCalendar(
              calendarFormat: CalendarFormat.week,
              firstDay: DateTime.utc(2003, 1, 1),
              lastDay: DateTime.utc(2050, 12, 30),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarBuilders: CalendarBuilders(
                 markerBuilder: (context,datetime,events){
                      return model.countTasksByDay(datetime)>0? Container(
                        width: 20,
                        height: 15,
                        decoration: BoxDecoration(
                          color:Colors.primaries[model.countTasksByDay(datetime)% Colors.primaries.length],
                          borderRadius: BorderRadius.circular(4.0)
                        ),
                        child:Center(
                        child: Text(model.countTasksByDay(datetime).toString(),
                        style: TextStyle(color: Colors.white),),
                      )):Container();
                    },
                    selectedBuilder:(context, _datetime, focusedDay){
                      return Container(
                        decoration: BoxDecoration(
                            color:const Color.fromARGB(255, 240, 87, 140),
                            borderRadius: BorderRadius.circular(4.0)
                        ),
                        margin: EdgeInsets.symmetric(vertical: 4.0,horizontal: 10.0),
                        child: Center(
                          child:Text(_datetime.day.toString(),style: TextStyle(color: Colors.white)),
                        ),
                      );
                    }
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: TextFormField(
                  controller: _titleController,
                  maxLength: 100,
                  decoration: InputDecoration(
                      hintText: "Enter Task Title",
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color:Colors.blue,
                          width: 2.0
                        )
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color:Colors.blue,
                          width: 2.0
                        )
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color:Colors.red,
                          width: 2.0
                        )
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color:Colors.red,
                          width: 2.0
                        )
                      ),
                      ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                )),
            Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: TextFormField(
                  controller: _descriptonController,
                  maxLength: 500,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                      hintText: "Enter Task Description (Optional)",
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color:Colors.blue,
                          width: 2.0
                        )
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color:Colors.blue,
                          width: 2.0
                        )
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color:Colors.red,
                          width: 2.0
                        )
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color:Colors.red,
                          width: 2.0
                        )
                      ),
                      ),
                
                )),
                if (widget.projectId == null)
                Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: DropdownButtonFormField<Project>(
                decoration: InputDecoration(
                  labelText: "Select Project",
                  border: OutlineInputBorder(),
                ),
                value: _selectedProject,
                items: projectModel.projects.map((Project project) {
                  return DropdownMenuItem<Project>(
                    value: project,
                    child: Text(project.title),
                  );
                }).toList(),
                onChanged: (Project? newValue) {
                  setState(() {
                    _selectedProject = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a project';
                  }
                  return null;
                },
              ),
            ),

          ])))),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        child: Icon(Icons.add),
        onPressed: () {
          if (_formKey.currentState!.validate() && _selectedProject != null) {
            Task _newTask=Task(null,_titleController.text,_selectedProject!.projectId,false,_descriptonController.text,_focusedDay,[],[]);
            model.add(_newTask);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task saved :)')),
            );
            Navigator.pushReplacementNamed(context, "ListTasks");
          }
        },
      ),
    );}
  );}
   @override
  void dispose() {
    _titleController.dispose();
    _descriptonController.dispose();
    super.dispose();
  }
}
