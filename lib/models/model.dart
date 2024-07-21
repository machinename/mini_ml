import 'package:mini_ml/models/resource.dart';

enum ModelType {
  classification,
  computerVision,
  naturalLanguageProcessing,
  regression,
  timeSeriesForecasting,
}

class Model implements Resource {
  @override
  dynamic createdAt;
  @override
  String description;
  @override
  String id;
  @override
  String name;
  @override
  ResourceType resourceType;

  String dataId;
  String dataName;
  Map<String, dynamic> evaluationMetrics;
  String label;
  ModelType? modelType;

  Model(
      {this.createdAt = '',
      this.dataId = '',
      this.dataName = '',
      this.description = '',
      this.evaluationMetrics = const {},
      this.name = '',
      this.id = '',
      this.label = '',
      this.modelType,
      this.resourceType = ResourceType.model});

  factory Model.fromJson(Map<String, dynamic> json) {
    ModelType modelType = _parseMLModelType(json['model_type']);

    return Model(
      createdAt: json['created_at'] ?? DateTime.now(),
      dataId: json['data_id'] ?? '',
      dataName: json['data_name'] ?? '',
      description: json['description'] ?? '',
      evaluationMetrics: json['evaluation_metrics'] ?? {},
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      modelType: modelType,
      name: json['name'] ?? '',
      resourceType: ResourceType.model,
    );
  }

  static ModelType _parseMLModelType(String modelType) {
    switch (modelType) {
      case 'regression':
        return ModelType.regression;
      case 'classification':
        return ModelType.classification;
      case 'timeSeriesForecasting':
        return ModelType.timeSeriesForecasting;
      case 'naturalLanguageProcessing':
        return ModelType.naturalLanguageProcessing;
      case 'computerVision':
        return ModelType.computerVision;
      default:
        throw ArgumentError('Unknown ml_model_type: $modelType');
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'data_id': dataId,
      'data_name': dataName,
      'description': description,
      'evaluation_metrics': evaluationMetrics,
      'name': name,
      'id': id,
      'label': label,
      'model_type': modelType.toString().split('.').last,
      'resource_type': resourceType.toString().split('.').last
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Model &&
        other.createdAt == createdAt &&
        other.dataId == dataId &&
        other.dataName == dataName &&
        other.description == description &&
        other.id == id &&
        other.modelType == modelType &&
        other.name == name &&
        other.resourceType == resourceType;
  }

  @override
  int get hashCode {
    return Object.hash(createdAt, dataId, dataName, description, id, modelType,
        name, resourceType, runtimeType);
  }
}
