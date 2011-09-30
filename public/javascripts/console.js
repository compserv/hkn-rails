var stdout = undefined;
var stdin  = undefined;
var conHist = [];
var iConHist = -1;

$(document).ready( function(){
  stdout = $('#stdout');
  stdin  = $('#input');
  $('#promptString')
    .html( promptString() )
    .ajaxSuccess( function(){
       $(this).html( promptString() ).show();
     });
  document.onkeyup = specialKey;

  $('#input').focus();
});

function puts( text ) {
  text += "<br>";
  stdout.html( stdout.html() + text );
  return text;
}

function promptString() {
  return ""+preprompt+username+"@hkn:~$ ";
}

function response(resp) {
  puts( promptString() + conHist[conHist.length-1] );
  puts( resp );
  stdin.focus();
}

function consoleKey( event ) {
  var keycode = window.event ? event.keyCode : event.which;

  if( keycode == 13 ) {         /* Return key */
    conHist.push( stdin.val() );
    $('#promptString').hide();
    $('#stdin form').submit();
    stdin.val("");
    iConHist = conHist.length;
    return false;
  }

  return true;
}

function specialKey( event ) {
  var keycode = window.event ? event.keyCode : event.which;

  switch( keycode ) {
  case 38: /* up */
    iConHist = Math.max( iConHist-1, 0 );
    stdin.val( conHist[iConHist] );
    break;
  case 40: /* down */
    iConHist = Math.min( iConHist+1, conHist.length-1 );
    stdin.val( conHist[iConHist] );
    break;
  }
}

function reauthenticate() {
  $('#reauthenticate_frame').remove();
  puts("<div id='reauthenticate_frame'></div>");
  $.get( '/reauthenticate', function(data) {
    $('#reauthenticate_frame').html( data ).focus();
    $('#reauthenticate_frame form').submit( function(){
      $('#reauthenticate_frame').remove();
      stdin.focus();
    });
  });
}
