import 'package:flutter/material.dart';
import 'package:frontend/provider/TaskModel.dart';
import 'package:frontend/view/SubtasksView.dart';
import 'package:provider/provider.dart';
import 'package:frontend/library/globals.dart' as globals;

class ListTasksWidget extends StatelessWidget {
  final String? projectId;

  const ListTasksWidget({Key? key, this.projectId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: Consumer<TaskModel>(
        builder: (context, model, child) {
          // ignore: unused_local_variable
          final filteredTasks = model.tasks[projectId] ?? [];

          return ListView.builder(
            itemCount: model.tasks.length,
            itemBuilder: (BuildContext context, int index) {
              String key = model.tasks.keys.elementAt(index);
              if (model.tasks[key]!.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          globals.taskCategoryNames[key]!,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: model.tasks[key]!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 173, 226, 249),
                                border: Border.all(color: Color(0xFFE2E2E2)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(model.tasks[key]![index].title),
                                subtitle: Text(
                                  'Developers: ${model.tasks[key]![index].developerNames.join(', ')}',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                leading: Checkbox(
                                  value: model.tasks[key]![index].status,
                                  onChanged: (bool? value) {
                                    model.markAsDone(key, index);
                                    print(model.tasks[key]![index].status);
                                  },
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SubtasksView(
                                            task: model.tasks[key]![index]),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.subdirectory_arrow_right),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                );
              }
              return SizedBox
                  .shrink();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: UniqueKey(),
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, 'addTasks');
        },
      ),
    );
  }
}
