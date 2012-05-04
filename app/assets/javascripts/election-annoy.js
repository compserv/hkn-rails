$(document).ready(function(){
  var lol = $('<div></div>')
    .attr('id', 'election-annoy')
    .append('FILL OUT YOUR ELECTION INFO')
    .css({ color: 'red' })
    .appendTo(document.body);

  $(document.body).mousemove(function(e){
    lol.css({ position: 'absolute', left: e.pageX+1, top: e.pageY+1, width: '8em', height: '2em', padding: '0.5em' });
  });
});
