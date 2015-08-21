import 'package:sky/widgets.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbols.dart';

void main() => runApp(new DatePickerDemo());

class DatePicker extends Component {
  DatePicker({this.dateTime});

  DateTime dateTime;

  Widget build() {
    DateFormat dateFormat = new DateFormat();
    DateSymbols symbols = dateFormat.dateSymbols;
    ThemeData theme = Theme.of(this);

    List<Text> headers = [];
    for (String weekDay in symbols.NARROWWEEKDAYS) {
      headers.add(new Text(weekDay, style: theme.text.caption));
    }
    List<Flex> rows = [
      new Flex(
        headers,
        justifyContent: FlexJustifyContent.spaceAround
      )
    ];
    int year = dateTime.year;
    int month = dateTime.month;
    // Dart's Date time constructor is very forgiving and will understand
    // month 13 as January of the next year. :)
    int daysInMonth = new DateTime(year, month + 1).difference(new DateTime(year, month)).inDays;
    int firstDay =  new DateTime(year, month).day;
    int weeksShown = 6;
    List<int> days = [
      DateTime.SUNDAY,
      DateTime.MONDAY,
      DateTime.TUESDAY,
      DateTime.WEDNESDAY,
      DateTime.THURSDAY,
      DateTime.FRIDAY,
      DateTime.SATURDAY
    ];
    int daySlots = weeksShown * days.length;
    List<Widget> labels = [];
    for (int i = 0; i < daySlots; i++) {
      // This assumes a start day of SUNDAY, but could be changed.
      int day = i - firstDay;
      if (day < 0 || day > daysInMonth)
        labels.add(new Text(""));
      else
        labels.add(new Text((day + 1).toString()));
    }
    for (int w = 0; w < weeksShown; w++) {
        int startIndex = w * days.length;
        rows.add(new Flex(
          labels.sublist(startIndex, startIndex + days.length),
          justifyContent: FlexJustifyContent.spaceAround
        ));
    }
    return new Flex([
      new Container(
        child: new ScrollableBlock([
            new Text("${dateTime.year}", style: theme.text.display2),
            new Text(new DateFormat("E, MMM d").format(dateTime), style: theme.text.display1),
          ]),
        padding: new EdgeDims.all(10.0),
        decoration: new BoxDecoration(backgroundColor: theme.accentColor)
      ),
      new Flex([
          new Icon(type:'navigation/chevron_left', size: 24),
          new Text(new DateFormat("MMMM y").format(dateTime)),
          new Icon(type:'navigation/chevron_right', size: 24),
        ],
        justifyContent: FlexJustifyContent.spaceBetween
      ),
      new Flex(rows, direction: FlexDirection.vertical)
    ],
    direction: FlexDirection.vertical);
  }
}

class DatePickerDemo extends App {
  DateTime _dateTime = new DateTime.now();

  Widget build() {
    return new Scaffold(
        toolbar: new ToolBar(center: new Text("Date Picker")),
        body: new Material(
          child: new Center(
            child: new DatePicker(dateTime: _dateTime)
          )
        )
    );
  }
}
