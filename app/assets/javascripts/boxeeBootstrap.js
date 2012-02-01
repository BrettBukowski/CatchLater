(function (e, a, g, h, f, c, b, d) {
  if (!(f = e.jQuery) || g > f.fn.jquery || h(f)) {
    c = a.createElement("script");
    c.type = "text/javascript";
    c.src = "http://ajax.googleapis.com/ajax/libs/jquery/" + g + "/jquery.min.js";
    c.onload = c.onreadystatechange = function () {
      if (!b && (!(d = this.readyState) || d == "loaded" || d == "complete")) {
        h((f = e.jQuery).noConflict(1), b = 1);
        f(c).remove();
      }
    };
    a.body.appendChild(c);
  }
})(window, document, "1.6.1", function ($, L) {
  var server = 'http://www.boxee.tv/';
  var logged_in = true;
  var loadLibrary = function (namespace, file, callback) {
    var prefix = server + 'htdocs/scripts/';
    if (namespace && window[namespace]) {
      callback();
    } else {
      var d, s, loaded = false;
      s = document.createElement("script");
      s.type = "text/javascript";
      s.src = prefix + file;
      s.onload = s.onreadystatechange = function () {
        if (!loaded && (!(d = this.readyState) || d == "loaded" || d == "complete")) {
          loaded = true;
          $(s).remove();
          callback();
        }
      };
      document.body.appendChild(s);
    }
  };
  var loadStylesheet = function (file) {
    var d, s, loaded = false;
    var prefix = server + 'htdocs/css/';
    var stylesheet = document.createElement("link");
    stylesheet.setAttribute("rel", "stylesheet");
    stylesheet.setAttribute("type", "text/css");
    stylesheet.setAttribute("href", prefix + file);
    document.body.appendChild(stylesheet);
  };
  var cache_buster = (new Date()).getTime().toString();
  loadStylesheet('watchlater/watchlater.css?' + cache_buster);
  loadLibrary('Handlebars', 'watchlater/vendor/handlebars.js', function () {
    loadLibrary('UnderscoreJS', 'watchlater/vendor/underscore-min-1.1.6.js', function () {
      loadLibrary('BoxeeWatchLater', 'watchlater/watchlater.js?' + cache_buster, function () {
        $.getJSON(server + "queue/watchlatertemplate?format=jsonp&callback=?", function (data) {
          if (data) {
            var runner = BoxeeWatchLaterRunner.init($, server);
            runner.run(data, logged_in);
          }
        });
      });
    });
  });
});
