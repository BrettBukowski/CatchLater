!function(doc) {
  if (window.CatchLater) return window.CatchLater();
  
  var head = doc.getElementsByTagName('head')[0],
      script = doc.createElement('script');

    script.onload = script.onreadystatechange = function() {
      window.CatchLater();
    };
    script.src = 'http://0.0.0.0:3000/assets/app.min.js?cb=' + new Date().getTime();
    head.appendChild(script);
}(document);