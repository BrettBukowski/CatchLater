$(document).ready ->
  prompt = $('#emailDialog')
  if prompt.length
    prompt.removeClass('hide').dialog(
      minWidth: 500,
      draggable: false,
      resizable: false,
      modal: true,
      title: 'Success!',
      closeText: '×',
    )