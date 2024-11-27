import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String status;

  Task({required this.id, required this.title, required this.description, required this.dueDate, required this.status});

  ParseObject toParseObject() {
    final parseObject = ParseObject('Task');
    parseObject.set('title', title);
    parseObject.set('description', description);
    parseObject.set('dueDate', dueDate);
    parseObject.set('status', status);
    return parseObject;
  }

  static Task fromParseObject(ParseObject parseObject) {
    return Task(
      id: parseObject.objectId ?? '',
      title: parseObject.get<String>('title') ?? '',
      description: parseObject.get<String>('description') ?? '',
      dueDate: parseObject.get<DateTime>('dueDate') ?? DateTime.now(),
      status: parseObject.get<String>('status') ?? '',
    );
  }
}