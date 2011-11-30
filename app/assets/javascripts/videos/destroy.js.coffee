$ ->
  $.rails.allowAction = (element) ->
    message = element.data('confirm')
    fire = $.rails.fire
    if message and fire(element, 'confirm')
      $('<div/>').html(message).dialog({
        draggable: false,
        resizable: false,
        modal: true,
        title: 'Delete this video',
        closeText: '×',
        buttons: [
          {
            text: 'Yes, kill it',
            click: () -> 
              $(this).dialog('close')
              callback = fire(element, 'confirm:complete', [true])
              if (callback)
                allowActionOrig = $.rails.allowAction
                $.rails.allowAction = () -> true
                element.trigger('click')
                $.rails.allowAction = allowActionOrig
          },
          {
            text: 'Cancel',
            click: () -> $(this).dialog('close')
          }
        ]
      })
    not message or false