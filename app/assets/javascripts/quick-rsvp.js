$(document).ready(function() {
    $("li.event").on("click", "a[href$='new']", function(e) {
        enclosing_event = $(this).parent().parent().parent();
        enclosing_event.find(".rsvp_message").slideToggle(function() {
            enclosing_event.find(".rsvp_message").remove();
        });
        if (enclosing_event.find(".quick-rsvp").size() == 0) {
            enclosing_event.append("<div class='quick-rsvp' style='display:none;'></div>");
            $.get($(this).attr('href') + " #new_rsvp", function(data) {
                if ($(data).find("#new_rsvp").length == 0) {
                    enclosing_event.find(".quick-rsvp").html($(data).find("#messages"));
                } else {
                    enclosing_event.find(".quick-rsvp").html($(data).find("#new_rsvp"));
                    $("#rsvp_comment").css("width","100%");
                    enclosing_event.find(".field-submit").append("<input type='submit' id='cancel-quick-rsvp' value='Cancel' />");
                    enclosing_event.find(".field:first").remove();
                    enclosing_event.find(".field:first").remove();
                }
                enclosing_event.find(".quick-rsvp").slideToggle();
            });
        } else {
            enclosing_event.find(".quick-rsvp").slideToggle();
        }
        return false;
    });

    $("li.event").on("click", "a[href$='edit']", function(e) {
        enclosing_event = $(this).parent().parent().parent();
        enclosing_event.find(".rsvp_message").slideToggle(function() {
            enclosing_event.find(".rsvp_message").remove();
        });
        if (enclosing_event.find(".quick-rsvp").size() == 0) {
            enclosing_event.append("<div class='quick-rsvp' style='display:none;'></div>");
            rsvp_id = $(this).data('rsvp_id');
            edit_rsvp_str = "#edit_rsvp_" + rsvp_id;
            $.get($(this).attr('href') + " " + edit_rsvp_str, function(data) {
                if ($(data).find(edit_rsvp_str).length == 0) {
                    enclosing_event.find(".quick-rsvp").html($(data).find("#messages"));
                } else {
                    enclosing_event.find(".quick-rsvp").html($(data).find(edit_rsvp_str));
                    $("#rsvp_comment").css("width","100%");
                    enclosing_event.find(".field-submit").append("<input type='submit' id='cancel-quick-rsvp' value='Cancel' />");
                    enclosing_event.find(".field:first").remove();
                    enclosing_event.find(".field:first").remove();
                }
                enclosing_event.find(".quick-rsvp").slideToggle();
            });
        } else {
            enclosing_event.find(".quick-rsvp").slideToggle();
        }
        return false;
    });

    $("li.event").on("click", "#cancel-quick-rsvp", function(e) {
        $(this).parent().parent().parent().slideToggle();
        return false;
    });

    $("li.event").on("submit", "form", function(e) {
        enclosing_event = $(this).parent().parent();
        $.post($(this).attr("action"),$(this).serialize(), function(data) {
            enclosing_event.append("<div class='rsvp_message'></div>");
            enclosing_event.find(".rsvp_message").html($(data).find("#messages"));
            enclosing_event.find(".quick-rsvp").remove();
            enclosing_event.find(".rsvp_link").html('[<a data-rsvp_id="'+ $(data).find("#edit_rsvp").data('rsvp_id') +'" href="' + $(data).find("#edit_rsvp").attr("href") + '">RSVP\'ed</a>]');
            
        });
        return false;
    });
});
