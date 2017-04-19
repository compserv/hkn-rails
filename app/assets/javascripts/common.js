$(document).ready(function() {
  $('form[method=get] input[name=utf8]').attr("disabled", "disabled");

  $("#user").click(function() {
    $("#userbar").toggle("fast");
  });
});
