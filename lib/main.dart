import 'package:sky/theme/colors.dart' as colors;
import 'package:sky/theme/typography.dart' as typography;
import 'package:sky/widgets.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbols.dart';

void main() => runApp(new DatePickerDemo());

typedef void DatePickerValueChanged(DateTime dateTime);

class DatePicker extends StatefulComponent {
  DatePicker({this.dateTime, this.onChanged});

  DateTime dateTime;
  DatePickerValueChanged onChanged;

  void syncConstructorArguments(DatePicker source) {
    dateTime = source.dateTime;
    onChanged = source.onChanged;
  }

  bool _showYear = false;

  EventDisposition _handleShowYear(_) {
    if (_showYear)
      return EventDisposition.ignored;
    setState(() {
      _showYear = true;
    });
    return EventDisposition.processed;
  }

  EventDisposition _handleHideYear(_) {
    if (!_showYear)
      return EventDisposition.ignored;
    setState(() {
      _showYear = false;
    });
    return EventDisposition.processed;
  }

  void _handleYearChanged(int year) {
    DateTime result = new DateTime(year, dateTime.month, dateTime.day);
    if (onChanged != null)
      onChanged(result);
  }

  void _handleDayChanged(int month, int day) {
    DateTime result = new DateTime(dateTime.year, month, day);
    if (onChanged != null)
      onChanged(result);
  }

  Widget build() {
    ThemeData theme = Theme.of(this);
    typography.TextTheme headerTheme;
    Color dayColor;
    Color yearColor;
    switch(theme.primaryColorBrightness) {
      case ThemeBrightness.light:
        headerTheme = typography.black;
        dayColor = _showYear ? colors.black54 : colors.black87;
        yearColor = _showYear ? colors.black87 : colors.black54;
        break;
      case ThemeBrightness.dark:
        headerTheme = typography.white;
        dayColor = _showYear ? colors.white54 : colors.white87;
        yearColor = _showYear ? colors.white87 : colors.white54;
        break;
    }
    TextStyle dayStyle = headerTheme.headline.copyWith(color: dayColor);
    TextStyle monthStyle = headerTheme.display3.copyWith(color: dayColor);
    TextStyle yearStyle = headerTheme.headline.copyWith(color: yearColor);
    Widget contents;
    if (_showYear) {
      contents = new Container(
        height: 160.0,
        child: new YearPicker(
          dateTime: dateTime,
          onChanged: _handleYearChanged
        )
      );
    } else {
      contents = new DayPicker(
        dateTime: dateTime,
        onChanged: _handleDayChanged
      );
    }

    return new Block([
      new Container(
        child: new BlockBody([
          new Center(
            child: new Listener(
              child: new Text(new DateFormat("MMM").format(dateTime).toUpperCase(), style: dayStyle),
              onGestureTap: _handleHideYear
            )
          ),
          new Center(
            child: new Listener(
              child: new Text(new DateFormat("d").format(dateTime), style: monthStyle),
              onGestureTap: _handleHideYear
            )
          ),
          new Center(
            child: new Listener(
              child: new Text(new DateFormat("yyyy").format(dateTime), style: yearStyle),
              onGestureTap: _handleShowYear
            )
          )
        ]),
        padding: new EdgeDims.all(10.0),
        decoration: new BoxDecoration(backgroundColor: theme.primaryColor)
      ),
      contents
    ]);
  }
}

typedef void DayPickerValueChanged(int month, int day);

class DayPicker extends Component {
  DayPicker({ this.dateTime, this.onChanged });
  final DateTime dateTime;
  final DayPickerValueChanged onChanged;

  Widget build() {
    ThemeData theme = Theme.of(this);
    DateFormat dateFormat = new DateFormat();
    DateSymbols symbols = dateFormat.dateSymbols;

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
      int day = i - firstDay + 1;
      Widget item;
      if (day < 1 || day > daysInMonth) {
        item = new Text("");
      } else {
        item = new Listener(
          onGestureTap: (_) {
            if (onChanged != null)
              onChanged(month, day);
          },
          child: new Container(
            height: 30.0,
            decoration: day == dateTime.day ? new BoxDecoration(
              backgroundColor: Theme.of(this).primarySwatch[100],
              shape: Shape.circle
            ) : null,
            child: new Center(
              child: new Text(day.toString())
            )
          )
        );
      }
      labels.add(new Flexible(child: item));
    }
    for (int w = 0; w < weeksShown; w++) {
        int startIndex = w * days.length;
        rows.add(new Container(
          child: new Flex(
            labels.sublist(startIndex, startIndex + days.length),
            justifyContent: FlexJustifyContent.spaceAround
          ), padding: const EdgeDims.symmetric(vertical: 5.0)
        ));
    }

    return new BlockBody([
      new Flex([
        new Icon(type:'navigation/chevron_left', size: 24),
        new Text(new DateFormat("MMMM y").format(dateTime)),
        new Icon(type:'navigation/chevron_right', size: 24),
      ], justifyContent: FlexJustifyContent.spaceBetween),
      new BlockBody(rows)
    ]);
  }
}

typedef void YearPickerValueChanged(int year);

class YearPicker extends ScrollableWidgetList {
  YearPicker({
    this.dateTime,
    this.onChanged,
    this.firstYear: 2014,
    this.lastYear: 2101
  })
   : super(itemExtent: 50.0) {
    assert(lastYear >= firstYear);
  }
  DateTime dateTime;
  YearPickerValueChanged onChanged;
  int firstYear;
  int lastYear;

  void syncConstructorArguments(YearPicker source) {
    dateTime = source.dateTime;
    onChanged = source.onChanged;
    firstYear = source.firstYear;
    lastYear = source.lastYear;
    super.syncConstructorArguments(source);
  }

  int get itemCount => lastYear - firstYear + 1;

  List<Widget> buildItems(int start, int count) {
    TextStyle style = Theme.of(this).text.body1.copyWith(color: colors.black54);
    List<Widget> items = new List<Widget>();
    for(int i = start; i < start + count; i++) {
      int year = firstYear + i;
      String label = year.toString();
      Widget item = new Listener(
        key: new Key(label),
        onGestureTap: (_) {
          if (onChanged != null)
            onChanged(year);
        },
        child: new InkWell(
          child: new Container(
            height: itemExtent,
            decoration: year == dateTime.year ? new BoxDecoration(
              backgroundColor: Theme.of(this).primarySwatch[100],
              shape: Shape.circle
            ) : null,
            child: new Center(
              child: new Text(label, style: style)
            )
          )
        )
      );
      items.add(item);
    }
    return items;
  }
}

class DatePickerDemo extends App {

  DateTime _dateTime;

  void initState() {
    DateTime now = new DateTime.now();
    _dateTime = new DateTime(now.year, now.month, now.day);
  }

  void _handleDateChanged(DateTime dateTime) {
    setState(() {
      _dateTime = dateTime;
    });
  }

  Widget build() {
    return new Theme(
      data: new ThemeData(
        brightness: ThemeBrightness.light,
        primarySwatch: colors.Teal
      ),
      child: new Stack([
        new Scaffold(
          toolbar: new ToolBar(center: new Text("Date Picker")),
          body: new Material(
            child: new Text(_dateTime.toString())
          )
        ),
        new Dialog(
          content: new DatePicker(dateTime: _dateTime, onChanged: _handleDateChanged),
          contentPadding: EdgeDims.zero,
          actions: [
            new FlatButton(
              child: new Text('CANCEL')
            ),
            new FlatButton(
              child: new Text('OK')
            ),
          ]
        )
      ])
    );
  }
}
