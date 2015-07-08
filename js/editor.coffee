closed = false
window.resize = ->
    $(".sidebar").height($("body").height());
    
window.onbeforeunload = () ->
  if confirm('need save before leave this page') isnt true
    alert('ok')

# document ready
$ ->
  $(".sidebar").height($("body").height());
  
  $(".sidecontrol").click -> 
    closeSidebar()

  $('[data-action="revert"]').click ->
    if confirm('Revert?') isnt true
      false
    else
      console.log("Reverted");
  $('[data-action="commit"]').click ->
    if confirm('Commit?') isnt true
      false
    else
      console.log("commited");

  $('[data-action="create"]').click ->
    # $(".sidecontent .filelist").append ->
      createFile('untitled')

  $('[data-action="delete"]').click ->
    if confirm('Delete?') isnt true
      false
    else
      console.log("Deleted");
      $(@).parent().parent('li').next().addClass('active')
      $(@).parent().parent('li').remove()

closeSidebar = (e) ->
  console.log(closed)
  if closed isnt true then(
    $(".sidebar").css width:"6px"
    $(".sidecontent").css width:0,display:"none"
    $(".sidebar .open").show()
    $(".sidebar .close").hide()
    closed = true
    # console.log('close')
  )
  else if closed is true then (
    $(".sidebar").css width:""
    $(".sidecontent").css width:"",display:"block"
    $(".sidebar .open").hide()
    $(".sidebar .close").show()
    closed = false
  )
$(document).ajaxStart ->
  $( ".status" ).text( "Triggered ajaxStart handler." );

createFile = (filename) ->
  $.ajax
    method:'POST',
    url:'/rest/scripts/'+ filename,
    data:{},
    success: (data) ->
      console.log(data)