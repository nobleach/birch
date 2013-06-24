# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  error_span = $('#password-error')
  error_span.hide()
  $('#password').blur( -> 
    orig_pass = $('#password').val()    
    $('#confirm-password').keyup( -> 
      pass = $(@).val()
      unless pass == orig_pass
        error_span.show()
        $(@).css({background:'red'})
      else
        $(@).css({background:'#fff'})
        error_span.hide()
    )
  )
  