String rupee(num v) =>
    '\u20B9${v == v.roundToDouble() ? v.toInt() : v.toStringAsFixed(1)}';

String hourLabel(int h) {
  final suffix = (h % 24) >= 12 ? 'PM' : 'AM';
  final hh = h % 12 == 0 ? 12 : h % 12;
  return '$hh $suffix';
}

String slotLabel(int h) => '${hourLabel(h)} - ${hourLabel(h + 1)}';

const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _daysShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December'];

String longDate(DateTime d) =>
    '${_days[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}, ${d.year}';
String shortDate(DateTime d) => '${d.day} ${_months[d.month - 1].substring(0, 3)}';
String dayShort(DateTime d) => _daysShort[d.weekday - 1];
bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String hoursSummary(List<int> hours) {
  if (hours.isEmpty) return '-';
  final h = [...hours]..sort();
  var contiguous = true;
  for (var i = 1; i < h.length; i++) {
    if (h[i] != h[i - 1] + 1) contiguous = false;
  }
  if (contiguous) return '${hourLabel(h.first)} - ${hourLabel(h.last + 1)}';
  return h.map(hourLabel).join(', ');
}

const sportEmoji = {
  'Football': '\u26BD',
  'Cricket': '\u{1F3CF}',
  'Badminton': '\u{1F3F8}',
  'Tennis': '\u{1F3BE}',
  'Basketball': '\u{1F3C0}',
};

const amenityEmoji = {
  'Floodlights': '\u{1F4A1}',
  'Washroom': '\u{1F6BF}',
  'Parking': '\u{1F17F}\uFE0F',
  'Caf\u00E9': '\u2615',
  'Drinking Water': '\u{1F4A7}',
};

String dayLong(DateTime d) => _days[d.weekday - 1];
