import 'package:flutter/material.dart';
import 'package:sqldatabse_learn/sql_database_learn/models/task.dart';
import 'package:sqldatabse_learn/sql_database_learn/product/utils/colors.dart';
import 'package:sqldatabse_learn/sql_database_learn/product/utils/strings.dart';
import 'package:sqldatabse_learn/sql_database_learn/view_model/home_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'home_partof.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends HomeViewModel<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _addTaskButton(),
      appBar: const _PartofAppBar(),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Column(
      children: [
        _searchBar(),
        Expanded(
          child: _tasksList(),
        ),
      ],
    );
  }

  //Search Bar
  Widget _searchBar() {
    return Container(
      margin: const _WidgetPadding.margin(),
      padding: const _WidgetPadding.symetric(),
      decoration: _searchDecoration(),
      child: TextFormField(
        controller: keyword,
        onChanged: (value) {
          setState(() {
            notes = search(value);
          });
        },
        decoration: _searchTextFormFiledDecoration(),
      ),
    );
  }

  // Add Task
  Widget _addTaskButton() {
    return FloatingActionButton(
      backgroundColor: ProjectColors.amberShade(),
      onPressed: () {
        _showTaskDialog(null, null);
      },
      child: Icon(
        Icons.add,
        color: ProjectColors.whiteColor(),
      ),
    );
  }

  //Task List
  Widget _tasksList() {
    var d = AppLocalizations.of(context);
    return Padding(
      padding: const _WidgetPadding.all(),
      child: FutureBuilder<List<Task>>(
        future: notes,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(d!.noTask));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                Task task = snapshot.data![index];
                return Card(
                  elevation: _WidgetSize().cardElevation,
                  shadowColor: Theme.of(context).colorScheme.primary,
                  color:
                      task.status == _WidgetSize().taskStatus ? ProjectColors.grenShade() : ProjectColors.whiteColor(),
                  child: ListTile(
                    iconColor: Colors.indigo,
                    title: _richText(task),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _editText(task),
                        _checkBox(task),
                      ],
                    ),
                    onLongPress: () {
                      _deleteText(context, task);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  //Delete Task
  Future<dynamic> _deleteText(BuildContext context, Task task) {
    var d = AppLocalizations.of(context);
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(d!.deleteWaring),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(d.cancelButtonText)),
          MaterialButton(
            color: ProjectColors.blueShade200(),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_WidgetSize().buttonRadius)),
            onPressed: () {
              databaseService.deleteTask(task.id);
              Navigator.pop(context);
              setState(() {
                notes = databaseService.getTasks();
              });
            },
            child: Text(d.deleteButton),
          ),
        ],
      ),
    );
  }

  Checkbox _checkBox(Task task) {
    return Checkbox(
      value: task.status == _WidgetSize().taskStatus,
      onChanged: (value) {
        databaseService.updateTaskStatus(
          task.id,
          value == true ? _WidgetSize().checkBoxCheck1 : _WidgetSize().checkBoxCheck2,
        );
        setState(() {
          notes = databaseService.getTasks();
        });
      },
    );
  }

  // Edit task dialog
  IconButton _editText(Task task) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        _showTaskDialog(task.id, task.content);
      },
    );
  }

  RichText _richText(Task task) {
    return RichText(
      text: TextSpan(
        text: task.content,
        style: TextStyle(
          color: Colors.black,
          fontSize: _WidgetSize().richTextFontSize,
          decoration: task.status == _WidgetSize().taskStatus ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
    );
  }

  void _showTaskDialog(int? taskId, String? initialContent) {
    var d = AppLocalizations.of(context);
    final TextEditingController controller = TextEditingController(text: initialContent);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(taskId == null ? d!.addTaskText : d!.editTextWaring),
        content: TextField(
          minLines: 1,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          controller: controller,
          onChanged: (value) {
            setState(() {
              notes = databaseService.getTasks(); // Refresh tasks
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_WidgetSize().buttonRadius),
            ),
            hintText: d.writeText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(d.cancelButtonText),
          ),
          MaterialButton(
            color: ProjectColors.blueShade200(),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_WidgetSize().buttonRadius)),
            onPressed: () {
              if (controller.text.isEmpty) return;
              if (taskId == null) {
                databaseService.addTask(controller.text);
              } else {
                databaseService.updateTaskContent(taskId, controller.text);
              }
              setState(() {
                notes = databaseService.getTasks(); // Refresh tasks
              });
              Navigator.pop(context);
            },
            child: Text(d.saveButtonText),
          ),
        ],
      ),
    );
  }

  InputDecoration _searchTextFormFiledDecoration() {
    var d = AppLocalizations.of(context);
    return InputDecoration(
      hintText: d!.searchText,
      icon: const Icon(Icons.search),
      border: InputBorder.none,
    );
  }

  BoxDecoration _searchDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(_WidgetSize().searchDecorationRadius),
      color: ProjectColors.whiteColor(),
      boxShadow: [
        BoxShadow(
          spreadRadius: _WidgetSize().spreadRadius,
          blurRadius: _WidgetSize().blurRadius,
          color: Colors.grey.withOpacity(_WidgetSize().boxShadowColor),
          offset: Offset(_WidgetSize().offset1, _WidgetSize().offset2),
        ),
      ],
    );
  }
}

class _WidgetPadding extends EdgeInsets {
  const _WidgetPadding.all() : super.all(16.0);
  const _WidgetPadding.symetric() : super.symmetric(horizontal: 10);
  const _WidgetPadding.margin() : super.symmetric(horizontal: 10, vertical: 15);
}

class _WidgetSize {
  final double searchDecorationRadius = 8;
  final double spreadRadius = 5;
  final double blurRadius = 7;
  final double boxShadowColor = 0.5;
  final double offset1 = 0;
  final double offset2 = 3;
  final double richTextFontSize = 16;
  final double cardElevation = 15;
  final double buttonRadius = 20;

  final int taskStatus = 1;
  final int checkBoxCheck1 = 1;
  final int checkBoxCheck2 = 0;
}
