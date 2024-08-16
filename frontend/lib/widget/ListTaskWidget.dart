import 'package:flutter/material.dart';
import 'package:frontend/provider/TaskModel.dart';
import 'package:provider/provider.dart';
import 'package:frontend/library/globals.dart' as globals;

class ListTasksWidget extends StatelessWidget {
  const ListTasksWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskModel>(builder: (context, model, child) {
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                              color: Color(0xFF0FB0D4),
                              border: Border.all(
                                color: Color(0xFFE2E2E2),
                              ),
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(model.tasks[key]![index].title),
                            subtitle: Text(
                                model.tasks[key]![index].deadline.toString()),
                            leading: Checkbox(
                              value: model.tasks[key]![index].status,
                              onChanged: (bool? value) {
                                model.markAsDone(key, index);
                                print(model.tasks[key]![index].status);
                              },
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
        },
      );
    });
  }
}
