/* JavaScript for basic interactivity in the results page. */


if (window.addEventListener){
    window.addEventListener('load', init, false);
} 
else {
    if (window.attachEvent){
        window.attachEvent('onload', init);
    }
}


function init() {
    var url = window.location.href;
    var n = url.lastIndexOf('#');
    var hashDiv = url.substring(n + 1);
    var div = document.getElementById(hashDiv);
    if (div !== null) {
        div.setAttribute('class', 'showing');
    }
}


function showHide(sender) {
    var div = sender.parentNode;
    
    if (div.getAttribute('class') === 'hidden') {
        div.setAttribute('class', 'showing');
    } 
    else {
        div.setAttribute('class', 'hidden');
    }
}