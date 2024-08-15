enum ProjectString { appName }

extension ProjectStrinExtension on ProjectString {
  String string() {
    switch (this) {
      case ProjectString.appName:
        return 'Todo List';
    }
  }
}
