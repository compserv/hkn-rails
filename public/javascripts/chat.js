$(document).ready(function() {
    $("#user").click(function(){
      $("#userbar").toggle("fast");
    });
    var frame;
    username="guest";
    $("#chat").click(function() {
        if (!frame) {
            frame = $('<iframe name="chat" id="chatbox" src="http://ghost.eecs.berkeley.edu:9999?nick=' + username + '&channels=hkn-chat&prompt=0"></iframe>');
            $("#chatwindow").append(frame);
        }
        $("#chatwindow").toggle("fast");
        return false;
    });
 });