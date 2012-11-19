  $(document).ready(function() {
    
    $("body").on("click", ".datetimepicker", function(){
    $(this).datetimepicker({
        dateFormat: 'yy-mm-dd',
        timeFormat: 'hh:mm tt',
        stepHour: 1,
        stepMinute: 5,
        hourGrid: 6,
        minuteGrid: 15
    });
    $(this).datepicker("show");
    });
    
    //calculate date one week from now
    var currentTime = new Date();
    currentTime.setDate(currentTime.getDate()+7);
    var year = currentTime.getFullYear();
    var month = currentTime.getMonth() + 1;
    var day = currentTime.getDate();
    var hours = currentTime.getHours();
    var minutes = currentTime.getMinutes();
    var suffix = "am"
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
    var dateOneWeekFromNow = year + "-" + month + "-" + day + " ";
    dateOneWeekFromNow += hours + ":" + minutes + " " + suffix;
    $("body").on("click", ".datetimepickerdepttour", function(){
    $(this).datetimepicker({
        defaultValue: dateOneWeekFromNow,
        dateFormat: 'yy-mm-dd',
        timeFormat: 'hh:mm tt',
        stepHour: 1,
        stepMinute: 5,
        hourGrid: 6,
        minuteGrid: 15
    });
    $(this).datepicker("show");
    });

  });

