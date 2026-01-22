class MediaModel {
  final String id;
  final String name;
  final String type;
  final int size;
  final String streamUrl;

  MediaModel({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.streamUrl,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      size: json['size'],
      streamUrl: json['stream_url'],
    );
  }
}
