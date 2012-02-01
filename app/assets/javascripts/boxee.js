if (!window.THE_BOXEE_BKMRKLT) window.THE_BOXEE_BKMRKLT = {
    server: 'boxee.tv',
    logged_in: false,
    username: false,
    tab_el: false,
    border_el: false,
    close_el: false,
    toolbar_el: false,
    styles_el: false,
    ip_popup: false,
    cur_video_id: false,
    services: [],
    videos: [],
    library_interval: false,
    init: function (options) {
        this.debug('init');
        this.services = options.services;
        this.logged_in = options.logged_in;
        this.username = options.username;
        this.server = options.server;
        this.toolbar_el = document.createElement('div');
        this.toolbar_el.id = 'bkmrklt_boxee_toolbar';
        this.toolbar_el.style.padding = '10px';
        this.toolbar_el.style.background = '#bddf33';
        this.toolbar_el.style.font = "bold 16px 'Myriad Pro', Helvetica";
        this.toolbar_el.style.position = 'absolute';
        this.toolbar_el.style.textAlign = 'left';
        this.toolbar_el.style.zIndex = 100000;
        this.toolbar_el.style.left = '5px';
        this.toolbar_el.innerHTML = 'Loading ...'
        document.body.appendChild(this.toolbar_el);
        if (!window.jQuery || jQuery.fn.jquery != '1.3.2') {
            this.importScript('http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.js');
            this.library_interval = setInterval(this.libraryCheck, 200);
        }
        else {
            this.start();
        }
    },
    start: function () {
        this.debug('start');
        if (jQuery.browser.msie) {
            this.logged_in = true;
            this.username = 'there';
        }
        this.findVideos();
        this.selectViewportVideo();
        if (this.videos.length == 0) {
            this.toolbar_el.style.top = (jQuery(window).scrollTop() + 5) + 'px';
            this.toolbar_el.innerHTML = '<span class="bkmrklt_boxee_close"  onclick="THE_BOXEE_BKMRKLT.toolbar_el.style.display = \'none\';">&times;</span><div style="width: 300px;">Sorry, Boxee couldn\'t find any videos on this page. <a class="info" href="http://' + this.server + '/bookmarklet/info" target="_blank">Click here for more info</a></div>';
            return false;
        }
        this.toolbar_el = jQuery('#bkmrklt_boxee_toolbar')[0];
        this.toolbar_el.style.display = 'none';
        if (!this.logged_in) this.login();
        if (this.logged_in && this.cur_video_id >= 0) {
            this.addToQueue(this.cur_video_id);
        }
        this.draw();
        jQuery(window).unbind('resize').unbind('scroll');
        jQuery(window).bind('scroll', {
            that: this
        }, this.onScroll);
        jQuery(window).bind('resize', {
            that: this
        }, this.onScroll);
        this.debug('events binded');
    },
    onScroll: function (e) {
        e.data.that.selectViewportVideo();
    },
    login: function () {
        jQuery('#bkmrklt_boxee_intro').html('Add to queue');
        jQuery('#bkmrklt_boxee_desc').html('<a href="http://' + this.server + '/auth?redirurl=/bookmarklet/loggedin" onclick="THE_BOXEE_BKMRKLT.loggingIn();" target="_blank">Log in</a> or <a href="http://' + this.server + '/signup" onclick="THE_BOXEE_BKMRKLT.loggingIn();" target="_blank">sign up</a> now');
        jQuery(window).bind('blur', {
            that: this
        }, this.windowOnBlur);
        jQuery(window).bind('focus', {
            that: this
        }, this.windowOnFocus);
        this.draw();
    },
    loggingIn: function () {
        jQuery('#bkmrklt_boxee_desc').html('<a href="javascript:void(0)" onclick="THE_BOXEE_BKMRKLT.loginCheck();">Click here once logged in</a>');
        this.draw();
    },
    loginCheck: function () {
        this.request('http://' + this.server + '/bookmarklet/login_check', {
            args: {
                callback: 'loginCheckResponse'
            }
        });
    },
    loginCheckResponse: function (is_logged_in, username) {
        if (is_logged_in) {
            jQuery(window).unbind('blur').unbind('focus');
            this.username = username;
            this.logged_in = true;
            this.start();
        }
        else {
            this.login();
        }
    },
    findVideos: function () {
        this.debug('Finding videos ...');
        this.videos_videos = false;
        var embeds_col = document.getElementsByTagName('embed');
        var objects = document.getElementsByTagName('object');
        var embeds = [];
        for (var i = 0; i < embeds_col.length; i++) {
            embeds.push(embeds_col[i]);
        }
        this.debug('Found ' + embeds_col.length + ' embeds and ' + objects.length + ' objects');
        for (var i = 0; i < objects.length; i++) {
            if ((!/<embed/i.test(objects[i].innerHTML) || embeds_col.length == 0) && (!/<object/i.test(objects[i].innerHTML) || jQuery.browser.msie)) {
                embeds.push(objects[i]);
            }
        }
        this.debug('Searching through ' + embeds.length + ' potential embeds');
        for (var i = 0; i < embeds.length; i++) {
            var str = this.getNodeValue(embeds[i], 'flashvars') + this.getNodeValue(embeds[i], 'src') + this.getNodeValue(embeds[i], 'data') + embeds[i].innerHTML + embeds[i].data + embeds[i].id;
            this.debug('\tEmbed videos: ', str);
            for (var j = 0; j < this.services.length; j++) {
                this.debug('\t\tSearching for ', this.services[j].domain, ' against ', this.services[j].regex);
                for (var k = 0; k < this.services[j].regex.length; k++) {
                    var r = new RegExp(this.services[j].regex[k]);
                    var domain_split = this.services[j].domain.split(',');
                    var valid_domain = false;
                    for (var l = 0; l < domain_split.length; l++) {
                        var domain_r = new RegExp(jQuery.trim(domain_split[l]));
                        if (domain_r.test(str) || domain_r.test(window.location)) {
                            valid_domain = true;
                            break;
                        }
                    }
                    if (r.test(str) && valid_domain) {
                        var pieces = r.exec(str);
                        var obj = jQuery(embeds[i]);
                        if (obj.width() == 0) obj = obj.parent();
                        this.debug('\t\t\t\tvideos: ', this.services[j].domain + ':' + pieces[1] + ' via ' + this.services[j].regex[k], obj);
                        if (pieces[1] == undefined) pieces[1] = window.location.href;
                        this.videos.push({
                            embed: obj,
                            service_id: this.services[j].id,
                            domain: this.services[j].domain,
                            id: decodeURIComponent(pieces[1])
                        });
                        break;
                    }
                }
            }
        }
        if (this.videos.length == 0) {
            for (j = 0; j < this.services.length; j++) {
                if (this.services[j].scrape_url == '') continue;
                var scrape_r = new RegExp(jQuery.trim(this.services[j].scrape_url));
                if (scrape_r.test(window.location)) {
                    this.debug('Scrapable url found despite lack of flash object. Add anyway. (Probably HTML5 page)');
                    var match = scrape_r.exec(window.location);
                    this.videos.push({
                        embed: false,
                        service_id: this.services[j].id,
                        domain: this.services[j].domain,
                        id: decodeURIComponent(match[1])
                    });
                    return;
                }
            }
        }
    },
    draw: function () {
        if (this.cur_video_id >= 0) {
            if (!this.logged_in) {} else if (this.videos[this.cur_video_id].adding_to_queue) {
                jQuery('#bkmrklt_boxee_intro').html('Hold on, ' + this.username);
                jQuery('#bkmrklt_boxee_desc').html('Adding to your Queue ...');
            }
            else if (this.videos[this.cur_video_id].added_to_queue) {
                jQuery('#bkmrklt_boxee_intro').html(this.videos[this.cur_video_id].meta.title);
                jQuery('#bkmrklt_boxee_desc').html('Added to your Queue!');
            }
            else {
                jQuery('#bkmrklt_boxee_intro').html('Hey ' + this.username + '!');
                jQuery('#bkmrklt_boxee_desc').html('Add to your Queue?');
            }
            jQuery('#bkmrklt_boxee_tab').css('display', '');
            jQuery('#bkmrklt_boxee_border').css('display', '');
            var target = this.videos[this.cur_video_id].embed;
            if (target !== false) {
                var pos = target.offset();
                var w = target.width();
                var h = target.height();
                var padding = 10;
                if (jQuery.browser.msie === true && this.tab_el.outerWidth() > 850) {
                    try {
                        this.tab_el[0].style.width = (w - 5 - padding * 4) + 'px';
                        this.tab_el[0].style.left = (pos.left - padding) + 'px';
                    }
                    catch (e) {}
                }
                else this.tab_el[0].style.left = (pos.left + w - this.tab_el.outerWidth() + padding) + 'px';
                var top = pos.top - this.tab_el.outerHeight();
                if (top < jQuery(window).scrollTop()) {
                    top = pos.top + h;
                }
                this.tab_el[0].style.top = top + 'px';
                this.border_el[0].style.left = (pos.left - padding) + 'px';
                this.border_el[0].style.top = (pos.top - padding) + 'px';
                this.border_el[0].style.width = w + 'px';
                this.border_el[0].style.height = h + 'px';
            }
            else {
                this.tab_el[0].style.left = '10px';
                this.tab_el[0].style.top = (jQuery(window).scrollTop() + 10) + 'px';
                this.border_el[0].style.display = 'none';
            }
        }
        else {
            this.hide();
        }
    },
    selectViewportVideo: function () {
        if (jQuery('#bkmrklt_boxee_tab').length == 0) {
            this.styles_el = document.createElement('style');
            this.styles_el.type = 'text/css';
            var css = "#bkmrklt_boxee_tab { background: url('http://" + this.server + "/htdocs/images/bookmarklet_boxee_logo.jpg') no-repeat 10px 10px; background-color: #bddf33; color: #333; padding: 5px 5px 15px 60px; position: absolute; cursor: pointer; z-index: 9999; height: 41px; }" + '#bkmrklt_boxee_border { border: 10px solid #bddf33; position: absolute; z-index: 9998; } ' + '.bkmrklt_boxee_wrap { float: left; margin: 6px 10px 0 0; }' + '#bkmrklt_boxee_intro { font: normal 12px \'Myriad Pro\', Helvetica; text-align: left; }' + '#bkmrklt_boxee_desc { font: bold 16px \'Myriad Pro\', Helvetica; text-align: left; } ' + '#bkmrklt_boxee_desc a { color: #336699; text-decoration: none; }' + '#bkmrklt_boxee_desc a:hover { color: #003366; }' + '.bkmrklt_boxee_close { font: bold 16px/14px Verdana; float: right; color: #333; text-decoration: none; width: 15px; height: 15px; padding:3px; overflow:hidden; -moz-border-radius: 5px; -webkit-border-radius: 5px; cursor: pointer; }' + '#bkmrklt_boxee_toolbar { color: #333; background: #bddf33; padding: 10px; font: bold 16px \'Myriad Pro\', Helvetica; }' + '#bkmrklt_boxee_toolbar a { color: #333; text-decoration: none; font: normal 12px \'Myriad Pro\', Helvetica; padding: 0; margin: 0; }' + '#bkmrklt_boxee_toolbar a.info { display: block; }';
            if (jQuery.browser.msie === true) this.styles_el.styleSheet.cssText = css;
            else jQuery(this.styles_el).html(css);
            document.body.appendChild(this.styles_el);
            var tab = document.createElement('div');
            tab.id = 'bkmrklt_boxee_tab';
            tab.innerHTML = '<div class="bkmrklt_boxee_close">&times;</div>' + '<div class="bkmrklt_boxee_wrap"><div id="bkmrklt_boxee_intro">Hey there</div>' + '<div id="bkmrklt_boxee_desc"></div></div>';
            document.body.appendChild(tab);
            var border = document.createElement('div');
            border.id = 'bkmrklt_boxee_border';
            border.innerHTML = '&nbsp;';
            document.body.appendChild(border);
        }
        this.cur_video_id = this.getViewportVideo();
        this.tab_el = jQuery('#bkmrklt_boxee_tab');
        this.border_el = jQuery('#bkmrklt_boxee_border');
        this.close_el = jQuery('div.bkmrklt_boxee_close');
        if (this.cur_video_id === false) {
            this.hide();
            return false;
        }
        else {
            this.show();
        }
        this.tab_el.unbind('click');
        this.close_el.unbind('click');
        this.border_el.unbind('click');
        this.border_el.bind('click', {
            that: this
        }, function (e) {
            e.data.that.close();
        });
        this.close_el.bind('click', {
            that: this
        }, function (e) {
            e.data.that.close();
        });
        this.tab_el.bind('click', {
            that: this,
            id: this.cur_video_id
        }, function (e) {
            if (e.data.that.logged_in) e.data.that.addToQueue(e.data.id);
        });
        this.draw();
    },
    getViewportVideo: function () {
        var w = jQuery(window).width();
        var h = jQuery(window).height();
        var y = jQuery(window).scrollTop();
        if (this.videos.length == 0) return false;
        if (this.videos.length == 1) return 0;
        for (var i = 0; i < this.videos.length; i++) {
            var pos = jQuery(this.videos[i].embed).offset();
            if (pos.top >= y && pos.top + 40 < y + h) {
                return i;
            }
        }
    },
    getNodeValue: function (obj, id) {
        var value = '';
        for (var i = 0; i < obj.attributes.length; i++) {
            if (obj.attributes[i].nodeName == id) {
                value += obj.attributes[i].nodeValue;
                break;
            }
        }
        var params = jQuery(obj).children('param');
        for (var i = 0; i < params.length; i++) {
            if (params[i].name == id) {
                value += params[i].value;
                break;
            }
        }
        return value;
    },
    addToQueue: function (i) {
        if (this.videos[i].added_to_queue) return false;
        if (jQuery.browser.msie) {
            var query = '?service_id=' + encodeURIComponent(this.videos[i].service_id) + '&id=' + encodeURIComponent(this.videos[i].id) + '&url=' + encodeURIComponent(window.location.href);
            var popup_url = 'http://' + this.server + '/bookmarklet/popup' + query
            this.debug('Opening ' + popup_url);
            this.ie_popup = window.open(popup_url, 'BOXEE_POPUP', 'height=430,width=850');
            if (!this.ie_popup) {
                alert('Uh oh! In order to use the Boxee Bookmarklet, you must Allow Pop-ups on this site.')
                return false;
            }
            this.videos[i].adding_to_queue = true;
            if (window.focus) this.ie_popup.focus();
            this.popup_interval = setInterval(this.addToQueuePopupResponse, 500);
            return false;
        }
        this.request('http://' + this.server + '/bookmarklet/queue/add', {
            args: {
                callback: 'addToQueueResponse',
                url: window.location.href,
                service_id: this.videos[i].service_id,
                id: this.videos[i].id == undefined ? '' : this.videos[i].id
            }
        });
        this.videos[i].adding_to_queue = true;
        this.draw();
    },
    popup_interval: false,
    addToQueuePopupResponse: function () {
        var that = THE_BOXEE_BKMRKLT;
        if (that.ie_popup.closed === true) {
            clearInterval(that.popup_interval);
            for (var i = 0; i < that.videos.length; i++) {
                if (that.videos[i].adding_to_queue == true) {
                    that.videos[i].added_to_queue = true;
                    that.videos[i].adding_to_queue = false;
                    that.videos[i].meta = {
                        title: 'Success!'
                    };
                    that.draw();
                    break;
                }
            }
        }
    },
    addToQueueResponse: function (service_id, url_id, meta) {
        for (var i = 0; i < this.videos.length; i++) {
            if (this.videos[i].service_id == service_id && this.videos[i].id == url_id) {
                this.videos[i].adding_to_queue = false;
                this.videos[i].added_to_queue = true;
                this.videos[i].meta = meta;
                break;
            }
        }
        this.draw();
        this.debug('addToQueueResponse', arguments);
    },
    close: function () {
        this.is_closed = true;
        this.hide();
        jQuery(window).unbind('resize').unbind('scroll').unbind('blur').unbind('focus');
    },
    hide: function () {
        this.tab_el.css('display', 'none');
        this.border_el.css('display', 'none');
    },
    show: function () {
        this.tab_el.css('display', '');
        this.border_el.css('display', '');
    },
    windowOnBlur: function (e) {},
    windowOnFocus: function (e) {
        e.data.that.loginCheck();
    },
    importScript: function (url) {
        this.debug('importScript: ' + url);
        try {
            var s = document.createElement('script');
            s.src = url + '?format=jsonp';
            document.body.appendChild(s);
        }
        catch (e) {}
    },
    libraryCheck: function () {
        if (window.jQuery != undefined) {
            THE_BOXEE_BKMRKLT.debug('jQuery loaded');
            jQuery.noConflict();
            clearInterval(THE_BOXEE_BKMRKLT.library_interval);
            THE_BOXEE_BKMRKLT.start();
        }
    },
    script: false,
    request: function (url, options) {
        if (this.script) {
            jQuery(this.script).remove();
            this.script = false;
        }
        if (!options.args) options.args = {};
        var args = '';
        for (i in options.args) {
            args += '&' + i + '=' + encodeURIComponent(options.args[i]);
        }
        this.script = document.createElement('script');
        this.script.type = 'text/javascript';
        this.script.src = url + '?' + args;
        document.body.appendChild(this.script);
    },
    debug_el: false,
    debug: function () {
        if (this.server == 'www.boxee.tv') return false;
        arguments[1] = arguments[1] === undefined ? '' : arguments[1];
        arguments[2] = arguments[2] === undefined ? '' : arguments[2];
        arguments[3] = arguments[3] === undefined ? '' : arguments[3];
        try {
            if (jQuery.browser.msie === true) {
                if (this.debug_el) {
                    this.debug_el.innerHTML = '<pre>' + arguments[0] + ' ' + arguments[1] + ' ' + arguments[2] + ' ' + arguments[3] + '</pre>' + this.debug_el.innerHTML;
                }
                else {
                    var e = document.createElement('div');
                    e.style.position = 'fixed';
                    e.style.bottom = '0px';
                    e.style.background = '#000';
                    e.style.height = '150px';
                    e.style.borderTop = '3px solid green';
                    e.style.color = '#fff';
                    e.style.padding = '10px;'
                    e.style.overflow = 'scroll';
                    e.style.font = 'normal 12px/12px "Courier New"';
                    e.style.textAlign = 'left';
                    this.debug_el = e;
                    document.body.appendChild(this.debug_el);
                }
            }
            else console.log(arguments[0], arguments[1], arguments[2], arguments[3]);
        }
        catch (e) {}
    }
}
THE_BOXEE_BKMRKLT.init({
    "logged_in": false,
    "username": false,
    "services": [{
        "id": "35",
        "domain": "adultswim.com",
        "scrape_url": "http:\\\/\\\/video\\.adultswim\\.com",
        "regex": ["tools\\\/swf\\\/sitevplayer.swf"]
    },
    {
        "id": "50",
        "domain": "abc.go.com",
        "scrape_url": "",
        "regex": ["VP2\\.swf"]
    },
    {
        "id": "56",
        "domain": "bbc.co.uk, news.bbc.co.uk",
        "scrape_url": "",
        "regex": ["http:\\\/\\\/cdnedge.bbc.co.uk\\\/player\\\/emp\\\/2.18.13034_14207\\\/9player.swf\\?revision=11798"]
    },
    {
        "id": "13",
        "domain": "blip.tv",
        "scrape_url": "http:\\\/\\\/(?:\\w+\\.)*blip\\.tv",
        "regex": ["flash\\\/showplayer\\.swf"]
    },
    {
        "id": "16",
        "domain": "break.com",
        "scrape_url": "http:\\\/\\\/(?:\\w+\\.)*break\\.com",
        "regex": ["sLink=(.*)&EmbedSEOLinkKeywords"]
    },
    {
        "id": "41",
        "domain": "brightcove.com",
        "scrape_url": false,
        "regex": ["brightcove.com\\\/services\\\/viewer"]
    },
    {
        "id": "54",
        "domain": "cbs.com",
        "scrape_url": "",
        "regex": ["rcpHolder"]
    },
    {
        "id": "21",
        "domain": "collegehumor.com",
        "scrape_url": "http:\\\/\\\/(?:\\w+\\.)*collegehumor\\.com\\\/video:([0-9]+)|http:\\\/\\\/(?:\\w+\\.)*collegehumor\\.com.*clip_id=([0-9]+)",
        "regex": ["videoid([0-9]+)", "clip_id=([0-9]+)"]
    },
    {
        "id": "52",
        "domain": "comedycentral.com, mtvnservices.com, media.mtvnservices.com",
        "scrape_url": "http:\\\/\\\/media\\.mtvnservices\\.com\\\/(.*?)",
        "regex": ["http:\\\/\\\/media\\.mtvnservices\\.com\\\/(mgid:cms:.*?:.*?\\.com:[0-9]+)"]
    },
    {
        "id": "22",
        "domain": "dailymotion.com",
        "scrape_url": "http:\\\/\\\/(?:\\w+\\.)*dailymotion\\.com\\\/video\\\/(.*)",
        "regex": ["videoId%22%3A%22([a-zA-Z0-9]+)", "dailymotion.com%2Fvideo%2F([a-zA-Z0-9]+)_", "dailymotion\\.com\\\/swf\\\/([a-zA-Z0-9]+)", "www.dailymotion.com\\\/video\\\/([a-zA-Z0-9]+)_"]
    },
    {
        "id": "51",
        "domain": "espn.com, espn.go.com",
        "scrape_url": "http:\\\/\\\/espn\\.go\\.com\\\/video\\\/clip\\?id=([0-9]+)&categoryid=([0-9]+)",
        "regex": ["ESPN_Player\\.swf\\?id=[0-9]+"]
    },
    {
        "id": "58",
        "domain": "fora.tv",
        "scrape_url": "",
        "regex": ["FORA_Player_5\\.ver_1_59\\.swf"]
    },
    {
        "id": "53",
        "domain": "funimation.com, player.hulu.com",
        "scrape_url": "http:\\\/\\\/www4\\.funimation\\.com\\\/video\\\/\\?page=video&v=(.*?)",
        "regex": ["videoTitle=.*?", "FUNimationVideo", "http:\\\/\\\/player\\.hulu\\.com\\\/express\\\/.*?"]
    },
    {
        "id": "26",
        "domain": "funnyordie.com,funnyordie.co.uk",
        "scrape_url": "http:\\\/\\\/(?:\\w+\\.)*funnyordie\\.com\\\/videos\\\/([a-zA-Z0-9]+)",
        "regex": ["key=([a-zA-Z0-9]+)"]
    },
    {
        "id": "27",
        "domain": "gametrailers.com",
        "scrape_url": false,
        "regex": ["mid=([0-9]+)", "%26id=([0-9]+)"]
    },
    {
        "id": "39",
        "domain": "video.google.com",
        "scrape_url": "",
        "regex": ["docid=([\\-0-9]+)"]
    },
    {
        "id": "24",
        "domain": "howcast.com",
        "scrape_url": "http:\\\/\\\/(?:\\w+\\.)*howcast\\.com\\\/videos\\\/(.*)",
        "regex": ["www.howcast.com\\\/videos\\\/([0-9]+)"]
    },
    {
        "id": "14",
        "domain": "hulu.com",
        "scrape_url": "http:\\\/\\\/(?:\\w+\\.)*hulu\\.com",
        "regex": ["stage_width=790&stage_height=368&"]
    },
    {
        "id": "38",
        "domain": "ign.com",
        "scrape_url": false,
        "regex": ["\"href\":\"(.*?)\""]
    },
    {
        "id": "37",
        "domain": "justin.tv",
        "scrape_url": false,
        "regex": ["channel=([a-zA-Z0-9_]+)"]
    },
    {
        "id": "59",
        "domain": "liveleak.com",
        "scrape_url": "http:\\\/\\\/www\\.liveleak\\.com\\\/view\\?i=(.*?)",
        "regex": ["http:\\\/\\\/www\\.liveleak\\.com\\\/e\\\/([a-zA-Z0-9]+_[a-zA-Z0-9]+)", "token%3D(.*?)%26"]
    },
    {
        "id": "57",
        "domain": "livestream.com",
        "scrape_url": "http:\\\/\\\/www\\.livestream\\.com\\\/(.*?)",
        "regex": ["allowChat=.*?&channel=(.*?)&id"]
    },
    {
        "id": "18",
        "domain": "metacafe.com",
        "scrape_url": "http:\\\/\\\/(?:\\w+\\.)*metacafe\\.com\\\/watch\\\/([^\\\/]*)",
        "regex": ["metacafe\\.com%2Fwatch%2F(.*?)&", "www.metacafe.com\\\/watch\\\/(.*?)\"", "itemID=([0-9]+)"]
    },
    {
        "id": "31",
        "domain": "motionbox.com",
        "scrape_url": false,
        "regex": ["videos%2F([a-zA-Z0-9]+)%2Fplayer_manifest", "video_uid=([a-zA-Z0-9]+)"]
    },
    {
        "id": "25",
        "domain": "mtv.com",
        "scrape_url": false,
        "regex": [":mtv.com:[0-9]+"]
    },
    {
        "id": "30",
        "domain": "vids.myspace.com",
        "scrape_url": false,
        "regex": ["&amp;el=(.*)&amp;on", "&el=(.*)&on"]
    },
    {
        "id": "46",
        "domain": "video.pbs.org",
        "scrape_url": "http:\\\/\\\/video\\.pbs\\.org\\\/video\\\/([0-9]+)",
        "regex": ["width=512&height=288&video=.*?\\\/([0-9]+)"]
    },
    {
        "id": "49",
        "domain": "revision3.com",
        "scrape_url": "http:\\\/\\\/revision3\\.com\\\/player-v([0-9]+)",
        "regex": ["player-v([0-9]+)"]
    },
    {
        "id": "33",
        "domain": "ted.com",
        "scrape_url": false,
        "regex": ["&amp;su=(http:\\\/\\\/www\\.ted\\.com.*?\\.html)&amp;", "&su=(http:\\\/\\\/www\\.ted\\.com.*?\\.html)&"]
    },
    {
        "id": "20",
        "domain": "theonion.com",
        "scrape_url": "",
        "regex": ["videoid=([0-9]+)"]
    },
    {
        "id": "34",
        "domain": "twit.tv, live.twit.tv",
        "scrape_url": "",
        "regex": ["TWiT.*?"]
    },
    {
        "id": "40",
        "domain": "vbs.tv",
        "scrape_url": false,
        "regex": ["permalink=(.*?)&", "&pl=(.*?)\""]
    },
    {
        "id": "19",
        "domain": "viddler.com",
        "scrape_url": "http:\\\/\\\/(?:\\w+\\.)*viddler\\.com.*\\\/videos\\.*",
        "regex": ["&key=([a-zA-Z0-9]+)", "viddler.com\\\/player\\\/([a-zA-Z0-9]+)"]
    },
    {
        "id": "1",
        "domain": "vimeo.com",
        "scrape_url": "http:\\\/\\\/(?:\\w+\\.)*vimeo\\.com\\\/([0-9]+)|http:\\\/\\\/(?:\\w+\\.)*vimeo\\.com.*clip_id=([0-9]+)",
        "regex": ["vimeo\\.com\\\/moogaloop\\.swf\\?clip_id=([0-9]+)", "clip_id=([0-9]+)&server=vimeo\\.com", "clip_id=([0-9]+)"]
    },
    {
        "id": "12",
        "domain": "youtube.com,youtube-nocookie.com",
        "scrape_url": "http:\\\/\\\/(?:\\w+\\.)*youtube\\.com.*v=([\\_\\-a-zA-Z0-9]+)",
        "regex": ["&video_id=([\\_\\-a-zA-Z0-9]+)", "youtube\\.com\/v\/([\\_\\-a-zA-Z0-9]+)", "youtube\\-nocookie\\.com\/v\/([\\_\\-a-zA-Z0-9]+)"]
    }],
    "server": "www.boxee.tv"
});