/*
 * b.js
 *
 * Makes every word start with the letter B.
 *
 */

var WORD_LETTERS    = /[abcdefghijklmnopqrstuvwxyz]+/i;
var VOWELS          = /[aeiou]+/i;
var BLOCKING_LETTERS= /[r]/i;

var bb = {
  isUpperCase: function(letter){
    if( letter.length > 1 ) letter = letter[0];
    return letter.toUpperCase() == letter;
  },
  isWord: function(word){
    return word.search(WORD_LETTERS) == 0;
  },
  matchCase: function(word, original_word){
    return word.split('').map(function(letter, i){
      return ( bb.isUpperCase( original_word[i] ) ? letter.toUpperCase() : letter.toLowerCase() );
    }).join('');
  },
};

var translate_word = function(word){
  if( !bb.isWord( word ) )
    return word;

  var i = word.search( VOWELS );

  /* A bunch of arbitrary grammatical rules */
  do
  {
    if( i == -1 )       /* no vowels */
      i = 1;
    else if( i > 2 )    /* too many consonants */
      i = 2;

    /* Don't pass blocking letters */
    var j = word.search(BLOCKING_LETTERS);
    if( j >= 0 && j < i && j < word.length-1 )
      i = j;

    /* Tweak for short words */
    if( word.length == 3 && i == 2 )
      i = 1;
  } while(false);

  var consonants = word.substr( 0, i );
  {
    if( consonants.length == 0 )
      consonants = "x";
  }
  var rest = word.slice( i );

  /* Hack for capitalization with no leading consonants */
  if( i == 0 && rest.length > 1 ) {
    rest = bb.matchCase( rest[0], rest[1] ) + rest.slice(1);
  }

  consonants = bb.matchCase( 'b', word );

  return consonants + rest;
};

var split_by_words = function(str){
  var s = [];

  var letter_before = false,
      letter_now    = undefined;

  str.split('').map(function(letter){
    letter_now = bb.isWord( letter );

    if( letter_before && letter_now ) {
      s[s.length-1] = s[s.length-1] + letter;
    } else {
      s.push( letter );
    }

    letter_before = letter_now;

  });

  return s;
};

$(document).ready(function(){
  var b = function() {
    $('*').map(function(index,e){
      for( var i in e.childNodes ) {
        var t = e.childNodes[i];
        if( t.nodeType != 3                              /* not text */
            || t.nodeValue.replace(/\s/,'').length == 0  /* empty */
          )
          continue;

        var s = split_by_words( t.nodeValue );
        s = s.map(translate_word);

        t.nodeValue = s.join('');

      }
    });
  };
  b();
});
