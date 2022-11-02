extension StringExtension on String {
  String capitalizeFirstWithSpace() {
    return " ${this[0].toUpperCase()}${this.substring(1)}";
  }

  String capitalizeFirstElement() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
