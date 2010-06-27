/** This function sets up the menu. It creates listeners for all of the links and displays
 * the appropriate submenu when needed.
 */
/**
 * Finds what path we're at currently and extracts the lowest subdirectory.
 * It will then look to see if there is a toplevel menu that has that name. If so,
 * it will make it selected. If not it will pick the first one it finds and make that 
 * selected. Might be deprecated soon.  
 */
/** richardxia:
 * Ported this to Prototype
 */
document.observe("dom:loaded", function() {
	current = location.pathname.replace('/','');
	current = current.substring(0,current.indexOf('/'));
	id = current;	
	if (id.length != 0 && $(id).length != 0) {
		$(id).addClass("selected");
		submenuid = current + "_submenu";
		$(submenuid).show();	
	}
	else {
		$$(".navigation_toplevel_item:first-child").first().addClassName("selected");	
		$$(".submenu").first().setStyle({
display:  'block'
});
	}
	$$(".navigation_toplevel_item").each(function(s) {
    s.observe("click", 
      function () {
        $$(".navigation_toplevel_item").invoke("removeClassName", "selected");
        $(this).addClassName("selected");
        $(this).blur();
        $$(".submenu").invoke("hide");
        id = $(this).readAttribute("id") + "_submenu";
        //$(id).fade({ duration: 0.2 });		
		    $(id).setStyle({ display:  'block' });
      }	
    );
  });
});

