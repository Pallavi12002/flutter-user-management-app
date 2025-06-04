

import 'package:equatable/equatable.dart';

class TodoModel extends Equatable {
  final int id;
  final String todo;
  final bool completed;
  final int userId;

  const TodoModel({
    required this.id,
    required this.todo,
    required this.completed,
    required this.userId,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] ?? 0,
      todo: json['todo'] ?? '',
      completed: json['completed'] ?? false,
      userId: json['userId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todo': todo,
      'completed': completed,
      'userId': userId,
    };
  }

  @override
  List<Object> get props => [id, todo, completed, userId];
}