/** This function sets up the menu. It creates listeners for all of the links and displays
 * the appropriate submenu when needed.
 */
/**
 * Finds what path we're at currently and extracts the lowest subdirectory.
 * It will then look to see if there is a toplevel menu that has that name. If so,
 * it will make it selected. If not it will pick the first one it finds and make that 
 * selected. Might be deprecated soon.  
 */ 
/** 
  amber: ported this to jQuery
  richardxia: ported this to Prototype
 */
$(document).ready(function() {
  $("#logo").click(function(){
    window.location = "/";
  });
  $(".submenu").hide();
	current = location.pathname.replace('/','');
  if (current.indexOf('/') != -1)
    current = current.substring(0,current.indexOf('/'));
	id = current;	
	if (id.length != 0 && id != "coursesurveys" && $("#" + id).length != 0) {
		$("#" + id).addClass("current");
		$("." + current + "_submenu").show();
	}
	else {
		$($(".navigation_toplevel_item")[0]).addClass("current");	
		$("#submenu .submenu").first().show();
		$("#submenu-thin .submenu").first().show();
	}
	$(".navigation_toplevel_item").click(function(e) {
	  e.preventDefault();
    $(".navigation_toplevel_item").removeClass("current");
    $(this).addClass("current");
    $(this).blur();
    $(".submenu").hide();
    id = $(this).attr("id") + "_submenu";
    //$(id).fadeIn({ duration: 0.2 });		
    $("." + id).show();
  });
  $("#userbar").toggle(function(){
    $("#user-dropdown").slideDown(300);
  }, function(){
    $("#user-dropdown").slideUp(300);
  });
  
});

