var CatchLater = CatchLater || (function() {
  var $ = snack.wrap,
      videos = [],
      sources = [
        {
          name: "youtube",
          domain: "youtube.com"
        }, 
        {
          name: "vimeo",
          domain: "vimeo.com"
        }
      ];    
  $.define('setStyle', function(styles) {
    return this.each(function(element) {
      for (var i in styles) {
        if (styles.hasOwnProperty(i)) {
          element.style[i] = styles[i];
        }
      }
    });
  });
  function parseURL(url) {
    var regex = /^((?:ht|f|nn)tps?)\:\/\/(?:([^\:\@]*)(?:\:([^\@]*))?\@)?([^\/]*)([^\?\#]*)(?:\?([^\#]*))?(?:\#(.*))?$/,
        pieces = [null, 'scheme', 'user', 'pass', 'host', 'path', 'query', 'fragment'],
        matches = url.match(regex),
        parsed = {};

    if (matches === null) return parsed;

    for (var i = 1, length = pieces.length; i < length; i++) {
      if (typeof matches[i] !== "undefined") {
        parsed[pieces[i]] = matches[i];
      }
    }
    if (parsed.path === '') {
      parsed.path = '/';
    }
    return parsed;
  }
  
  function run() {
    findVideo();
    highlightVideo();
  }
  
  function findVideo() {
    var url, tagName, parsedUrl, host;
    $('video, embed, iframe').each(function(item, index, all) {
      tagName = item.tagName.toLowerCase();
      if (tagName === 'iframe' || tagName === 'embed') {
        url = item.src;
      }
      parsedUrl = parseURL(url);
      if (parsedUrl.host) {
        host = parsedUrl.host;
        $(sources).each(function(source) {
          if (host.indexOf(source.domain) > -1) {
            videos.push(item);
          }
        });
      }
    });
    if (!videos.length) {
      alert("no video");
    }
  }
  
  function highlightVideo() {
    var styleElement,
        padding = 10;
    if (videos.length) {
      $(videos).each(function(element) {
        styleElement = (element.offsetHeight) ? element : element.parentNode;
        var d = document.createElement("div");
        $(d).setStyle({
          position: "absolute",
          border: "10px dashed blue",
          width: styleElement.offsetWidth + "px",
          height: styleElement.offsetHeight + "px",
          top: styleElement.offsetTop - padding + "px",
          left: styleElement.offsetLeft - padding + "px",
          bottom: styleElement.offsetTop + styleElement.offsetHeight + "px",
          right: styleElement.offsetLeft + styleElement.offsetWidth + "px",
          zIndex: 9999
        });
        document.body.appendChild(d);
      });
    }
  }
  
  return function() {
    if (typeof instance === "undefined") {
      instance = new run();
    }
    // only run this bookmarklet once per page
    return instance;
  };
})();
