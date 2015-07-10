closed = false
window.resize = ->
    $(".sidebar").height($("body").height());
    
window.onbeforeunload = () ->
  if confirm('need save before leave this page') isnt true
    alert('ok')

# document ready
newfile = 0;
$ ->
  filelist = $(".filelist")
  ul = $(".filelist ul.row")
  $.ajax
    method:'GET'
    url:'/rest/scripts'
    success:(data) ->
      for s in data
        li = $('<li class="clearfix"></li>')
        file = $('<div class="col-xs-8 name"><span data-action="delete" class="glyphicon glyphicon-remove-sign"></span></div>')
        filename = $('<span data-action="editname">'+s.name+'</span>')
        filedate = $('<div class="date">'+s.lastEdit+'</div>')
        control = $('<div class="col-xs-4 icons"><button class="btn" data-action="revert"><span class="glyphicon glyphicon-import"></span>Revert</button><button class="btn" data-action="commit"><span class="glyphicon glyphicon-random"></span>Commit</button></div>')
        li.append(file.append(filename).append(filedate)).append(control).attr("data-name",s.name)
        filelist.append(ul.append(li))

      $('[data-action="revert"]').click ->
        # $(elem).click ->
        if confirm('Revert?') is true
          console.log($(@).index()+"Reverted");
        else
          console.log($(@).index()+" not Reverted")

      $('[data-action="commit"]').click ->
        if confirm('Commit?') is true
          console.log("commited");
        else
            false

      $('[data-action="create"]').click ->
        # $(".sidecontent .filelist").append ->
          newfile = newfile+1
          createFile('untitled' + newfile)

      $('[data-action="delete"]').click ->
        if confirm('Delete?') is true
          deleteFile($(@).next().text())
          console.log("Deleted");
          $(@).parent().parent('li').next().addClass('active')
          $(@).parent().parent('li').remove()

      $('[data-action="editname"]').each ->
        $(@).editable
          callback:
            # $(@).editable("destroy")
            changeName($(@).closest(li).attr("data-name"),$(@).text())
          
          editClass: 'editable'
          event:'click'
          emptyMessage : 'untitled'
        # $(@).edit = (event,$editor)) ->
          # console.log($(@))


  $(".sidebar").height($("body").height());
  
  $(".sidecontrol").click -> 
    closeSidebar()





  $('.code').editable
    event:'click'
    # callback:
      # {
      #   $(@).css('background-color','#eee')
      # }
    

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
  $(".status").removeClass('error').text("Processing...");
$(document).ajaxStop ->
  $(".status").removeClass('error').text();

changeName = (filename,newname) ->
  $.ajax
    method:'PUT',
    url:'/rest/scripts/'+filename+'/'+newname,
    data:{from:filename,to:newname},
    success: (data) ->
      console.log(data)

createFile = (filename) ->
  $.ajax
    method:'POST',
    url:'/rest/scripts/'+ filename,
    data:'',
    success: (data) ->
      console.log(data)
      $(".notify .status").removeClass("error").text("Scripts " +filename+" created")
    error: (error) ->
      $(".notify .status").addClass("error").text("Scripts " +filename+" already exist")

deleteFile = (filename) ->
  $.ajax
    method:'DELETE',
    url:'/rest/scripts/'+filename,
    data:filename,
    success:(data)->
      console.log(data)
