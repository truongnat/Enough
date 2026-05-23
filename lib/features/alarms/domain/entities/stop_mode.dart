enum StopMode {
  general,
  strict,
  meme;

  String get displayName {
    switch (this) {
      case StopMode.general:
        return 'General';
      case StopMode.strict:
        return 'Strict';
      case StopMode.meme:
        return 'Meme';
    }
  }

  String get description {
    switch (this) {
      case StopMode.general:
        return 'Nhắc nhở nhẹ nhàng, ấm áp';
      case StopMode.strict:
        return 'Kỷ luật thép, đanh thép cảnh tỉnh';
      case StopMode.meme:
        return 'Meme châm biếm, vui vẻ thức tỉnh';
    }
  }
}
