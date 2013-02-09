$(document).ready(function() {
    $("li.event").delegate("a[href$='new']","click",function(e) {
        e.preventDefault();
        enclosing_event = $(this).parent().parent().parent();
        enclosing_event.find(".rsvp_message").slideToggle(function() {
            enclosing_event.find(".rsvp_message").remove();
        });
        if (enclosing_event.find(".quick-rsvp").size() == 0) {
	    enclosing_event.append("<div class='quick-rsvp' style='display:none;'></div>");
	    $.get($(this).attr('href') + " #new_rsvp", function(data) {
	        if ($(data).find("#new_rsvp").length == 0) {
	  	    enclosing_event.find(".quick-rsvp").html($(data).find("#messages"));
	        }
	        else {
                    enclosing_event.find(".quick-rsvp").html($(data).find("#new_rsvp"));
		    $("#rsvp_comment").css("width","100%");
		    enclosing_event.find(".field-submit").append("<input type='submit' id='cancel-quick-rsvp' value='Cancel' />");
		    enclosing_event.find(".field:first").remove();
            	    enclosing_event.find(".field:first").remove();
	        }
	        enclosing_event.find(".quick-rsvp").slideToggle();
            });
	}
	else {
	    enclosing_event.find(".quick-rsvp").slideToggle();
	}
    });

    $("li.event").delegate("a[href$='edit']","click",function(e) {
        e.preventDefault();
        enclosing_event = $(this).parent().parent().parent();
        enclosing_event.find(".rsvp_message").slideToggle(function() {
            enclosing_event.find(".rsvp_message").remove();
        });
        if (enclosing_event.find(".quick-rsvp").size() == 0) {
            enclosing_event.append("<div class='quick-rsvp' style='display:none;'></div>");
            temp_rsvp_id = $(this).attr('href').split('/');
            rsvp_id = temp_rsvp_id[temp_rsvp_id.length - 2];
            edit_rsvp_str = "#edit_rsvp_" + rsvp_id;
            $.get($(this).attr('href') + " " + edit_rsvp_str, function(data) {
                if ($(data).find(edit_rsvp_str).length == 0) {
                    enclosing_event.find(".quick-rsvp").html($(data).find("#messages"));
                }
                else {
                    enclosing_event.find(".quick-rsvp").html($(data).find(edit_rsvp_str));
                    $("#rsvp_comment").css("width","100%");
                    enclosing_event.find(".field-submit").append("<input type='submit' id='cancel-quick-rsvp' value='Cancel' />");
                    enclosing_event.find(".field:first").remove();
                    enclosing_event.find(".field:first").remove();
                }
                enclosing_event.find(".quick-rsvp").slideToggle();
            });
        }
        else {
            enclosing_event.find(".quick-rsvp").slideToggle();
        }
    });

    $("li.event").delegate("#cancel-quick-rsvp","click",function(e) {
	e.preventDefault();
	$(this).parent().parent().parent().slideToggle();
    });

    $("li.event").delegate("form","submit",function(e) {
	e.preventDefault();
	enclosing_event = $(this).parent().parent();
	$.post($(this).attr("action"),$(this).serialize(), function(data) {
            enclosing_event.append("<div class='rsvp_message'></div>");
	    enclosing_event.find(".rsvp_message").html($(data).find("#messages"));
	    enclosing_event.find(".quick-rsvp").remove();
	    enclosing_event.find(".rsvp_link").html('[<a href="' + $(data).find("#edit_rsvp").attr("href") + '">RSVP\'ed</a>]');
	});
    });
});
