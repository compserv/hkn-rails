$(document).ready(function() {
    var frame;

    username="unknown-user";
    $("#chat").click(function() {
        if (!frame) {
            frame = $('<iframe name="chat" id="chatbox" src="http://ghost.eecs.berkeley.edu:9999?nick=' + username + '&channels=hkn-chat&prompt=0"></iframe>');
            $("#chatwindow").append(frame);
            
            var cssLink = document.createElement("link") 
            cssLink.href = "chat.css"; 
            cssLink .rel = "stylesheet"; 
            cssLink .type = "text/css"; 
            frames['chat'].document.body.appendChild(cssLink);
        }
        $("#chatwindow").toggle("fast");
        return false;
    });
 });