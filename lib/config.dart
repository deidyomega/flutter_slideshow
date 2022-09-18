import 'dart:convert';

class Config {
  int rows;
  int columns;
  int speed;
  int width;
  int height;
  String directory;
  bool fullscreen;

  Config({
    required this.rows,
    required this.columns,
    required this.speed,
    required this.width,
    required this.height,
    required this.directory,
    required this.fullscreen,
  });

  Config copyWith({
    int? rows,
    int? columns,
    int? speed,
    int? width,
    int? height,
    String? directory,
    bool? fullscreen,
  }) {
    return Config(
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      speed: speed ?? this.speed,
      width: width ?? this.width,
      height: height ?? this.height,
      directory: directory ?? this.directory,
      fullscreen: fullscreen ?? this.fullscreen,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rows': rows,
      'columns': columns,
      'speed': speed,
      'width': width,
      'height': height,
      'directory': directory,
      'fullscreen': fullscreen,
    };
  }

  factory Config.fromMap(Map<String, dynamic> map) {
    return Config(
      rows: map['rows'],
      columns: map['columns'],
      speed: map['speed'],
      width: map['width'],
      height: map['height'],
      directory: map['directory'],
      fullscreen: map['fullscreen'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Config.fromJson(String source) => Config.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Config(rows: $rows, columns: $columns, speed: $speed, width: $width, height: $height, directory: $directory, fullscreen: $fullscreen)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Config &&
        other.rows == rows &&
        other.columns == columns &&
        other.speed == speed &&
        other.width == width &&
        other.height == height &&
        other.directory == directory &&
        other.fullscreen == fullscreen;
  }

  @override
  int get hashCode {
    return rows.hashCode ^
        columns.hashCode ^
        speed.hashCode ^
        width.hashCode ^
        height.hashCode ^
        directory.hashCode ^
        fullscreen.hashCode;
  }
}
