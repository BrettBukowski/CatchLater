$ ->
  $.rails.allowAction = (element) ->
    message = element.data('confirm')
    fire = $.rails.fire
    if message and fire(element, 'confirm')
      title = if $(document.body).hasClass('videos') then 'Delete this video' else 'Delete your account'
      dialog = new Dialog(title, message, confirmLabel: '<i class="icon-trash" role="presentation" aria-hidden="true"></i>Yes')
      dialog.onConfirm () ->
        callback = fire(element, 'confirm:complete', [true])
        if (callback)
          allowActionOrig = $.rails.allowAction
          $.rails.allowAction = () -> true
          element.trigger('click')
          $.rails.allowAction = allowActionOrig
          dialog.destroy()
      dialog.onClose () ->
        element.focus()
      dialog.show()
    not message or false