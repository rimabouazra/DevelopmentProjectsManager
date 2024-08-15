import 'package:flutter/material.dart';
import 'package:frontend/provider/TaskModel.dart';
import 'package:provider/provider.dart';

class ListTasksWidget extends StatelessWidget {
  const ListTasksWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskModel>(builder: (context, model, child) {
      return ListView.builder(
        itemCount: model.tasks.length,
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
              child: CheckboxListTile(
                title: Text(model.tasks[index].title),
                subtitle: Text(model.tasks[index].deadline.toString()),
                value: model.tasks[index].status,
                onChanged: (bool? value) {
                  model.markAsDone(index);
                  print(model.tasks[index].status);
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          );
        },
      );
    }
    );
  }
}
