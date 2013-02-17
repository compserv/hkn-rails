$(document).ready(function() {
  //calculate date one week from now
  var currentTime = new Date();
  var oneWeekFromNow = new Date(currentTime.getTime() + 7*24*60*60*1000);
  var year = oneWeekFromNow.getFullYear();
  var month = oneWeekFromNow.getMonth() + 1;
  var day = oneWeekFromNow.getDate();
  var hours = oneWeekFromNow.getHours();
  var minutes = oneWeekFromNow.getMinutes();
  var suffix = "am";
  //convert hours to AM/PM format
  if (hours >= 12)
  {
    suffix = "pm";
  }
  if (hours == 0)
  {
    hours += 12;
  }
  else if (hours > 12)
  {
    hours %= 12;
  }
  //fix up formatting of default date (one week from current date)
  if (minutes < 10)
  {
    minutes = "0" + minutes;
  }
  if (hours < 10)
  {
    hours = "0" + hours;
  }
  if (month < 10)
  {
    month = "0" + month;
  }
  var dateOneWeekFromNow = year + "-" + month + "-" + day + " ";
  dateOneWeekFromNow += hours + ":" + minutes + " " + suffix;
  $(function() {
    $(".datetimepicker").datetimepicker({
      defaultValue: dateOneWeekFromNow,
      dateFormat: 'yy-mm-dd',
      timeFormat: 'hh:mm tt',
      stepHour: 1,
      stepMinute: 5,
      hourGrid: 6,
      minuteGrid: 15,
      showOn: "button",
      buttonImage: "../assets/icons/calendar.gif",
      buttonImageOnly: true,
      buttonText: "show calendar"
    });
  });
});
