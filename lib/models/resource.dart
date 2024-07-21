enum ResourceType {
  data,
  model,
}

abstract class Resource {
  late dynamic createdAt;
  late String description;
  late String name;
  late String id;

  late ResourceType resourceType;

  factory Resource.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError(
        'fromJson factory method must be implemented by subclasses');
  }

  Map<String, dynamic> toJson();
}
