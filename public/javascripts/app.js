var CatchLater = CatchLater || (function() {
  var $ = snack.wrap,
      videos = [];    

  $.define('setStyle', function(styles) {
    return this.each(function(element) {
      for (var i in styles) {
        if (styles.hasOwnProperty(i)) {
          element.style[i] = styles[i];
        }
      }
    });
  });
  $.define('html', function(html) {
    return this.each(function(element) {
      element.innerHTML = html;
    });
  });
  
  var Parser = (function() {
    var _sources = {
      iframe: [
        { name: 'youtube', regex: /www\.youtube(-nocookie)?\.com\/embed\/([^&?]+)/ },
        { name: 'vimeo', regex: /player\.vimeo\.com\/video\/([0-9]+)/ },
        { name: 'blip', regex: /blip\.tv\/play\/([^.]+)\.html/ }
      ],
      object: [
        { vimeo: /player\.vimeo\.com\/video\/([0-9]+)/ },
        { ted: /video\.ted\.com/ }
      ],
      embed: [
        { name: 'youtube', regex: /www\.youtube(-nocookie)?\.com\/embed\/([^&?]+)/ },
        { name: 'vimeo', regex: /vimeo\.com\/[^0-9]+([0-9]+)/ }
      ]
    },
    _checkSrc = function(sources, element) {
      for (var i = 0, src = element.src, match; i < sources.length; i++) {
        if (match = sources[i].regex.exec(src)) {
          return foundVideo(element, {source: sources[i].name, id: match[match.length - 1]});
        }
      }
    };
    return {
      iframe: function(el) {
        return _checkSrc(_sources.iframe, el);
      },
      object: function(el) {
        var data = el.data, match;
        
        if (match = _sources.object.ted.regex.exec(data)) {
          var paramData = $.wrap('#' + el.id + 'param[name="flashvars"]')[0];
          paramData = decodeURIComponent(paramData.value);
          if (match = /mp4:([^.]+\.mp4)/) {
            return found(el, {source: 'ted', id: match[1]});
          }
        }
        
        if (match = _sources.object.vimeo.regex.exec(data)) {
          
        }
      },
      embed: function(el) {
        return _checkSrc(_sources.embed, el);
      }
    };
  })();

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
  
  function foundVideo(video, details) {
    videos.push({video: video, details: details});
  }
  
  function findVideo() {
    $('object, embed, iframe').each(function(item, index, all) {
      Parser[item.tagName.toLowerCase()](item);
    });
    if (!videos.length) {
      alert("no supported video found :(");
    }
  }
  
  function highlightVideo() {
    if (videos.length) {
      $(videos).each(function(item) {
        drawPrompt(item.element, item.details);
      });
    }
  }
  
  function addVideo(url, type, details) {
      snack.JSONP({
        url: 'http://0.0.0.0:3000/queue/push/',
        key: 'addVideoResponse',
        data: {
          url: url,
          type: type,
          source: details.source,
          videoID: details.id,
          webpageUrl: window.top.location.href
        }
      }, function(resp) {
        console.log(resp);
      });
    }
  
  function drawPrompt(element, details) {
    var styleElement = (element.offsetHeight) ? element : element.parentNode,
      border, prompt, close, add,
      padding = 3;
    border = document.createElement("div");
    $(border).setStyle({
      position: "absolute",
      padding: padding + "px",
      border: "3px dotted red",
      width: styleElement.offsetWidth + "px",
      height: styleElement.offsetHeight + "px",
      top: styleElement.offsetTop - padding + "px",
      left: styleElement.offsetLeft - padding + "px",
      bottom: styleElement.offsetTop + styleElement.offsetHeight + "px",
      right: styleElement.offsetLeft + styleElement.offsetWidth + "px",
      zIndex: 9999
    });
    prompt = document.createElement("div");
    $(prompt).setStyle({
      background: "red",
      fontFamily: "'Lucida Grande', 'Lucida Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif",
      opacity: "0.96",
      position: "absolute",
      height: "50px",
      width: styleElement.offsetWidth + padding + "px",
      left: border.style.left,
      top: parseInt(border.style.top, 10) - 50 + "px",
      zIndex: 10000
    });
    if (parseInt(prompt.style.top, 0) < 0) {
      prompt.style.top = border.style.bottom;
    }
    close = document.createElement("a");
    $(close).setStyle({
      color: "#FFF",
      textDecoration: "none",
      position: "absolute",
      top: "4px",
      right: "4px"
    }).html("Close");
    close.href = "#";
    snack.listener({
      node: close,
      event: "click"
    }, function(e) {
        snack.preventDefault(e);
        border.parentNode.removeChild(border);
        prompt.parentNode.removeChild(prompt);
    });
    add = document.createElement("a");
    $(add).setStyle({
      color: "#FFF",
      textDecoration: "none",
      position: "absolute",
      top: "18%",
      left: "8px",
      borderRadius: "2px",
      padding: "6px 8px",
      boxShadow: "0 3px 3px rgba(0,0,0,.4)",
      background: "#5CCCCC"
    }).html("Add to Queue +");
    add.href = "#";
    snack.listener({
      node: add,
      event: "click"
    }, function(e) {
        snack.preventDefault(e);
        addVideo(element.src, element.tagName.toLowerCase(), details);
    });
    document.body.appendChild(border);
    document.body.appendChild(prompt);
    prompt.appendChild(close); prompt.appendChild(add);
  }
  
  function run() {
    findVideo();
    highlightVideo();
  }
  
  var instance;
  
  return function() {
    if (typeof instance === "undefined") {
      instance = new run();
    }
    // only run this bookmarklet once per page
    return instance;
  };
})();
