import 'package:mini_ml/models/data.dart';
import 'package:mini_ml/models/model.dart';

class Project {
  dynamic createdAt;
  String description;
  String name;
  String id;
  List<Data> data;
  List<Model> models;
  Model? currentModel;
  Data? currentData;

  Project({
    this.createdAt,
    this.description = '',
    this.id = '',
    this.name = '',
    this.data = const [],
    this.models = const [],
    this.currentData,
    this.currentModel,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      createdAt: json['created_at'] ?? DateTime.now(),
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      data: [],
      models: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'description': description,
      'name': name,
      'id': id,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project &&
        other.createdAt == createdAt &&
        other.description == description &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      createdAt,
      description,
      id,
      name,
    );
  }
}


    // if (validate()) {
    //   try {
    //     User? currentUser = FirebaseAuth.instance.currentUser;
    //     if (currentUser != null) {
    //       DocumentReference docRef = FirebaseFirestore.instance
    //           .collection('users')
    //           .doc(currentUser.uid)
    //           .collection('projects')
    //           .doc();
    //       createdAt = DateTime.now();
    //       id = docRef.id;
    //       await docRef.set(toJson());
    //     }
    //     print('Successfully add project to database');
    //   } catch (error) {
    //     print('Error creating project database: $error');
    //     rethrow;
    //   }
    // }