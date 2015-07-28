closed = false


window.resize = ->
    $(".sidebar").height($(window).height());
    
window.onbeforeunload = () ->
  if confirm('need save before leave this page') isnt true
    alert('ok')

# document ready
newfile = 0
editor = ace.edit("editor")
language = 'javascript'
editor.setTheme("ace/theme/twilight")
editor.getSession().setMode("ace/mode/" + language)

$ ->
  $('[data-action="create"]').click ->
  # $(".sidecontent .filelist").append ->
    newfile = newfile+1
    createFile('untitled' + newfile)
  getFilelist()

  h = $("body").height()
  $(".sidebar,.content").height(h)
  
  $(".sidecontrol").click -> 
    closeSidebar()


$.fn.editable =  ->
  input = $('<input type="text" class="editnamebox">')
  $(@).on 'click', (event) ->
    t = $(@).text()
    $(@).css("visibility","hidden")
    input.insertAfter($(@)).val(t).focus().blur ->
      changeName(t,($(@).val()).trim())
      $(@).prev().text($(@).val()).removeAttr("style")
      $(@).remove()
      console.log("Name Changed")

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
  $(".status").removeClass('error').text("Processing...")

$(document).ajaxComplete ->
  $(".status").removeClass('error').text('')

changeName = (filename,newname) ->
  $.ajax
    method:'PUT'
    url:'/rest/scripts/rename/'+filename+'/'+newname
    # data:{from:filename,to:newname},
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
      $(".filelist ul.row").empty()
      getFilelist()

    error: (error) ->
      $(".notify .status").addClass("error").text("Scripts " +filename+" already exist")

deleteFile = (filename) ->
  $.ajax
    method:'DELETE',
    url:'/rest/scripts/'+filename,
    data:filename,
    success:(data)->
      console.log(data)

getContent = (name) ->
  $.ajax
    method:'GET'
    url:'/rest/scripts/'+name
    success:(data) ->
      # console.log(data)
      editor.setValue(data.temp)

saveContent = (name,content) ->
  $.ajax
    method:'PUT',
    url:'/rest/scripts/'+name
    data:{'name':name,'data':content}
    success:(data) ->
      console.log(data)

getFilelist = () ->
  # filelist = $(".filelist")
  $(".filelist ul.row li").remove()
  ul = $(".filelist ul.row")
  $.ajax
    method:'GET'
    url:'/rest/scripts'
    success:(data) ->
      console.log(data)
      for s in data by -1
        li = $('<li class="clearfix"></li>')
        file = $('<div class="col-xs-8 name"><span data-action="delete" class="glyphicon glyphicon-remove-sign"></span></div>')
        filename = $('<span data-action="editname">'+s.name+'</span>')
        filedate = $('<div class="date">'+s.lastEdit+'</div>')
        control = $('<div class="col-xs-4 icons"><button class="btn" data-action="revert"><span class="glyphicon glyphicon-import"></span>Revert</button><button class="btn" data-action="commit"><span class="glyphicon glyphicon-random"></span>Commit</button></div>')
        li.append(file.append(filename).append(filedate)).append(control).attr("data-name",s.name)
        ul.append(li)


      $('li[data-name]').click ->
        $(".filelist ul.row li").removeClass('active')
        $(@).addClass('active')
        getContent($(@).attr('data-name'))

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

      $('[data-action="delete"]').click ->
        if confirm('Delete?') is true
          deleteFile($(@).next().text())
          console.log("Deleted");
          $(@).parent().parent('li').next().addClass('active')
          $(@).parent().parent('li').remove()

      $('[data-action="editname"]').each ->
        $(@).editable
        #   callback:
        #     changeName($(@).closest(li).attr("data-name"),$(@).text())
          
          editClass: 'editable'
          event:'click'
          emptyMessage : 'untitled'
        # $(@).edit = (event,$editor)) ->
          # console.log($(@))
      
      $('li[data-name]').first().trigger('click')
    statusCode:
      500:() ->
        console.log('error')
      