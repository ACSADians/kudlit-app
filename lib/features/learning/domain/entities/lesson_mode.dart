enum LessonMode {
  reference,
  draw,
  freeInput;

  static LessonMode fromJson(String value) {
    switch (value) {
      case 'reference':
        return LessonMode.reference;
      case 'draw':
        return LessonMode.draw;
      case 'freeInput':
      case 'free_input':
        return LessonMode.freeInput;
      default:
        throw ArgumentError('Unknown LessonMode: $value');
    }
  }
}
