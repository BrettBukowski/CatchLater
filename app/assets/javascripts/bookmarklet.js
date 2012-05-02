!function(doc, win) {
  if (win.CatchLater) return win.CatchLater();
  
  var head = doc.getElementsByTagName('head')[0],
      script = doc.createElement('script');

    script.onload = script.onreadystatechange = function() {
      win.CatchLater();
    };
    script.src = 'http://0.0.0.0:3000/assets/app.min.js?cb=' + new Date().getTime();
    head.appendChild(script);
}(document, window);