enum StopMode {
  general,
  strict,
  meme; // Hidden from UI, kept for data migration

  String get displayName {
    switch (this) {
      case StopMode.general:
        return 'General';
      case StopMode.strict:
        return 'Strict';
      case StopMode.meme:
        return 'General'; // Map to General for display
    }
  }

  String get description {
    switch (this) {
      case StopMode.general:
        return 'Nhắc nhở nhẹ nhàng, ấm áp';
      case StopMode.strict:
        return 'Kỷ luật thép, đanh thép cảnh tỉnh';
      case StopMode.meme:
        return 'Nhắc nhở nhẹ nhàng, ấm áp'; // Map to General description
    }
  }

  StopMode get visibleMode {
    switch (this) {
      case StopMode.meme:
        return StopMode.general; // Map old meme to general
      case StopMode.general:
      case StopMode.strict:
        return this;
    }
  }
}
