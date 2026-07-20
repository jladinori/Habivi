class AppClock {
  static Duration offset = Duration.zero; 
  static DateTime now() => DateTime.now().add(offset);
}
