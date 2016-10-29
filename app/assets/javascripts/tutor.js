var pref_color = "#3f3";
var comp_color = "#39f";
var curr_color = "#fc0";

var locked = false;
var highlighted = false;

$(document).ready(function() {
    $(".tutorbox").hide();
    $(".person").hover(function(){
        //$(".tutorbox").hide();
        box = $("#box" + $(this).attr("id"));
        box.show();
        box.css("left", $(this).offset().left + 20);
        box.css("top", $(this).offset().top + 20);
    }, function(){
        box = $("#box" + $(this).attr("id"));
        box.hide();
    });
});

function getObjectCss () {
	var css = null;
	try {
		var head = document.getElementsByTagName("head").item(0);
		head.appendChild(document.createElement("style"));
		css = document.styleSheets[document.styleSheets.length-1];
	} catch (ex) {
		css = document.createStyleSheet("tutoringStyle.css");
	}
	return css;
}

function addCssRule (css, selector, rule) {
	if (css.insertRule) {
		css.insertRule(selector + " { " + rule + " }", css.cssRules.length);
	} else if(css.addRule) {
		css.addRule(selector, rule);
	}
}

function deleteCssRule (css, selector) {
	if (!selector) {
		return;
	}

	if (tutoringcss.cssRules) {
		rules = tutoringcss.cssRules;
	}
	else if (tutoringcss.rules) {
		rules = tutoringcss.rules;
	}
	else {
		return;
	}

	for (var it = 0; it < rules.length; it++) {
		if (rules[it].selectorText.toLowerCase() == selector.toLowerCase()) {
			if (tutoringcss.deleteRule) {
				tutoringcss.deleteRule(it);
			}
			else if (tutoringcss.removeRule) {
				tutoringcss.removeRule(it);
			}
			return;
		}
	}
}

// Highlight using these funky colors.
function highlight (className) {
	if (!locked) {
		deleteCssRule(tutoringcss, '.' + highlighted + '_2');
		deleteCssRule(tutoringcss, '.' + highlighted + '_1');
		deleteCssRule(tutoringcss, '.' + highlighted + '_0');
		highlighted = className;
		addCssRule(tutoringcss, '.' + className + '_2', 'background: ' + pref_color + ' !important');
		addCssRule(tutoringcss, '.' + className + '_1', 'background: ' + comp_color + ' !important');
		addCssRule(tutoringcss, '.' + className + '_0', 'background: ' + curr_color + ' !important');
	}
}

// Get rid of the css.
function unhighlight (className) {
	if (!locked) {
		deleteCssRule(tutoringcss, '.' + highlighted + '_2');
		deleteCssRule(tutoringcss, '.' + highlighted + '_1');	
		deleteCssRule(tutoringcss, '.' + highlighted + '_0');
		highlighted = false;
	}
}

// Highlight and stay highlighted until we click something else.
// If you do click a different class, highlight it instead of clearing.
function locklight (className) {
	if (!locked){
		highlight(className);
		locked = className;
	}
	else if (locked != className) {
		locked = false;
		highlight(className);
		locked = className;
	}
	else {
		locked = false;
		highlight(className);
	}

	return false;
}

var tutoringcss = getObjectCss();
addCssRule(tutoringcss, '.pref', 'background: ' + pref_color + ' !important');
addCssRule(tutoringcss, '.comp', 'background: ' + comp_color + ' !important');
addCssRule(tutoringcss, '.curr', 'background: ' + curr_color + ' !important');
