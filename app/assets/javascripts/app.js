var CatchLater = CatchLater || (function() {
  var $ = snack.wrap;
  // Modules
  var Parser, UI, Video;
  
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

  Parser = (function() {
    var _sources = {
      iframe: [
        { name: 'youtube', regex: /www\.youtube(-nocookie)?\.com\/embed\/([^&?\/]+)/ },
        { name: 'vimeo', regex: /player\.vimeo\.com\/video\/([0-9]+)/ },
        { name: 'npr', regex: /npr\.org\/templates\/event\/embeddedVideo.php\?storyId=([0-9]+)/ },
        { name: 'gamespot', regex: /gamespot\.com\/videoembed\/([0-9]+)/ }
      ],
      object: {
        vimeo: { data: /\.vimeocdn\.com/, id: /clip_id=([0-9]+)/ },
        ted: { data: /video\.ted\.com/, id: /mp4:([^.]+\.mp4)/, decode: true },
        npr: { data: /media\.npr\.org/, id: /\?storyId=([0-9]+)/, decode: true },
        gamespot: { data: /image\.com\.com\/gamespot\/images/, id: /\?id=([0-9]+)/, decode: true }
      },
      embed: {
        youtube: [ { src: /ytimg.com/, id: /&video_id=([^&?]+)/ },
                   { src: /www\.youtube.com\/v\/([^&?\/]+)/ } ],
        vimeo: [ { src: /vimeo\.com\/[^0-9]+([0-9]+)/ } ]
      },
      video: {
        youtube: { src: /.*\.youtube\.com/, attr: 'data-youtube-id' }
      }
    },
    _checkIframeSrc = function(sources, el) {
      for (var src = el.src, match, i = 0; i < sources.length; i++) {
        if (match = sources[i].regex.exec(src)) {
          return {source: sources[i].name, id: match[match.length - 1]};
        }
      }
    },
    _checkObjectData = function(sources, el) {
      var data = el.data, 
          source, match, i, paramData;
      for (i in sources) {
        source = sources[i];
        if (sources.hasOwnProperty(i) && (match = source.data.exec(data))) {
          paramData = $('#' + el.id + ' param[name="flashvars"], #' + el.id + ' param[name="flashVars"]')[0];
          paramData = ((source.decode) ? decodeURIComponent(paramData.value) : paramData.value);
          if (match = source.id.exec(paramData)) {
            return {source: i, id: match[match.length - 1]};
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
                  return {source: i, id: match[match.length - 1]};
                }
              }
              else if (match.length > 1) {
                return {source: i, id: match[match.length - 1]};
              }
            }
          }
        }
      }
    },
    _checkVideoData = function(sources, el) {
      var src = el.src, source, i, match;
      for (i in sources) {
        if (sources.hasOwnProperty(i)) {
          source = sources[i];
          if (sources.hasOwnProperty(i) && (match = source.src.exec(src))) {
            return {source: i, id: el[source.attr]};
          }
        }
      }
    };
    return {
      selector: 'object, embed, iframe, video',
      iframe: function(el) {
        return _checkIframeSrc(_sources.iframe, el);
      },
      object: function(el) {
        return _checkObjectData(_sources.object, el);
      },
      embed: function(el) {
        return _checkEmbedData(_sources.embed, el);
      },
      video: function(el) {
        return _checkVideoData(_sources.video, el);
      }
    };
  })();
  
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
        right: coords.x + coords.width + "px"
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

    function _close() {
      var close = document.createElement("a");
      $(close).setStyle({
        color: "#FFF",
        textDecoration: "none",
        position: "absolute",
        top: "4px",
        right: "4px"
      }).html('&#215;');
      close.href = "#";
      return close;
    }

    function _add() {
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
      return add;
    }
        
    function prompt(element, details) {
      var coords = _getXY((element.offsetHeight) ? element : element.parentNode);
      
      this.border = _border(coords);
      this.prompt = _prompt(coords, this.border);
      this.close = _close();
      this.add = _add();

      snack.listener({
        node: this.close,
        event: "click"
      }, this.bind(function(e) {
          snack.preventDefault(e);
          this.destroy();        
      }));

      document.body.appendChild(this.border);
      document.body.appendChild(this.prompt);
      this.prompt.appendChild(this.close);
      this.prompt.appendChild(this.add);      
    }
    prompt.prototype = {
      destroy: function() {
        this.border.parentNode.removeChild(this.border);
        this.border = null;
        this.prompt.parentNode.removeChild(this.prompt);
        this.prompt = null;
      },
      bind: function(func) {
        var _this = this;
        return function() {
          func.apply(_this, arguments);
        }
      },
      onAdd: function(func) {
        var listen = snack.listener({
          node: this.add,
          event: "click"
        }, this.bind(function(e) {
          snack.preventDefault(e);
          listen.detach();
          this.addText('Catching...');
          func.call(this);
        }));
      },
      addText: function(text) {
        this.add.innerHTML = text;
      },
      addLoginLink: function() {
        var link = document.createElement('a');
        $(link).setStyle({
          background: '#000',
          color: '#FFF',
          textDecoration: 'underline',
          padding: '3px',
          position: 'absolute',
          top: '30%',
          right: '40%',
          fontSize: '16px',
          zIndex: 1
        });
        link.target = '_blank';
        link.href = 'http://0.0.0.0:3000/signin';
        link.innerHTML = 'Log in real quick \u2192';
        this.addText('Oops... You aren\'t logged in');
        this.add.parentNode.insertBefore(link, this.add);
        snack.listener({
          node: link,
          event: 'click'
        }, this.bind(function() {
            link.parentNode.removeChild(link);
            this.addText('Catch later');
        }));
      }
    };
    
    return {prompt: prompt};
  })();
  
  Video = (function() {
    var _videos = [];
    
    function _highlightVideo() {
      var i = 0;
      $(_videos).each(function(item) {
        new UI.prompt(item.video, item.details).onAdd(function() {
          Video.addVideo(item.video.src, item.video.tagName.toLowerCase(), item.details, this);
        });
        i++;
      });
      return i;
    }
    
    function _foundVideo(video, details) {
      if (video && video.tagName && details && details.id && details.source) {
        _videos.push({video: video, details: details});
      }
    }
    
    return {
      findVideo: function() {
        $(Parser.selector).each(function(item, index, all) {
          _foundVideo(item, Parser[item.tagName.toLowerCase()](item));
        });
        if (!_highlightVideo()) {
          alert("no supported video found :(");
        }
      },

      addVideo: function(url, type, details, prompt) {
        var request = {
          url: url,
          type: type,
          source: details.source,
          videoID: details.id,
          webpageUrl: window.top.location.href
        };
        snack.JSONP({
          url: 'http://0.0.0.0:3000/queue/push/',
          key: 'callback',
          data: request
        }, function(resp) {
            if (resp.login_required) {
              prompt.addLoginLink();
              prompt.onAdd(function() {
                Video.addVideo(url, type, details, prompt);
              });
            }
            else {
              prompt.addText((resp.id) ? 'Caught!' : resp);
              setTimeout(prompt.destroy(), 1500);
            }
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
