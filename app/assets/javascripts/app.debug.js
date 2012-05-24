!function(exports) {
  /*!
  * snack.js (c) Ryan Florence
  * https://github.com/rpflorence/snack
  * MIT License
  * Inspiration and code adapted from
  *  MooTools      (c) Valerio Proietti   MIT license
  *  jQuery        (c) John Resig         Dual license MIT or GPL Version 2
  *  contentLoaded (c) Diego Perini       MIT License
  *  Zepto.js      (c) Thomas Fuchs       MIT License
*/

if (typeof Object.create != 'function'){
  // ES5 Obeject.create
  Object.create = function (o){
    function F() {}
    F.prototype = o
    return new F
  }
}

!function(window){
  var snack = window.snack = {}
    , guid = 0
    , toString = Object.prototype.toString
    , indexOf = [].indexOf
    , push = [].push

  snack.extend = function (){
    if (arguments.length == 1)
      return snack.extend(snack, arguments[0])

    var target = arguments[0]

    for (var key, i = 1, l = arguments.length; i < l; i++)
      for (key in arguments[i])
        target[key] = arguments[i][key]

    return target
  }

  snack.extend({
    v: '1.2.4dev',

    bind: function (fn, context, args) {
      args = args || [];
      return function (){
        push.apply(args, arguments);
        return fn.apply(context, args)
      }
    },

    punch: function (obj, method, fn, auto){
      var old = obj[method]
      obj[method] = auto ? function (){
        old.apply(obj, arguments)
        return fn.apply(obj, arguments)
      } : function (){
        var args = [].slice.call(arguments, 0)
        args.unshift(snack.bind(old, obj))
        return fn.apply(obj, args)
      }
    },

    create: function (proto, ext){
      var obj = Object.create(proto)
      if (!ext)
        return obj

      for (var i in ext) {
        if (!ext.hasOwnProperty(i))
          continue

        if (!proto[i] || typeof ext[i] != 'function'){
          obj[i] = ext[i]
          continue
        }

        snack.punch(obj, i, ext[i])
      }

      return obj
    },

    id: function (){
      return ++guid
    },

    each: function (obj, fn, context){
      if (obj.length === void+0){ // loose check for object, we want array-like objects to be treated as arrays
        for (var key in obj)
          if (obj.hasOwnProperty(key))
            fn.call(context, obj[key], key, obj);
        return obj
      }

      for (var i = 0, l = obj.length; i < l; i++)
        fn.call(context, obj[i], i, obj)
      return obj
    },

    parseJSON: function(json) {
      // adapted from jQuery
      if (typeof json != 'string')
        return

      json = json.replace(/^\s+|\s+$/g, '')

      var isValid = /^[\],:{}\s]*$/.test(json.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, "@")
        .replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, "]")
        .replace(/(?:^|:|,)(?:\s*\[)+/g, ""))

      if (!isValid)
        throw "Invalid JSON"
      
      var JSON = window.JSON // saves a couple bytes
      return JSON && JSON.parse ? JSON.parse(json) : (new Function("return " + json))()
    },

    isArray: function (obj){
      return obj instanceof Array || toString.call(obj) == "[object Array]"
    },

    indexOf: indexOf ? function(item, array){
        return indexOf.call(array, item)
      } : function (item, array){
      for (var i = 0, l = array.length; i < l; i++)
        if (array[i] === item)
          return i

      return -1
    }
  })
}(window);
!function (snack, document){
  var proto = {}
    , query

  snack.wrap = function (nodes, context){
    // passed in a CSS selector
    if (typeof nodes == 'string')
      nodes = query(nodes, context)

    // passed in single node
    if (!nodes.length)
      nodes = [nodes]

    var wrapper = Object.create(proto)
      , i = 0
      , l = nodes.length

    for (; i < l; i++)
      wrapper[i] = nodes[i]

    wrapper.length = l
    wrapper.id = snack.id()
    return wrapper
  }

  snack.extend(snack.wrap, {
    define: function(name, fn){
      if (typeof name != 'string'){
        for (var i in name)
          snack.wrap.define(i, name[i])
        return
      }
      proto[name] = fn
    },

    defineEngine: function (fn){
      query = fn
    }
  })

  // QSA default selector engine, supports real browsers and IE8+
  snack.wrap.defineEngine(function (selector, context){
    if (typeof context == 'string')
      context = document.querySelector(context)

    return (context || document).querySelectorAll(selector)
  })
}(snack, document)
!function (snack, window, document){
  var add            = document.addEventListener ? 'addEventListener' : 'attachEvent'
    , remove         = document.addEventListener ? 'removeEventListener' : 'detachEvent'
    , prefix         = document.addEventListener ? '' : 'on'
    , ready          = false
    , top            = true
    , root           = document.documentElement
    , readyHandlers  = []

  snack.extend({
    stopPropagation: function (event){
      if (event.stopPropagation)
        event.stopPropagation()
      else
        event.cancelBubble = true
    },

    preventDefault: function (event){
      if (event.preventDefault)
        event.preventDefault()
      else
        event.returnValue = false
    }
  })

  snack.listener = function (params, handler){
    if (params.delegate){
      params.capture = true
      _handler = handler
      handler = function (event){
        // adapted from Zepto
        var target = event.target || event.srcElement
          , nodes = typeof params.delegate == 'string'
            ? snack.wrap(params.delegate, params.node)
            : params.delegate(params.node)

        while (target && snack.indexOf(target, nodes) == -1 )
          target = target.parentNode

        if (target && !(target === this) && !(target === document))
          _handler.call(target, event, target)
      }
    }

    if (params.context)
      handler = snack.bind(handler, params.context)

    var methods = {
      attach: function (){
        params.node[add](
          prefix + params.event,
          handler,
          params.capture
        )
      },

      detach: function (){
        params.node[remove](
          prefix + params.event,
          handler,
          params.capture
        )
      },

      fire: function (){
        handler.apply(params.node, arguments)
      }
    }

    methods.attach()

    return methods
  }




  snack.ready = function (handler){
    if (ready){
      handler.apply(document)
      return
    }
    readyHandlers.push(handler)
  }

  // adapted from contentloaded
  function init(e) {
    if (e.type == 'readystatechange' && document.readyState != 'complete')
      return

    (e.type == 'load' ? window : document)[remove](prefix + e.type, init, false)

    if (!ready && (ready = true))
      snack.each(readyHandlers, function (handler){
        handler.apply(document)
      })
  }

  function poll() {
    try {
      root.doScroll('left')
    } catch(e) { 
      setTimeout(poll, 50)
      return
    }
    init('poll')
  }

  if (document.createEventObject && root.doScroll) {
    try {
      top = !window.frameElement
    } catch(e) {}
    if (top)
      poll();
  }

  document[add](prefix + 'DOMContentLoaded', init, false)
  document[add](prefix + 'readystatechange', init, false)
  window[add](prefix + 'load', init, false)
}(snack, window, document);
!function (snack){
  snack.publisher = function (obj){
    var channels = {}
    obj = obj || {}

    snack.extend(obj, {
      subscribe: function (channel, handler, context){
        var subscription = {
          fn: handler,
          ctxt: (context || {})
        }

        if (!channels[channel])
          channels[channel] = []

        var publik = {
          attach: function (){
            channels[channel].push(subscription)
          },
          detach: function (){
            channels[channel].splice(snack.indexOf(handler, channels[channel]), 1)
          }
        }
        publik.attach()
        return publik
      },

      publish: function (channel, argsArray){
        if (!channels[channel])
          return false

        snack.each(channels[channel], function (subscription){
          subscription.fn.apply(subscription.ctxt, argsArray || [])
        })

        return channels[channel].length
      }
    })

    return obj
  }

  snack.publisher(snack)
}(snack);
!function(snack, window, document){
  snack.JSONP = function(params, callback){
    // adapted from Zepto
    var jsonpString = 'jsonp' + snack.id()
      , script = document.createElement('script')
      , running = false

      snack.JSONP[jsonpString] = function(data){
        running = false
        delete snack.JSONP[jsonpString]
        callback(data)
      }

      if (typeof params.data == 'object')
        params.data = snack.toQueryString(params.data)

    var publik = {
      send: function (){
        running = true
        script.src = params.url + '?' + params.key + '=snack.JSONP.' + jsonpString + '&' + params.data
        document.getElementsByTagName('head')[0].appendChild(script)
      },

      cancel: function (){
        running && script.parentNode && script.parentNode.removeChild(script)
        running = false
        snack.JSONP[jsonpString] = function (){
          delete snack.JSONP[jsonpString]
        }
      }
    }

    if (params.now !== false)
      publik.send()

    return publik
  }

  snack.toQueryString = function(object, base){
    // adapted from MooTools
    var queryString = []

    snack.each(object, function(value, key){
      if (base)
        key = base + '[' + key + ']'

      var result

      if (snack.isArray(value)){
        var qs = {}
        snack.each(value, function(val, i){
          qs[i] = val
        })
        result = snack.toQueryString(qs, key)
      }
      else if (typeof value == 'object')
        result = snack.toQueryString(value, key)
      else
        result = key + '=' + encodeURIComponent(value)

      if (value !== null)
        queryString.push(result)
    })

    return queryString.join('&')
  }

  var xhrObject = (function(){
    // adapted from MooTools
    var XMLHTTP = function(){
      return new XMLHttpRequest();
    }

    var MSXML2 = function(){
      return new ActiveXObject('MSXML2.XMLHTTP');
    }

    var MSXML = function(){
      return new ActiveXObject('Microsoft.XMLHTTP');
    }

    try {
      XMLHTTP()
      return XMLHTTP
    } catch (e){
      try {
        MSXML2()
        return MSXML2
      } catch (e){
        MSXML()
        return MSXML
      }
    }
  })();

  function empty(){}

  snack.request = function (options, callback){
    // adapted from MooTools
    if (!(this instanceof snack.request))
      return new snack.request(options, callback)

    var self = this
    self.options = snack.extend({}, self.options, options)
    self.callback = callback
    self.xhr = new xhrObject
    self.headers = self.options.headers
    if (self.options.now !== false)
      self.send()
  }

  snack.request.prototype = {

    options: {/*
      user: '',
      password: '',*/
      exception: empty,
      url: '',
      data: '',
      method: 'get',
      now: true,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'Accept': 'text/javascript, text/html, application/xml, text/xml, */*'
      },
      async: true,
      emulation: true,
      urlEncoded: true,
      encoding: 'utf-8'
    },

    onStateChange: function(){
      var self = this
        , xhr = self.xhr

      if (xhr.readyState != 4 || !self.running) return
      self.running = false
      self.status = 0

      try{
        var status = xhr.status
        self.status = (status == 1223) ? 204 : status
      } catch(e) {}

      xhr.onreadystatechange = empty;

      var args = self.status >= 200 && self.status < 300
        ? [false, self.xhr.responseText || '', self.xhr.responseXML]
        : [self.status]

      self.callback.apply(self, args)
    },
  
    setHeader: function(name, value){
      this.headers[name] = value;
      return this;
    },

    getHeader: function(name){
      try {
        return this.xhr.getResponseHeader(name)
      } catch(e) {
        return null
      }
    },
  
    send: function(){
      var self = this
        , options = self.options

      if (self.running) return self;

      self.running = true;

      var data = options.data || ''
        , url = String(options.url)
        , method = options.method.toLowerCase()

      if (typeof data != 'string')
        data = snack.toQueryString(data)

      if (options.emulation && snack.indexOf(method, ['get', 'post']) < 0){
        var _method = '_method=' + method
        data = (data) ? _method + '&' + data : _method
        method = 'post'
      }

      if (options.urlEncoded && snack.indexOf(method, ['post', 'put']) > -1){
        var encoding = (options.encoding) ? '; charset=' + options.encoding : ''
        self.headers['Content-type'] = 'application/x-www-form-urlencoded' + encoding
      }

      if (!url)
        url = document.location.pathname

      var trimPosition = url.lastIndexOf('/')
      if (trimPosition > -1 && (trimPosition = url.indexOf('#')) > -1)
        url = url.substr(0, trimPosition)

      if (data && method == 'get'){
        url += (url.indexOf('?') > -1 ? '&' : '?') + data
        data = null
      }

      var xhr = self.xhr

      xhr.open(method.toUpperCase(), url, options.async, options.user, options.password)
      if (options.user && 'withCredentials' in xhr) xhr.withCredentials = true
    
      xhr.onreadystatechange = snack.bind(self.onStateChange, self)

      for (var i in self.headers){
        try {
          xhr.setRequestHeader(i, self.headers[i])
        } catch (e){
          options.exception.apply(self, [i, self.headers[i]])
        }
      }

      xhr.send(data)
      if (!options.async) self.onStateChange()
    
      return self
    },

    cancel: function(){
      var self = this

      if (!self.running)
        return self

      self.running = false

      var xhr = self.xhr
      xhr.abort()

      xhr.onreadystatechange = empty

      self.xhr = new xhrObject()
      return self
    }
  }
}(snack, window, document)
!function(snack, document){
  snack.wrap.define({
    data: function (){
      // API inspired by jQuery
      var storage = {}

      return function (key, value){
        var data = storage[this.id]

        if (!data)
          data = storage[this.id] = {}

        if (value === void+1)
          return data[key]

        return data[key] = value
      }  
    }(),

    each: function (fn, context){
      return snack.each(this, fn, context)
    },
  
    addClass: function (className){
      // adapted from MooTools
      return this.each(function (element){
        if (clean(element.className).indexOf(className) > -1)
          return
        element.className = clean(element.className + ' ' + className)
      })
    },

    removeClass: function (className){
      // adapted from MooTools
      return this.each(function (element){
        element.className = element.className.replace(new RegExp('(^|\\s)' + className + '(?:\\s|$)'), '$1')
      })
    },

    attach: function (event, handler, /* internal */ delegation){
      var split = event.split('.')
        , listeners = []

      if (split[1])
        listeners = this.data(split[1]) || []

      this.each(function(node){
        var params = {
          node: node,
          event: split[0]
        }

        if (delegation)
          params.delegate = delegation

        listeners.push(snack.listener(params, handler))
      })

      if (split[1])
        this.data(split[1], listeners)

      return this
    },

    detach: function (namespace){
      listenerMethod(this, 'detach', namespace, null, true)
      this.data(namespace, null)
      return this
    },

    fire: function (namespace, args){
      return listenerMethod(this, 'fire', namespace, args)
    },

    delegate: function (event, delegation, handler){
      return this.attach(event, handler, delegation)
    }
  })

  function clean(str){
    return str.replace(/\s+/g, ' ').replace(/^\s+|\s+$/g, '')
  }

  function listenerMethod(wrapper, method, namespace, args){
    var data = wrapper.data(namespace)

    if (data)
      snack.each(data, function (listener){
        listener[method].apply(wrapper, args)
      })

    return wrapper
  }
}(snack, document);
/*!
  * Qwery - A Blazing Fast query selector engine
  * https://github.com/ded/qwery
  * copyright Dustin Diaz & Jacob Thornton 2011
  * MIT License
  */

!function (context, doc) {

  var c, i, j, k, l, m, o, p, r, v,
      el, node, len, found, classes, item, items, token,
      id = /#([\w\-]+)/,
      clas = /\.[\w\-]+/g,
      idOnly = /^#([\w\-]+$)/,
      classOnly = /^\.([\w\-]+)$/,
      tagOnly = /^([\w\-]+)$/,
      tagAndOrClass = /^([\w]+)?\.([\w\-]+)$/,
      html = doc.documentElement,
      normalizr = /\s*([\s\+\~>])\s*/g,
      tokenizr = /([\s\>\+\~])(?![\s\w\-\/\?\&\=\:\.\(\)\!,@#%<>\{\}\$\*\^'"]*\])/,
      specialChars = /([.*+?\^=!:${}()|\[\]\/\\])/g,
      simple = /^([a-z0-9]+)?(?:([\.\#]+[\w\-\.#]+)?)/,
      attr = /\[([\w\-]+)(?:([\|\^\$\*\~]?\=)['"]?([ \w\-\/\?\&\=\:\.\(\)\!,@#%<>\{\}\$\*\^]+)["']?)?\]/,
      chunker = new RegExp(simple.source + '(' + attr.source + ')?'),
      walker = {
    ' ': function (node) {
      return node && node !== html && node.parentNode
    },
    '>': function (node, contestant) {
      return node && node.parentNode == contestant.parentNode && node.parentNode;
    },
    '~': function (node) {
      return node && node.previousSibling;
    },
    '+': function (node, contestant, p1, p2) {
      if (!node) {
        return false;
      }
      p1 = previous(node);
      p2 = previous(contestant);
      return p1 && p2 && p1 == p2 && p1;
    }
  };

  function cache() {
    this.c = {};
  }
  cache.prototype = {
    g: function (k) {
      return this.c[k] || undefined;
    },
    s: function (k, v) {
      this.c[k] = v;
      return v;
    }
  };

  var classCache = new cache(),
      cleanCache = new cache(),
      attrCache = new cache(),
      tokenCache = new cache();

  function array(ar) {
    r = [];
    for (i = 0, len = ar.length; i < len; i++) {
      r[i] = ar[i];
    }
    return r;
  }

  function previous(n) {
    while (n = n.previousSibling) {
      if (n.nodeType == 1) {
        break;
      }
    }
    return n
  }

  function q(query) {
    return query.match(chunker);
  }

  function interpret(whole, tag, idsAndClasses, wholeAttribute, attribute, qualifier, value) {
    var m, c, k;
    if (tag && this.tagName.toLowerCase() !== tag) {
      return false;
    }
    if (idsAndClasses && (m = idsAndClasses.match(id)) && m[1] !== this.id) {
      return false;
    }
    if (idsAndClasses && (classes = idsAndClasses.match(clas))) {
      for (i = classes.length; i--;) {
        c = classes[i].slice(1);
        if (!(classCache.g(c) || classCache.s(c, new RegExp('(^|\\s+)' + c + '(\\s+|$)'))).test(this.className)) {
          return false;
        }
      }
    }
    if (wholeAttribute && !value) {
      o = this.attributes;
      for (k in o) {
        if (Object.prototype.hasOwnProperty.call(o, k) && (o[k].name || k) == attribute) {
          return this;
        }
      }
    }
    if (wholeAttribute && !checkAttr(qualifier, this.getAttribute(attribute) || '', value)) {
      return false;
    }
    return this;
  }

  function clean(s) {
    return cleanCache.g(s) || cleanCache.s(s, s.replace(specialChars, '\\$1'));
  }

  function checkAttr(qualify, actual, val) {
    switch (qualify) {
    case '=':
      return actual == val;
    case '^=':
      return actual.match(attrCache.g('^=' + val) || attrCache.s('^=' + val, new RegExp('^' + clean(val))));
    case '$=':
      return actual.match(attrCache.g('$=' + val) || attrCache.s('$=' + val, new RegExp(clean(val) + '$')));
    case '*=':
      return actual.match(attrCache.g(val) || attrCache.s(val, new RegExp(clean(val))));
    case '~=':
      return actual.match(attrCache.g('~=' + val) || attrCache.s('~=' + val, new RegExp('(?:^|\\s+)' + clean(val) + '(?:\\s+|$)')));
    case '|=':
      return actual.match(attrCache.g('|=' + val) || attrCache.s('|=' + val, new RegExp('^' + clean(val) + '(-|$)')));
    }
    return 0;
  }

  function _qwery(selector) {
    var r = [], ret = [], i, j = 0, k, l, m, p, token, tag, els, root, intr, item,
        tokens = tokenCache.g(selector) || tokenCache.s(selector, selector.split(tokenizr));
    tokens = tokens.slice(0); // this makes a copy of the array so the cached original is not effected

    if (!tokens.length) {
      return r;
    }

    token = tokens.pop();
    root = tokens.length && (m = tokens[tokens.length - 2].match(idOnly)) ? doc.getElementById(m[1]) : doc;
    if (!root) {
      return r;
    }
    intr = q(token);
    els = /^[+~]$/.test(tokens[tokens.length - 1]) ? function (r) {
        r = []
        while (root = root.nextSibling) {
          root.nodeType == 1 && (intr[1] ? intr[1] == root.tagName.toLowerCase() : 1) && r.push(root)
        }
        return r
      }() :
      root.getElementsByTagName(intr[1] || '*');
    for (i = 0, l = els.length; i < l; i++) {
      if (item = interpret.apply(els[i], intr)) {
        r[j++] = item;
      }
    }

    if (!tokens.length) {
      return r;
    }

    // loop through all descendent tokens
    for (j = 0, l = r.length, k = 0; j < l; j++) {
      p = r[j];
      // loop through each token backwards crawling up tree
      for (i = tokens.length - 2; i >= 0;i = i - 2) {
        // loop through parent nodes
        while (p = walker[tokens[i + 1]](p, r[j])) {
          if (found = interpret.apply(p, q(tokens[i]))) {
            break;
          }
        }
      }
      found && (ret[k++] = r[j]);
    }
    return ret;
  }

  function boilerPlate(selector, _root, fn) {
    var root = (typeof _root == 'string') ? fn(_root)[0] : (_root || doc);
    if (selector === window || isNode(selector)) {
      return !_root || (selector !== window && isNode(root) && isAncestor(selector, root)) ? [selector] : [];
    }
    if (selector && typeof selector === 'object' && isFinite(selector.length)) {
      return array(selector);
    }
    if (m = selector.match(idOnly)) {
      return (el = doc.getElementById(m[1])) ? [el] : [];
    }
    if (m = selector.match(tagOnly)) {
      return array(root.getElementsByTagName(m[1]));
    }
    return false;
  }

  function isNode(el) {
    return (el && el.nodeType && (el.nodeType == 1 || el.nodeType == 9));
  }

  function uniq(ar) {
    var a = [], i, j;
    label:
    for (i = 0; i < ar.length; i++) {
      for (j = 0; j < a.length; j++) {
        if (a[j] == ar[i]) {
          continue label;
        }
      }
      a[a.length] = ar[i];
    }
    return a;
  }

  function qwery(selector, _root) {
    var root = (typeof _root == 'string') ? qwery(_root)[0] : (_root || doc);
    if (!root || !selector) {
      return [];
    }
    if (m = boilerPlate(selector, _root, qwery)) {
      return m;
    }
    return select(selector, root);
  }

  var isAncestor = 'compareDocumentPosition' in html ?
    function (element, container) {
      return (container.compareDocumentPosition(element) & 16) == 16;
    } : 'contains' in html ?
    function (element, container) {
      container = container == doc || container == window ? html : container;
      return container !== element && container.contains(element);
    } :
    function (element, container) {
      while (element = element.parentNode) {
        if (element === container) {
          return 1;
        }
      }
      return 0;
    },

  select = (doc.querySelector && doc.querySelectorAll) ?
    function (selector, root) {
      if (doc.getElementsByClassName && (m = selector.match(classOnly))) {
        return array((root).getElementsByClassName(m[1]));
      }
      return array((root).querySelectorAll(selector));
    } :
    function (selector, root) {
      selector = selector.replace(normalizr, '$1');
      var result = [], collection, collections = [], i;
      if (m = selector.match(tagAndOrClass)) {
        items = root.getElementsByTagName(m[1] || '*');
        r = classCache.g(m[2]) || classCache.s(m[2], new RegExp('(^|\\s+)' + m[2] + '(\\s+|$)'));
        for (i = 0, l = items.length, j = 0; i < l; i++) {
          r.test(items[i].className) && (result[j++] = items[i]);
        }
        return result;
      }
      for (i = 0, items = selector.split(','), l = items.length; i < l; i++) {
        collections[i] = _qwery(items[i]);
      }
      for (i = 0, l = collections.length; i < l && (collection = collections[i]); i++) {
        var ret = collection;
        if (root !== doc) {
          ret = [];
          for (j = 0, m = collection.length; j < m && (element = collection[j]); j++) {
            // make sure element is a descendent of root
            isAncestor(element, root) && ret.push(element);
          }
        }
        result = result.concat(ret);
      }
      return uniq(result);
    };

  qwery.uniq = uniq;
  var oldQwery = context.qwery;
  qwery.noConflict = function () {
    context.qwery = oldQwery;
    return this;
  };
  context['qwery'] = qwery;

}(this, document);snack.qwery = qwery.noConflict()
snack.wrap.defineEngine(function (selector, context){
  return snack.qwery(selector, context);
})

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
  
  // Modules
  var Parser, UI, Video;
  Parser = (function() {
    var _sources = {
      iframe: [
        { name: 'youtube', regex: /www\.youtube(-nocookie)?\.com\/embed\/([^&?\/]+)/ },
        { name: 'vimeo', regex: /player\.vimeo\.com\/video\/([0-9]+)/ },
        { name: 'npr', regex: /npr\.org\/templates\/event\/embeddedVideo.php\?storyId=([0-9]+)/ },
        { name: 'gamespot', regex: /gamespot\.com\/videoembed\/([0-9]+)/ },
        { name: 'mtv', regex: /media\.mtvnservices\.com\/[a-z:.]+([0-9]+)/ },
        { name: 'dailymotion', regex: /www\.dailymotion\.com\/embed\/video\/([A-Za-z0-9\-])+/ },
        { name: 'fora', regex: /fora\.tv\/embed\?id=([0-9]+)/ }
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
        vimeo: [ { src: /vimeo\.com\/[^0-9]+([0-9]+)/ } ],
        mtv: [ { src: /media\.mtvnservices\.com\/[a-z:.]+([0-9]+)/ } ],
        dailymotion: [ { src: /dmcdn.net\/flash\/dmplayer/, id: /"videoUniqueURL":"http:\\\/\\\/www\.dailymotion\.com\\\/video\\\/([A-Za-z0-9\-_]+)/, decode: true } ],
        fora: [ { src: /FORA_Player/, id: /clipid=([0-9]+)/ } ]
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
                if (source[j].decode) {
                  paramData = decodeURIComponent(paramData);
                }
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
            return {source: i, id: el.getAttribute(source.attr)};
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
        link.href = 'http://catchlater.com/signin';
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
          url: 'http://0.0.0.0:3000/videos/bookmark/',
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
  };
  var instance;
  
  exports.CatchLater = function() {
    // Only run this bookmarklet once per page
    if (typeof instance === "undefined") {
      instance = new run();
    }
  };
}(this)
