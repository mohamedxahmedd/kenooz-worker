import 'package:easy_localization/easy_localization.dart';

String formatDate(String dateTimeString) {
  DateTime dateTime = DateTime.parse(dateTimeString);
  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
  return formattedDate;
}

// String formatTime(String dateTimeString) {
//   DateTime dateTime = DateTime.parse(dateTimeString);
//   String formattedDate = DateFormat('HH:mm').format(dateTime);
//   return formattedDate;
// }
String formatTime(String dateTimeString) {
  DateTime dateTime = DateTime.parse(dateTimeString);
  String formattedDate = DateFormat('hh:mm a').format(dateTime);
  return formattedDate;
}

bool isCurrentTimeBetween(String startTimeStr, String endTimeStr) {
  final now = DateTime.now();
  final startTimeParts = startTimeStr.split(':').map(int.parse).toList();
  final endTimeParts = endTimeStr.split(':').map(int.parse).toList();

  final startTime = DateTime(now.year, now.month, now.day, startTimeParts[0],
      startTimeParts[1], startTimeParts[2]);
  final endTime = DateTime(now.year, now.month, now.day, endTimeParts[0],
      endTimeParts[1], endTimeParts[2]);

  if (endTime.isBefore(startTime)) {
    // End time is on the next day
    return now.isAfter(startTime) || now.isBefore(endTime);
  } else {
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
}

String reformatDate(String dateStr, String locale) {
  // Parse the input date string
  DateTime parsedDate = DateTime.parse(dateStr);

  // Format the date into the desired output with the given locale
  String formattedDate =
      DateFormat('EEEE, dd MMMM yyyy', locale).format(parsedDate);

  return formattedDate;
}

int calculateSessionDuration(String startTime, String endTime) {
  // Parse the times into DateTime objects
  DateTime start = DateFormat("HH:mm").parse(startTime);
  DateTime end = DateFormat("HH:mm").parse(endTime);

  // Calculate the duration in minutes
  Duration duration = end.difference(start);
  return duration.inMinutes;
}

String formatDateDifference(String startDate, String endDate) {
  DateTime start = DateTime.parse(startDate);
  DateTime end = DateTime.parse(endDate);

  int totalDays = end.difference(start).inDays;

  int years = (totalDays / 365).floor(); // Approximate years
  int remainingDays = totalDays % 365; // Remaining days after full years

  int months = (remainingDays / 30).floor(); // Approximate months
  int days = remainingDays % 30; // Remaining days after full months

  List<String> parts = [];

  if (years > 0) {
    parts.add("$years year${years > 1 ? 's' : ''}");
  }
  if (months > 0) {
    parts.add("$months month${months > 1 ? 's' : ''}");
  }
  if (days > 0) {
    parts.add("$days day${days > 1 ? 's' : ''}");
  }

  return parts.isEmpty ? "0 days" : parts.join(", ");
}

String getDayName(String dateString) {
  DateTime date = DateTime.parse(dateString);
  List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  return days[date.weekday - 1]; // DateTime weekday starts from 1 (Monday)
}

String getDayNumber(String dateString) {
  DateTime date = DateTime.parse(dateString);
  return date.day.toString().padLeft(2, '0'); // Ensures "01" instead of "1"
}

String getMonthName(String dateString) {
  DateTime date = DateTime.parse(dateString);
  List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  return months[date.month - 1]; // DateTime.month starts from 1
}

String formatMedicineTime(String time) {
  try {
    // Parse the given time string
    final DateTime parsedTime = DateFormat("HH:mm:ss").parse(time);

    // Format to 12-hour format with AM/PM
    final String formattedTime = DateFormat("hh:mm a").format(parsedTime);

    return formattedTime;
  } catch (e) {
    return "Invalid time"; // Handle any errors
  }
}
