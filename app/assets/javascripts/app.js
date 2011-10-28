var CatchLater = CatchLater || (function() {
  var $ = snack.wrap;
  
  $.define({
    setStyle: function(styles) {
      return this.each(function(element) {
        for (var i in styles) {
          if (styles.hasOwnProperty(i)) {
            element.style[i] = styles[i];
          }
        }
      });
    },
    html: function(html) {
      return this.each(function(element) {
        element.innerHTML = html;
      });
    }
  });

  var Parser = (function() {
    var _sources = {
      iframe: [
        { name: 'youtube', regex: /www\.youtube(-nocookie)?\.com\/embed\/([^&?\/]+)/ },
        { name: 'vimeo', regex: /player\.vimeo\.com\/video\/([0-9]+)/ },
        { name: 'blip', regex: /blip\.tv\/play\/([^.]+)\.html/ }
      ],
      object: {
        vimeo: { data: /\.vimeocdn\.com/, id: /clip_id=([0-9]+)/ },
        ted: { data: /video\.ted\.com/, id: /mp4:([^.]+\.mp4)/, decode: true }
      },
      embed: {
        youtube: [ { src: /ytimg.com/, id: /&video_id=([^&?]+)/ },
                   { src: /www\.youtube.com\/v\/([^&?\/]+)/ } ],
        vimeo: [ { src: /vimeo\.com\/[^0-9]+([0-9]+)/ } ]
      }
    },
    _checkIframeSrc = function(sources, el) {
      for (var src = el.src, match, i = 0; i < sources.length; i++) {
        if (match = sources[i].regex.exec(src)) {
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
          paramData = $('#' + el.id + ' param[name="flashvars"]')[0];
          paramData = ((source.decode) ? decodeURIComponent(paramData.value) : paramData.value);
          if (match = source.id.exec(paramData)) {
            return Video.foundVideo(el, {source: i, id: match[match.length - 1]});
          }
        }
      }
    },
    _checkEmbedData = function(sources, el) {
      var src = el.src, 
          source, match, i, j, paramData;
      for (i in sources) {
        if (sources.hasOwnProperty(i)) {
          source = sources[i];
          for (j = 0; j < source.length; j++) {
            if (match = source[j].src.exec(src)) {
              if (source[j].id) {
                paramData = el.getAttribute("flashvars");
                if (match = source[j].id.exec(paramData)) {
                  return Video.foundVideo(el, {source: i, id: match[match.length - 1]});
                }
              }
              else if (match.length > 1) {
                return Video.foundVideo(el, {source: i, id: match[match.length - 1]});
              }
            }
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
        return _checkEmbedData(_sources.embed, el);
      }
    };
  })(),
  
  UI = (function() {
    var _padding = 0;

    function _getXY(node) {
      var coords = {x: 0, y: 0, height: node.offsetHeight, width: node.offsetWidth};
      while (node) {
        coords.x += node.offsetLeft;
        coords.y += node.offsetTop;
        node = node.offsetParent;
      }
      return coords;
    }

    function _border(coords) {
      var border = document.createElement("div");
      $(border).setStyle({
        position: "absolute",
        padding: _padding + "px",
        boxShadow: "3px 3px 11px rgba(0,0,0,.4)",
        width: coords.width + "px",
        height: coords.height + "px",
        top: coords.y - _padding + "px",
        left: coords.x - _padding + "px",
        bottom: coords.y + coords.height + "px",
        right: coords.x + coords.width + "px",
        zIndex: 9999
      });
      return border;
    }

    function _prompt(coords, border) {
      var prompt = document.createElement("div");
      $(prompt).setStyle({
        backgroundColor: "rgba(50,50,50,.9)",
        boxShadow: "3px 3px 11px rgba(0,0,0,.4)",
        fontFamily: "'Lucida Grande', 'Lucida Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif",
        position: "absolute",
        height: "50px",
        width: coords.width + _padding + "px",
        left: border.style.left,
        top: parseInt(border.style.top, 10) - 50 + "px",
        zIndex: 10000
      });
      if (parseInt(prompt.style.top, 10) < 0) {
        prompt.style.top = border.style.bottom;
      }
      return prompt;
    }

    function _close(closeFunc) {
      var close = document.createElement("a");
      $(close).setStyle({
        color: "#FFF",
        textDecoration: "none",
        position: "absolute",
        top: "4px",
        right: "4px"
      }).html("✕");
      close.href = "#";
      snack.listener({
        node: close,
        event: "click"
      }, closeFunc);
      return close;
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
      }).html("Catch later");
      add.href = "#";
      var listen = snack.listener({
        node: add,
        event: "click"
      }, function(e) {
        snack.preventDefault(e);
        add.innerHTML = "Catching...";
        listen.detach();
        onClick(add);
      });
      return add;
    }

    return {
      drawPrompt: function(element, details) {
        var coords = _getXY((element.offsetHeight) ? element : element.parentNode),
            border = _border(coords),
            prompt = _prompt(coords, border),
            closeFunc = function() {
                border.parentNode.removeChild(border);
                prompt.parentNode.removeChild(prompt);
            },
            close = _close(function(e) {
              snack.preventDefault(e);
              closeFunc();
            }),
            add = _add(function(writeTo) {
              Video.addVideo(element.src, element.tagName.toLowerCase(), details, writeTo, closeFunc);
            });

        document.body.appendChild(border);
        document.body.appendChild(prompt);
        prompt.appendChild(close);
        prompt.appendChild(add);
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

      addVideo: function(url, type, details, writeTo, closePrompt) {
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
            writeTo.innerHTML = (resp.id) ? "Caught!" : resp;
            setTimeout(closePrompt, 1500);
        });
      }
    };
  })();
  
  function run() {
    Video.findVideo();
  }
  return new run();
  // var instance;
  
  // return function() {
  //   if (typeof instance === "undefined") {
  //     instance = new run();
  //   }
  //   // only run this bookmarklet once per page
  //   return instance;
  // };
})();
