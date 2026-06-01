int calculateDaysDifference(DateTime from, DateTime to) {
  // Clear the hour/minute/second data so we only look at the calendar day
  final fromDate = DateTime(from.year, from.month, from.day);
  final toDate = DateTime(to.year, to.month, to.day);
  return toDate.difference(fromDate).inDays;
}//hello