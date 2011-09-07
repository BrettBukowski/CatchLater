var CatchLater = CatchLater || (function() {
  var $ = snack.wrap;
  
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
        { vimeo: { data: /\.vimeocdn\.com/, id: /clip_id=([0-9]+)/ } },
        { ted: { data: /video\.ted\.com/, id: /mp4:([^.]+\.mp4)/, decode: true } }
      ],
      embed: [
        { name: 'youtube', regex: /www\.youtube(-nocookie)?\.com\/embed\/([^&?]+)/ },
        { name: 'vimeo', regex: /vimeo\.com\/[^0-9]+([0-9]+)/ }
      ]
    },
    _checkIframeSrc = function(sources, el) {
      var src = el.src, match, i;
      for (i in sources) {
        if (sources.hasOwnProperty(i) && (match = sources[i].regex.exec(src))) {
          return Video.foundVideo(el, {source: sources[i].name, id: match[match.length - 1]});
        }
      }
    },
    _checkObjectData = function(sources, el) {
      var data = el.data, 
          source, match, i, paramData;
      for (i in sources) {
        source = sources[i];
        if (sources.hasOwnProperty(i) && (match = source.data.exec(data))) {
          paramData = $.wrap('#' + el.id + ' param[name="flashvars"]')[0];
          (source.decode && (paramData = decodeURIComponent(paramData.value));
          if (match = source.id.exec(paramData)) {
            return found(el, {source: i, id: match[match.length - 1]});
          }
        }
      }
    };
    return {
      iframe: function(el) {
        return _checkIframeSrc(_sources.iframe, el);
      },
      object: function(el) {
        return _checkObjectData(_sources.object, el);
      },
      embed: function(el) {
        return _checkSrc(_sources.embed, el);
      }
    };
  })(),
  
  UI = (function() {
    var _padding = 3;
    
    function _border(element) {
      var border = document.createElement("div");
      $(border).setStyle({
        position: "absolute",
        padding: _padding + "px",
        border: "3px dotted red",
        width: element.offsetWidth + "px",
        height: element.offsetHeight + "px",
        top: element.offsetTop - _padding + "px",
        left: element.offsetLeft - _padding + "px",
        bottom: element.offsetTop + element.offsetHeight + "px",
        right: element.offsetLeft + element.offsetWidth + "px",
        zIndex: 9999
      });
      return border;
    }
    
    function _prompt(element, border) {
      var prompt = document.createElement("div");
      $(prompt).setStyle({
        background: "red",
        fontFamily: "'Lucida Grande', 'Lucida Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif",
        opacity: "0.96",
        position: "absolute",
        height: "50px",
        width: styleElement.offsetWidth + _padding + "px",
        left: border.style.left,
        top: parseInt(border.style.top, 10) - 50 + "px",
        zIndex: 10000
      });
      if (parseInt(prompt.style.top, 10) < 0) {
        prompt.style.top = border.style.bottom;
      }
      return prompt;
    }
    
    function _close(border, prompt) {
      var close = document.createElement("a");
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
    }
    
    function _add(onClick) {
      var add = document.createElement("a");
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
        onClick();
      });
    }
    
    return {
      drawPrompt: function(element, details) {
        var styleElement = (element.offsetHeight) ? element : element.parentNode,
            border = _border(styleElement);
            prompt = _prompt(styleElement, border);
            close = _close(border, prompt);
            add = _add(function() {
              Video.addVideo(element.src, element.tagName.toLowerCase(), details);
            });
        
        document.body.appendChild(border);
        document.body.appendChild(prompt);
        prompt.appendChild(close); prompt.appendChild(add);
      }
    };
  })(),
  
  Video = (function() {
    var _videos = [];
    
    function _highlightVideo() {
      $(_videos).each(function(item) {
        UI.drawPrompt(item.video, item.details);
      });
    }
    
    return {
      foundVideo: function(video, details) {
        _videos.push({video: video, details: details});
      },

      findVideo: function() {
        $('object, embed, iframe').each(function(item, index, all) {
          Parser[item.tagName.toLowerCase()](item);
        });
        if (_videos.length) {
          _highlightVideo();
        }
        else {
          alert("no supported video found :(");
        }
      },

      addVideo: function(url, type, details) {
        snack.JSONP({
          url: 'http://0.0.0.0:3000/queue/push/',
          key: 'callback',
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
    };
  })();
  
  function run() {
    Video.findVideo();
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
