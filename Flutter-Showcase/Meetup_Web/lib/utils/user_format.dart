String formatDate(DateTime? dateTime) {
  if (dateTime == null) return 'N/A';
  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${dateTime.day} ${months[dateTime.month - 1]}, ${dateTime.year}';
}

String getInitials(String name, {String fallback = ''}) {
  final nameParts = name.trim().split(' ').where((n) => n.isNotEmpty).toList();
  if (nameParts.isEmpty) return fallback;
  if (nameParts.length == 1) {
    return nameParts[0][0].toUpperCase();
  }
  final firstInitial = nameParts.first[0];
  final lastInitial = nameParts.last[0];
  return (firstInitial + lastInitial).toUpperCase();
}
