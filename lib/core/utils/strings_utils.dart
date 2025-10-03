import 'package:biux/core/config/strings.dart';

extension StringsExtension on String {
  String get hourFormatter {
    String hour;
    DateTime dt = DateTime.parse(this);
    if (dt.hour <= 12 && dt.minute < 10) {
      hour = '${dt.hour}:0${dt.minute}\nA.M';
    } else if (dt.hour <= 12) {
      hour = '${dt.hour}:${dt.minute}\nA.M';
    } else if (dt.minute < 10) {
      hour = '${dt.hour - 12}:0${dt.minute}\nP.M';
    } else {
      hour = '${dt.hour - 12}:${dt.minute}\nP.M';
    }
    return hour;
  }

  String get dateFormatterWithDe {
    String date;
    DateTime dt = DateTime.parse(this);
    String day = dt.day <= 9 ? '0${dt.day}' : dt.day.toString();
    String? month;
    switch (dt.month) {
      case 1:
        month = 'Ene';
        break;
      case 2:
        month = 'Feb';
        break;
      case 3:
        month = 'Mar';
        break;
      case 4:
        month = 'Abr';
        break;
      case 5:
        month = 'May';
        break;
      case 6:
        month = 'Jun';
        break;
      case 7:
        month = 'Jul';
        break;
      case 8:
        month = 'Ago';
        break;
      case 9:
        month = 'Sep';
        break;
      case 10:
        month = 'Oct';
        break;
      case 11:
        month = 'Nov';
        break;
      case 12:
        month = 'Dic';
        break;
      default:
    }
    date = '$day $month';
    return date;
  }

  String get timeHaveCreated {
    DateTime dt = DateTime.parse(this);
    final date = DateTime.now();
    String timeHaveCreated = '';
    final formattedHours = date.difference(dt).inHours;
    final formattedMinutes = date.difference(dt).inMinutes;
    final formattedDays = date.difference(dt).inDays;
    if (formattedMinutes <= 59) {
      timeHaveCreated = AppStrings.storytimeHaveCreated(
        number: formattedMinutes.toString(),
        time: AppStrings.minutesText,
      );
    } else {
      if (formattedHours <= 23) {
        timeHaveCreated = AppStrings.storytimeHaveCreated(
          number: formattedHours.toString(),
          time: AppStrings.hoursText,
        );
      } else {
        if (formattedDays <= 6) {
          timeHaveCreated = AppStrings.storytimeHaveCreated(
            number: formattedDays.toString(),
            time: AppStrings.daysText,
          );
        } else {
          if (formattedDays <= 28) {
            int number = (formattedDays / 7).floor();
            timeHaveCreated = AppStrings.storytimeHaveCreated(
              number: number.toString(),
              time: AppStrings.weeksText,
            );
          } else {
            int number = (formattedDays / 28).floor();
            timeHaveCreated = AppStrings.storytimeHaveCreated(
              number: number.toString(),
              time: AppStrings.monthsText,
            );
          }
        }
      }
    }
    return timeHaveCreated;
  }
}
