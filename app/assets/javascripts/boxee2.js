/*global Handlebars _ */
window.BoxeeWatchLaterRunner = {
  init: function(jQuery, SERVER, logged_in) {
    var _ = window._.noConflict();
    
    return (function($) {
      
      var BoxeeWatchLater, Video = function(service, video_id) {
        this.service = service || '';
        this.video_id = video_id;
      };
      
      var EMBEDLY_TIMEOUT = 4000;
      
      Video.prototype = {
        title: '',
        description: '',
        thumbnail_url: '',
        
        service: '',
        video_id: '',
        playback_url: '',
        found_on_url: document.location.toString(),
        index: null,
        
        $video: null,
        
        action_index: null,
        added: false,
        removed: false,
        
        ajax_in_progress: false,
        
        get_add_params: function() {
          return {
            title: this.title,
            description: this.description,
            thumbnail_url: this.thumbnail_url,
            playback_url: this.playback_url,
            found_on_url: this.found_on_url,
            service: this.service,
            video_id: this.video_id,
            url: this.playback_url || this.found_on_url
          };
        },
        
        show_as_added: function() {
          if (this.$video) {
            this.$video.addClass('boxee-video-added');
          }
        },
        
        show_as_removed: function() {
          if (this.$video) {
            this.$video.removeClass('boxee-video-added');
          }
        },
        
        show_as_loading: function() {
          if (this.$video) {
            this.$video.addClass('boxee-video-loading');
          }
          setTimeout(_.bind(this.show_as_still_loading, this), 1000);
        },
        
        show_as_still_loading: function() {
          if (this.$video && this.$video.hasClass('boxee-video-loading')) {
            this.$video.addClass('boxee-video-still-loading');
          }          
        },
        
        show_as_not_loading: function() {
          if (this.$video) {
            this.$video.removeClass('boxee-video-loading boxee-video-still-loading');
          }          
        },
        
        add_to_queue: function() {
          if (this.ajax_in_progress) {
            return false;
          } else {
            this.ajax_in_progress = true;
            this.show_as_loading();
          }
          
          $.getJSON(SERVER + 'queue/addtoqueue2?' + $.param(this.get_add_params()) + "&format=jsonp&callback=?",
            _.bind(this.add_to_queue_callback, this)
          );
        },
        
        add_to_queue_callback: function(response) {
          this.ajax_in_progress = false;
          this.show_as_not_loading();
          this.action_index = response.action_index;
          this.show_as_added();
        },
        
        undo_add_to_queue: function() {
          if (this.ajax_in_progress || !this.action_index) {
            return false;
          } else {
            this.ajax_in_progress = true;
            this.show_as_loading();
          }
          
          var data = {action_index: this.action_index};
          this.action_index = null;
          
          $.getJSON(SERVER + 'queue/undoaddtoqueue?' + $.param(data) + "&format=jsonp&callback=?",
            _.bind(this.undo_add_to_queue_callback, this)
          );
        },
        
        undo_add_to_queue_callback: function(response) {
          this.ajax_in_progress = false;
          this.show_as_not_loading();
          if (response.deleted || response.missing) {
            this.action_index = null;
            this.show_as_removed();
          }
        },
        
        add_or_remove_from_queue: function() {
          if (this.action_index) {
            this.undo_add_to_queue();
          } else {
            this.add_to_queue();
          }
        },
        
        draw: function($container, template) {
          $container.append(template(this));
          this.$video = $container.find('.boxee-video-item[data-index=' + this.index + ']');
          if (this.ajax_in_progress) {
            this.show_as_loading();
          }
          this.setup_behavior();
          this.get_short_url();
        },
        
        thumbnail_click_handler: function(event) {
          event.stopPropagation();
          this.add_or_remove_from_queue();
        },
        
        get_short_url: function() {
          if (!this.short_url) {
            var url = this.playback_url || this.found_on_url;
            var video = this;
            $.getJSON(SERVER + 'api/shortenurl?url=' + encodeURIComponent(url) + "&format=jsonp&callback=?",
              function(response) {
                video.short_url = response.short_url;
              }
            );
          }
        },
        
        fb_click_handler: function() {
          // facebook can decode the short url - ignores it
          window.open("http://facebook.com/sharer.php?u=" +
            encodeURIComponent(this.short_url || this.playback_url || this.found_on_url),
            'sharer','toolbar=0,status=0,resizable=1,width=626,height=436')
        },
        
        twitter_click_handler: function() {
          window.open("http://twitter.com/intent/tweet?" +
            "text=" + 
            encodeURIComponent("Loved ") +
            encodeURIComponent(this.title + " ") +
            encodeURIComponent(this.short_url || this.playback_url || this.found_on_url) +
            "&via=boxee",
            'sharer','toolbar=0,status=0,resizable=1,width=626,height=436');
        },
        
        tumblr_click_handler: function() {
          // Don't use short url here - tumblr can't handle it nicely
          window.open("http://www.tumblr.com/share?v=3&u=" +
            encodeURIComponent(this.playback_url || this.found_on_url),
            'sharer','toolbar=0,status=0,resizable=1,width=626,height=436');
        },
        
        setup_behavior: function() {
          this.$video.find('.boxee-video-block').click(
            _.bind(this.thumbnail_click_handler, this)
          );
          this.$video.find('.boxee-video-fb-share').click(
            _.bind(this.fb_click_handler, this)
          );
          this.$video.find('.boxee-video-twitter-share').click(
            _.bind(this.twitter_click_handler, this)
          );
          this.$video.find('.boxee-video-tumblr-share').click(
            _.bind(this.tumblr_click_handler, this)
          );
        }
      };
      
      BoxeeWatchLater = {
        results: {
          youtube: [],
          vimeo: [],
          tumblr: [],
          ooyala: [],
          brightcove: [],
          blip: [],
          viddler: [],
          
          videos: [],
          embedly: null,
          
          page: {
            thumbnails: [],
            descriptions: [],
            titles: []
          }
        },
        
        services: ['youtube', 'vimeo', 'tumblr', 'ooyala', 'brightcove', 'blip', 'viddler'],
        
        templates: {},
        
        setup_templates: function() {
          BoxeeWatchLater.templates.video = Handlebars.compile($('#boxee-template-video').html());
        },
        
        setup_behavior: function() {
          $(".boxee-close-button").click(function() {
            BoxeeWatchLater.remove_now();
          });
          $("#boxee-add-page").click(_.once(BoxeeWatchLater.add_page));
          $("#boxee-dont-add-it").click(BoxeeWatchLater.undo_add_page);
        },
        
        fade_now: function() {
          $("#boxee-watch-later-wrapper").animate({height: "0px"}, 350, 'swing', function() {
            BoxeeWatchLater.remove_now();
          });
          
          $("#boxee-page-spacer").animate({height: "0px"}, 350, 'swing', function() {});
        },
        
        remove_now: function() {
          $("#boxee-watch-later-wrapper").remove();
          $("#boxee-page-spacer").remove();
          
          BoxeeWatchLater.clear_intervals();
        },
        
        fade_eventually: function() {
          $("#boxee-watch-later").mouseenter(_.throttle(_.bind(this.on_mouseenter, this), 100));
          $("#boxee-watch-later").mouseleave(_.throttle(_.bind(this.on_mouseleave, this), 200));

          this.fade_eventually_timer = setTimeout(_.bind(this.fade_now, this), 4300);
        },
        
        on_mouseenter: function() {
          if (this.fade_eventually_timer) {
            clearTimeout(this.fade_eventually_timer);
          }
        },
        
        on_mouseleave: function() {
          if (this.fade_eventually_timer) {
            clearTimeout(this.fade_eventually_timer);
          }
          this.fade_eventually_timer = setTimeout(_.bind(this.fade_now, this), 3000);
        },
        
        get_add_params: function() {
          return {
            title: document.title,
            description: ' ',
            playback_url: document.location.toString(),
            found_on_url: document.location.toString(),
            url: document.location.toString()
          };
        },
        
        add_page: function(event) {
          //event.preventDefault();
          $.getJSON(SERVER + 'queue/addtoqueue2?' + $.param(BoxeeWatchLater.get_add_params()) + "&format=jsonp&callback=?",
            function(response) {
              BoxeeWatchLater.action_index = response.action_index;
              $('#boxee-add-page').replaceWith("Page added!");
            }
          );
        },
        
        undo_add_page: function(event) {
          //event.preventDefault();
          if (BoxeeWatchLater.action_index) {
            var data = {action_index: BoxeeWatchLater.action_index};
            BoxeeWatchLater.action_index = null;
            
            $.getJSON(SERVER + 'queue/undoaddtoqueue?' + $.param(data) + "&format=jsonp&callback=?",
              function() {
                $('#boxee-dont-add-it').replaceWith("Ok, it's gone");
              }
            );            
          }
        },
        
        clear_intervals: function() {
          window.clearInterval(window.boxee_spacer_mirroring_height_interval);
          if (this.fade_eventually_timer) {
            clearTimeout(this.fade_eventually_timer);
          }
        },
        
        start_spacer_mirroring_height: function() {
          window.boxee_spacer_mirroring_height_interval = setInterval(function() {
            $("#boxee-page-spacer").css('height', $("#boxee-watch-later-wrapper").height());
            if ($('body').css('position') == 'relative') {
              $("#boxee-watch-later-wrapper").css('top', -$("#boxee-watch-later-wrapper").height())
            }
          }, 50);
        },
        
        maybe_reject_meta_video: function() {
          if (BoxeeWatchLater.results.videos.length == 2) {
            var embed_video = _.detect(BoxeeWatchLater.results.videos, function(v) {return v.service;});
            var meta_video = _.detect(BoxeeWatchLater.results.videos, function(v) {return !v.service;});
            if (embed_video && meta_video) {
              // remove meta video if we found one non meta video
              BoxeeWatchLater.results.videos = _.without(BoxeeWatchLater.results.videos, meta_video);
            }
          }
        },
        
        get_page_video_file: function() {
          var last, pieces = window.location.pathname.toString().split('/');
          last = pieces[pieces.length - 1];
          
          if ((/\.(mov|mp4)$/).test(last)) {
            var video = new Video();
            video.title = last;
            video.playback_url = window.location.host.toString() + window.location.pathname.toString();
            return video;
          }
          
          return false;
        },
        
        require_login: function() {
          $('#sign-in-link').attr('href', SERVER + 'auth?redirurl=/bookmarklet/loggedin');
          BoxeeWatchLater.set_view_state('need-login');
          $(window).bind('focus', BoxeeWatchLater.onWindowFocus);
        },
        
        onWindowFocus: function() {
          $.getJSON(SERVER + 'queue/watchlaterlogincheck?format=jsonp&callback=?', BoxeeWatchLater.login_check);
        },
        
        login_check: function(data) {
          if (data) {
            $(window).unbind('focus', BoxeeWatchLater.onWindowFocus);
            BoxeeWatchLater.set_view_state('searching');
            BoxeeWatchLater.query_embedly();
            setTimeout(function() {
              BoxeeWatchLater.done_searching();
            }, EMBEDLY_TIMEOUT);
          }
        },
        
        query_embedly: function(url) {
          url = url || document.location.toString();
          $.getJSON(SERVER + 'queue/embedly?url=' +
            encodeURIComponent(url) +
            "&format=jsonp&callback=?", function(data){
              if (data && data.type == 'video' && data.title && data.thumbnail_url) {
                var video = new Video(data.provider_name);
                video.playback_url = url;
                video.title = data.title;
                video.description = data.description;
                video.thumbnail_url = data.thumbnail_url;
                BoxeeWatchLater.results.embedly = video;
              }
          });
        },
        
        get_embedly_video: function() {
          return BoxeeWatchLater.results.embedly;
        },
        
        done_searching: function() {
          BoxeeWatchLater.maybe_reject_meta_video();
          
          if (BoxeeWatchLater.found_anything()) {
            if (BoxeeWatchLater.found_multiple()) {
              window.setTimeout(function() {
                BoxeeWatchLater.draw_videos();
                BoxeeWatchLater.set_view_state('found-many');
              }, 500);
            } else {
              window.setTimeout(function() {
                var video = BoxeeWatchLater.results.videos[0];
                BoxeeWatchLater.draw_videos();
                if (video) {
                  video.add_to_queue();
                }
                BoxeeWatchLater.set_view_state('found-one');
                BoxeeWatchLater.fade_eventually();
              }, 500);
            }
          } else {
            // BoxeeWatchLater.view.results()
            var video = BoxeeWatchLater.get_page_video_file() || BoxeeWatchLater.get_embedly_video() || BoxeeWatchLater.get_open_graph_video();
            if (video) {
              BoxeeWatchLater.add_video(video);
              BoxeeWatchLater.draw_videos();
              video.add_to_queue();
              BoxeeWatchLater.set_view_state('found-one');
              BoxeeWatchLater.fade_eventually();
            } else {
              BoxeeWatchLater.add_page();
              BoxeeWatchLater.set_view_state('found-none');
              BoxeeWatchLater.fade_eventually();
            }
          }
        },
        
        get_meta_title: function() {
          var i = 0;
          for(i; i < BoxeeWatchLater.results.page.titles.length; i++) {
            if (BoxeeWatchLater.results.page.titles[i]) {
              return BoxeeWatchLater.results.page.titles[i];
            }
          }
        },
        
        get_meta_thumbnail: function() {
          var i = 0;
          for(i; i < BoxeeWatchLater.results.page.thumbnails.length; i++) {
            if (BoxeeWatchLater.results.page.thumbnails[i]) {
              return BoxeeWatchLater.results.page.thumbnails[i];
            }
          }
        },
        
        found_meta_info: function() {
          return (BoxeeWatchLater.get_meta_title() && BoxeeWatchLater.get_meta_thumbnail());
        },
        
        found_anything: function() {
          return BoxeeWatchLater.results.videos.length > 0;
        },
        
        found_multiple: function() {
          return BoxeeWatchLater.results.videos.length > 1;
        },
        
        set_view_state: function(name) {
          BoxeeWatchLater.clear_view_state();
          $('#boxee-watch-later-wrapper').addClass('boxee-' + name);
        },
        
        clear_view_state: function() {
          var states = ['searching', 'found-none', 'found-one', 'found-many', 'need-login'];
          $.each(states, function(idx, val) {
            $('#boxee-watch-later-wrapper').removeClass('boxee-' + val);
          });
        },
        
        embeds_found: function() {
          var count = 0;
          
          $.each(BoxeeWatchLater.services, function(idx, val) {
            count += BoxeeWatchLater.results[val].length;
          });
          
          return count;
        },
        
        add_result: function(service, element, data) {
          BoxeeWatchLater.results[service].push({
            element: element,
            data: data
          });
        },
        
        add_video: function(video) {
          var index = BoxeeWatchLater.results.videos.length;
          video.index = index;
          BoxeeWatchLater.results.videos.push(video);
        },
        
        draw_videos: function() {
          var $videos_view = $('#boxee-videos-list');
          $.each(BoxeeWatchLater.results.videos, function(idx, video) {
            video.draw($videos_view, BoxeeWatchLater.templates.video);
          });
        },
        
        set_link: function(key, value) {
          BoxeeWatchLater.results.links[key] = value;
        },
        
        get_open_graph_video: function() {
          var video = new Video();
          if (BoxeeWatchLater.results.page.thumbnails.length > 0) {
            video.thumbnail_url = BoxeeWatchLater.results.page.thumbnails[0][0];
          }
          if (BoxeeWatchLater.results.page.titles.length > 0) {
            video.title = BoxeeWatchLater.results.page.titles[0][0];
          }
          if (BoxeeWatchLater.results.page.descriptions.length > 0) {
            video.description = BoxeeWatchLater.results.page.descriptions[0][0];
          }
          if (video.thumbnail_url) {
            return video;
          }
        },
        
        view: {
          youtube: function(element, data, index) {
            var youtube_id = data.id;
            var video = new Video('YouTube', youtube_id);
            video.playback_url = "http://www.youtube.com/watch?v=" + youtube_id;
            video.thumbnail_url = "http://i.ytimg.com/vi/" + youtube_id + "/default.jpg";
            
            $.getJSON("http://gdata.youtube.com/feeds/api/videos/" + youtube_id +"?alt=json-in-script&callback=?",
              function(response) {
                if (response && response.entry &&
                    response.entry.title && response.entry.title.$t !== undefined &&
                    response.entry.content && response.entry.content.$t !== undefined) {
                  video.title = response.entry.title.$t;
                  video.description = response.entry.content.$t;
                  BoxeeWatchLater.add_video(video);
                }
            });
          },
          
          //view.vimeo
          vimeo: function(element, data, index) {
            var vimeo_id = data.id;
            var video = new Video('Vimeo', vimeo_id);
            video.playback_url = "http://vimeo.com/" + vimeo_id;
            
            var callback = function(response) {
              if (response && response[0] && response[0].id) {
                var video_data = response[0];
                video.title = video_data.title;
                video.description = video_data.description;
                video.thumbnail_url = video_data.thumbnail_small;
                BoxeeWatchLater.add_video(video);
              }
            };
            
            $.getJSON("http://vimeo.com/api/v2/video/" + vimeo_id + ".json?callback=?", callback);
          },
          
          //view.tumblr
          tumblr: function(element, data, index) {
            var video = new Video('Tumblr', null);
            video.thumbnail_url = (data.thumbnails.length ? data.thumbnails[0] : false);
            
            BoxeeWatchLater.add_video(video);
          },
          
          //view.ooyala
          ooyala: function(element, data, index) {
            var $embed = $(element);
            var embed = $embed.get(0);
            var video = new Video('Ooyala');
            if (embed.getCurrentItemTitle) {
              video.title = embed.getCurrentItemTitle();
              video.embed_code = embed.getCurrentItemEmbedCode();
              video.video_id = video.embed_code;
              video.description = embed.getCurrentItemDescription();
              video.thumbnail_url = embed.getPromoFor(embed.getCurrentItemEmbedCode(), 360, 240);
              BoxeeWatchLater.add_video(video);
            } else if (data.embedCode) {
              video.video_id = data.embedCode;
              video.embedCode = data.embedCode;
              
              window.boxee_ooyala_request_id = window.boxee_ooyala_request_id ? (window.boxee_ooyala_request_id + 1) : 100;
              var player_id = "boxee_ooyala_p" + boxee_ooyala_request_id;
              var callback_name = "boxee_ooyala_callback_handler_" + boxee_ooyala_request_id;
              
              window[callback_name] = _.once(function() {
                var player = document.getElementById(player_id);
                video.title = player.getTitle();
                video.description = player.getDescription();
                video.thumbnail_url = player.getPromoFor(data.embedCode, 360, 240);
                BoxeeWatchLater.add_video(video);
                $(player).parent().hide();
              });
              
              var src = "http://player.ooyala.com/player.js?callback=" + callback_name + "&playerId=" + player_id + "&width=640&height=360&embedCode=" + data.embedCode + "&autoplay=0&transition=selector";              
              $('body').append($('<script>').attr('src', src));
            } else {
              video.title = document.title;
              BoxeeWatchLater.add_video(video);
            }
          },
          
          //view.brightcove
          brightcove: function(element, data, index) {
            //http://link.brightcove.com/services/player/bcpid{{player_id}}?bctid={{video_id}}
            var video = new Video('Brightcove');
            var param_hash = {};
            
            var obj_data = $(element).attr('data');
            if (obj_data) {
              var pieces = obj_data.split('?');
              if (pieces && pieces[1]) {
                $.each(pieces[1].split('&'), function(idx, value) {
                  if (value) {
                    var keyvalue = value.split('=');
                    if (keyvalue && keyvalue[1]) {
                      param_hash[keyvalue[0]] = keyvalue[1];
                    }
                  }
                });
              }
            }
            
            video.video_id = param_hash['%40videoPlayer'];
            video.pulisher_id = param_hash.publisherID;
            
            if (video.video_id && video.pulisher_id) {
              $.getJSON(
                "http://dir.boxee.tv/apps/brightcove/bcvideo.php?publisherId=" + param_hash.publisherID + 
                "&videoId=" + video.video_id + "&callback=?", function(response) {
                  if (response && response.name && response.thumbnailURL && response.playbackURI) {
                    video.title = response.name;
                    video.thumbnail_url = response.thumbnailURL;
                    video.playback_url = response.playbackURI;
                    BoxeeWatchLater.add_video(video);
                  } else {
                    video.title = document.title;
                    BoxeeWatchLater.add_video(video);                    
                  }
                }
              );
            } else {
              video.title = document.title;
              BoxeeWatchLater.add_video(video);
            }
          },
          
          //view.blip
          blip: function(element, data, index) {
            var video = new Video('blip.tv', data.code);
            $.getJSON("http://blip.tv/players/episode/" + data.code + "?skin=json&version=2&callback=?",
              function(response) {
                if (response && response[0] && response[0].Post && response[0].Post.thumbnailUrl) {
                  var video_data = response[0].Post;
                  video.thumbnail_url = video_data.thumbnailUrl;
                  video.title = video_data.title;
                  video.description = video_data.description;
                  video.playback_url = video_data.url;
                  BoxeeWatchLater.add_video(video);
                }
              });
          },
          
          //view.viddler
          viddler: function(element, data, index) {
            var video = new Video('Viddler', data.id);
            $.getJSON(SERVER + "queue/viddler?video_id=" + data.id + "&format=jsonp&callback=?",
              function(response) {
                if (response.video && response.video.title && response.video.thumbnail_url) {
                  video.title = response.video.title;
                  video.thumbnail_url = response.video.thumbnail_url;
                  video.description = response.video.description;
                  video.playback_url = response.video.url;
                  BoxeeWatchLater.add_video(video);
                }
              }
            );
          }
        },
        
        parsers: {
          embed: function() {
            var $el = $(this);
            var src = $el.attr('src');
            var match_data;
            if (src.match(/player\.ooyala\.com/)) {
              BoxeeWatchLater.add_result('ooyala', $el, {});
            }
            
            match_data = (/viddler\.com\/(simple|player)\/(\w+)/).exec(src);
            if (match_data && match_data[2]) {
              BoxeeWatchLater.add_result('viddler', $el, {id: match_data[2]});
            }
            
            match_data = (/vimeo\.com\/[^?]+/).exec(src);
            var clip_data = (/clip_id=(\d{8})/).exec(src);
            if (match_data && clip_data && clip_data[1]) {
              BoxeeWatchLater.add_result('vimeo', $el, {id: clip_data[1]});
            }
            
            match_data = (/www\.youtube(-nocookie)?\.com\/v\/([^?&]+)/).exec(src);
            if (match_data && match_data[2]) {
              BoxeeWatchLater.add_result('youtube', $el, {id: match_data[2]});
            }
            
            match_data = (/http:\/\/blip\.tv\/play\/([^?&]+)/).exec(src);
            if (match_data && match_data[1]) {
              BoxeeWatchLater.add_result('blip', $el, {code: match_data[1]});
            }
            
            if ((/assets\.tumblr\.com\/swf\/video_player\.swf/).test(src)) {
              var embed_vars = {};
              var flashvars = decodeURIComponent($el.attr('flashvars')).split("&");
              $.each(flashvars, function(idx, value) {
                var pair = value.split("=");
                embed_vars[pair[0]] = pair[1];
              });
              BoxeeWatchLater.add_result('tumblr', $el, {
                link: embed_vars.file,
                thumbnails: embed_vars.poster.split(',')
              });
            }
          },
          

          
          // parsers.object
          object: function() {
            var $el = $(this);
            var match_data, data = $el.attr('data');
            
            if ((/http\:\/\/player\.ooyala\.com/).test(data)) {
              var flashvars = $el.find('param[name=flashvars]').attr('value');
              if (flashvars) {
                var bits = flashvars.split('&');
                var flashvar_hash = {};
                _.each(bits, function(bit) {
                  var pieces = bit.split('=');
                  if (pieces.length > 1) {
                    flashvar_hash[pieces[0]] = pieces[1];
                  }
                });
                BoxeeWatchLater.add_result('ooyala', $el, {embedCode: flashvar_hash.embedCode});
              } else {
                BoxeeWatchLater.add_result('ooyala', $el, {});
              }
            }
            
            if ((/http:\/\/(\w+)\.vimeocdn\.com/).test(data)) {
              // example: http://vimeo.com/channels/hd
              var vimeo_object = $el.get()[0];
              if (vimeo_object.api_getVideoUrl && vimeo_object.api_getVideoUrl()) {
                var vimeo_url = vimeo_object.api_getVideoUrl(); // this URL may not have a vimeo id
                BoxeeWatchLater.query_embedly(vimeo_url);
              }
            }
            
            if (data) {
              match_data = (/http\:\/\/c\.brightcove\.com\/services\/viewer\//).exec(data);
              if (match_data && match_data[0]) {
                BoxeeWatchLater.add_result('brightcove', $el, {});
              }
              
              match_data = (/viddler\.com\/(simple|player)\/(\w+)/).exec(data);
              if (match_data && match_data[2]) {
                BoxeeWatchLater.add_result('viddler', $el, {id: match_data[2]});
              }
            }
          },
          
          // parsers.video
          video: function() {
            
          },
          
          // parsers.iframe
          iframe: function() {
            var $el = $(this);
            var src = $el.attr('src');
            
            var match_data = (/player\.vimeo\.com\/video\/([^?&]+)/).exec(src);
            if (match_data && match_data[1]) {
              BoxeeWatchLater.add_result('vimeo', $el, {id: match_data[1]});
            }
            
            match_data = (/viddler\.com\/embed\/(\w+)/).exec(src);
            if (match_data && match_data[1]) {
              BoxeeWatchLater.add_result('viddler', $el, {id: match_data[1]});
            }
            
            match_data = (/www\.youtube(-nocookie)?\.com\/embed\/([^?&]+)/).exec(src);
            if (match_data && match_data[2]) {
              BoxeeWatchLater.add_result('youtube', $el, {id: match_data[2]});
            }
          }
        },
        
        read_titles: function() {
          var $og_title = $('meta[property="og:title"], meta[name="og:title"]');
          if ($og_title.size() > 0) {
            var title = $og_title.attr('content');
            if (title && $.trim(title).length > 0) {
              BoxeeWatchLater.results.page.titles.push([title, 'meta[og:title]']);
            }
          }
          
          var $headline_meta = $('meta[name=Headline], meta[name=headline]');
          if ($headline_meta.size() > 0) {
            BoxeeWatchLater.results.page.titles.push([$headline_meta.attr('content'), 'meta[name="Headline"]']);
          }
          
          BoxeeWatchLater.results.page.titles.push([document.title, 'document.title']);
        },
        
        read_descriptions: function() {
          var $og_descriptions = $('meta[property="og:description"], meta[property="og:Description"], meta[name="og:description"]');
          if ($og_descriptions.size() > 0) {
            BoxeeWatchLater.results.page.descriptions.push([$og_descriptions.attr('content'), 'meta[og:description]']);
          }
          var $description_meta = $('meta[name=description], meta[name=Description]');
          if ($description_meta.size() > 0) {
            BoxeeWatchLater.results.page.descriptions.push([$description_meta.attr('content'), 'meta[name=description]']);
          }
        },
        
        read_thumbnails: function() {
          var $og_image = $('meta[property="og:image"], meta[name="og:image"]');
          if ($og_image.size() > 0 && $og_image.attr('content')) {
            BoxeeWatchLater.results.page.thumbnails.push([$og_image.attr('content'), 'meta[og:image]']);
          }
          
          var $thumbnail_meta = $('meta[name=THUMBNAIL_URL], meta[name=thumbnail_url]');
          if ($thumbnail_meta.size() > 0) {
            BoxeeWatchLater.results.page.thumbnails.push([$thumbnail_meta.attr('content'), 'meta[name="THUMBNAIL_URL"]']);
          }
          
          var $image_src_link = $('link[rel=image_src]');
          if ($image_src_link.size() > 0) {
            BoxeeWatchLater.results.page.thumbnails.push([$image_src_link.attr('href'), 'link[rel=image_src]']);
          }
        },
        
        read_metas: function() {
          BoxeeWatchLater.read_titles();
          BoxeeWatchLater.read_descriptions();
          BoxeeWatchLater.read_thumbnails();
        },
        
        scroll_to_element: function(element) {
          var $el = $(element);
          var offsets = $el.offset();
          window.scrollTo(0, offsets.top);
        },
        
        scroll_to_top: function() {
            var is_ok = false;
            var animateScroll = function() {
                $('html,body').animate({scrollTop: 0}, 400, function() {is_ok = true;});
            }
            var forceScroll = function() {
                if (!is_ok) {
                    $(window).scrollTop(0);
                }
            }
            setTimeout(animateScroll, 0);
            setTimeout(forceScroll, 450);
        },
        
        cleanup: function() {
          BoxeeWatchLater.clear_intervals();
          $("#boxee-watch-later-wrapper").remove();
          $('#boxee-page-spacer').remove();
        },

          initial_draw: function() {
            var is_ok = false;
            var animate_draw = function() {
              $("#boxee-watch-later-wrapper").animate({height: "90px"}, 350, 'swing', function() {
                $("#boxee-watch-later-wrapper").css('height', 'auto');
                is_ok = true;
              });

              $("#boxee-page-spacer").animate({height: "90px"}, 350, 'swing', function() {
                //BoxeeWatchLater.start_spacer_mirroring_height();
                $("#boxee-page-spacer").css('height', 'auto');
              });
            }
            var force_draw = function() {
              if (!is_ok) {
                $("#boxee-watch-later-wrapper").css('height', 'auto');
                $("#boxee-page-spacer").css('height', 'auto');
              }
            }
            setTimeout(animate_draw, 0);
            setTimeout(force_draw, 400);
          },
        
        run_parsers: function() {
          $('embed').each(BoxeeWatchLater.parsers.embed);
          $('iframe').each(BoxeeWatchLater.parsers.iframe);
          $('object').each(BoxeeWatchLater.parsers.object);
          $('video').each(BoxeeWatchLater.parsers.video);
        },
        
        run: function(html, logged_in) {
          BoxeeWatchLater.scroll_to_top();
          BoxeeWatchLater.cleanup();
          
          //$('body').append(html);
          $('body').before("<div id='boxee-page-spacer'>");
          $('#boxee-page-spacer').append(html);
          
          if (!logged_in) {
            BoxeeWatchLater.require_login();
          }
          
          BoxeeWatchLater.initial_draw();
          
          BoxeeWatchLater.setup_templates();
          BoxeeWatchLater.setup_behavior();
          
          // populate BoxeeWatchLater.results
          BoxeeWatchLater.read_metas();
          BoxeeWatchLater.run_parsers();
          
          $.each(BoxeeWatchLater.services, function(service_idx, service) {
            $.each(BoxeeWatchLater.results[service], function(result_idx, result) {
              BoxeeWatchLater.view[service](result.element, result.data, result_idx);
            });
          });
          
          if (logged_in) {
            BoxeeWatchLater.query_embedly();
            setTimeout(function() {
              BoxeeWatchLater.done_searching();
            }, EMBEDLY_TIMEOUT);
          }
          setTimeout(function() {
            $('#boxee-watch-later-wrapper').css('overflow-y', 'auto');
          }, 500);
        }
      };
      
      BoxeeWatchLater.Video = Video;
      return BoxeeWatchLater;
      
    })(jQuery);
  }
};