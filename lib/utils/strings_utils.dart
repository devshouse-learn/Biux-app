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
}
