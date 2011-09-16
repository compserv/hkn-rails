function fTranslate(text)
{
    var x = ""
    var matches = text.match(/\b\w+\b/g)
    var wordCount = matches ? matches.length : 0
    if (wordCount <= 0) return null
    var base = 0x4e00
    for (var i = 0; i < wordCount*2; i++)
    {
        var value = Math.floor(Math.random()*10000)
        x += String.fromCharCode(base + value)
    }
    return x
}

function moonspeak_helper(node) {
    // 3 = text node
    if (node[0].nodeType == 3)
    {
        var trans = fTranslate(node[0].nodeValue)
        if (trans == null) return
        node[0].nodeValue = trans
    }
    else if (!node.is(".no-translation"))
    {
        node.contents().each(function (i) {
            moonspeak_helper($(this))
        })
    }
}

function moonspeak() {
    moonspeak_helper($("body"))
}

$(document).ready(moonspeak)
