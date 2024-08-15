import 'package:flutter/material.dart';
import 'package:sqldatabse_learn/sql_database_learn/models/task.dart';
import 'package:sqldatabse_learn/sql_database_learn/services/database_service.dart';
import 'package:sqldatabse_learn/sql_database_learn/view/home_view.dart';

abstract class HomeViewModel<T extends HomeView> extends State<T> {
  final DatabaseService databaseService = DatabaseService.instance;
  final TextEditingController keyword = TextEditingController();
  Future<List<Task>>? notes;

  Future<List<Task>> search(String query) async {
    if (query.isEmpty) {
      return databaseService.getTasks();
    } else {
      return databaseService.search(query);
    }
  }

  @override
  void initState() {
    super.initState();
    notes = databaseService.getTasks();
  }
}
