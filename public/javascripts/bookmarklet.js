(function() {
  if(!window.snack && !window.CatchLater) {
    var head = document.getElementsByTagName('head')[0],
        scripts = ['snack/builds/snack', 'app'],
        i, s, length = scripts.length, interval;
    for(i = 0; i < length; i++) {  
        s = document.createElement('script');
        s.type = 'text/javascript';
        s.src = 'http://0.0.0.0:3000/javascripts/' + scripts[i] + '.js';
        head.appendChild(s);
    }
    // Rather to readystatechange / onload, do an interval check, since there's multiple scripts
    interval = setInterval(function(){
      if(window.snack && window.CatchLater) {
        clearInterval(interval);
        window.CatchLater();
      }
    }, 200);
  }
  else {
    window.CatchLater();
  }
})();