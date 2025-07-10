class TaskModel {
  String id;
  String userId;
  String title;
  bool isCompleted;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'title': title,
    'isCompleted': isCompleted,
  };

  static TaskModel fromJson(String id, Map<String, dynamic> json) {
    return TaskModel(
      id: id,
      userId: json['userId'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}