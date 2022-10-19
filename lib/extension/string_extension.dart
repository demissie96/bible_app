extension StringExtension on String {
  String capitalizeFirst() {
    return " ${this[0].toUpperCase()}${this.substring(1)}";
  }

  String capitalizeFirstForCopy() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
