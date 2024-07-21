import 'package:mini_ml/models/resource.dart';

enum DataType {
  // image,
  tabular,
// text, video
}

class Data implements Resource {
  @override
  dynamic createdAt;
  DataType? dataType;
  @override
  String description;
  Map<String, dynamic> variables;
  @override
  String id;
  @override
  String name;
  @override
  ResourceType resourceType;

  Data(
      {this.createdAt = '',
      this.dataType,
      this.description = '',
      this.variables = const {},
      this.id = '',
      this.name = '',
      this.resourceType = ResourceType.data});

  factory Data.fromJson(Map<String, dynamic> json) {
    DataType dataType = _parseDataType(json['data_type']);
    return Data(
      createdAt: json['created_at'] ?? '',
      dataType: dataType,
      description: json['description'] ?? '',
      variables: json['variables'] ?? {},
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  static DataType _parseDataType(String dataType) {
    switch (dataType) {
      // case 'image':
      //   return DataType.image;
      case 'tabular':
        return DataType.tabular;
      // case 'text':
      //   return DataType.text;
      // case 'video':
      //   return DataType.video;
      default:
        throw ArgumentError('Unknown ml_model_type: $dataType');
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'data_type': dataType.toString().split('.').last,
      'description': description,
      'name': name,
      'id': id,
      'resource_type': resourceType.toString().split('.').last,
      'variables': variables,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Data &&
        other.createdAt == createdAt &&
        other.dataType == dataType &&
        other.description == description &&
        other.variables == variables &&
        other.id == id &&
        other.name == name &&
        other.resourceType == resourceType;
  }

  @override
  int get hashCode {
    return Object.hash(
        createdAt, dataType, description, id, name, resourceType, runtimeType);
  }
}
