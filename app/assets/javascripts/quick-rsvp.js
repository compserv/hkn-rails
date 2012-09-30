$(document).ready(function() {
    $("li.event a[href$='new']").click(function(e) {
	e.preventDefault();
	//$(".quick-rsvp").slideToggle(function() {
	$(".quick-rsvp").remove();
	//});
	$(this).parent().parent().parent().append("<div class='quick-rsvp' style='display:none;'></div>");
	$.get($(this).attr('href') + " #new_rsvp", function(data) {
	    if ($(data).find("#new_rsvp").length == 0) {
		$(".quick-rsvp").html($(data).find("#messages"));
	    }
	    else {
		$(".quick-rsvp").html($(data).find("#new_rsvp"));
		$("#rsvp_comment").css("width","100%");
		$(".quick-rsvp .field-submit").append("<input type='submit' id='cancel-quick-rsvp' value='Cancel' />");
	    }
	    $(".quick-rsvp").slideToggle();
	    $("li.event .field:first").remove();
	    $("li.event .field:first").remove();
	});
    });

    $("li.event").delegate("#cancel-quick-rsvp","click",function(e) {
	e.preventDefault();
	$(".quick-rsvp").slideToggle();
    });

    $("li.event").delegate("form","submit",function(e) {
	e.preventDefault();
	$.post($(this).attr("action"),$(this).serialize(), function(data) {
	    $(".quick-rsvp").html($(data).find("#messages"));
	    $(".quick-rsvp").parent().find(".rsvp_link").remove();
	});
    });
});