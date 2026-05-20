enum StopMode {
  gentle,
  strict,
  meme;

  String get displayName {
    switch (this) {
      case StopMode.gentle:
        return 'Gentle';
      case StopMode.strict:
        return 'Strict';
      case StopMode.meme:
        return 'Meme';
    }
  }

  String get description {
    switch (this) {
      case StopMode.gentle:
        return 'Nhắc nhở nhẹ nhàng, ấm áp';
      case StopMode.strict:
        return 'Kỷ luật thép, đanh thép cảnh tỉnh';
      case StopMode.meme:
        return 'Meme châm biếm, vui vẻ thức tỉnh';
    }
  }
}
