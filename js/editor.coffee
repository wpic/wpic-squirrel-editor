closed = false

href = window.location.href  


window.resize = ->
    $(".sidebar").height($(window).height());

$(window).on 'beforeunload', () ->
  

window.onbeforeunload = () ->
  # autoSave()
  # x = ''

isMobile = () ->
  sUserAgent = navigator.userAgent.toLowerCase()
  bIsIpad = sUserAgent.match(/ipad/i)
  bIsIphoneOs = sUserAgent.match(/iphone os/i)
  bIsMidp = sUserAgent.match(/midp/i)
  bIsUc7 = sUserAgent.match(/rv:1.2.3.4/i)
  bIsUc = sUserAgent.match(/ucweb/i)
  bIsAndroid = sUserAgent.match(/android/i)
  bIsCE = sUserAgent.match(/windows ce/i)
  bIsWM = sUserAgent.match(/windows mobile/i)
  if bIsIpad || bIsIphoneOs || bIsMidp || bIsUc7 || bIsUc || bIsAndroid || bIsCE || bIsWM
    return true
  else
    return false

# document ready
newfile = 0
editor = ace.edit("editor")
language = 'javascript'
editor.setTheme("ace/theme/twilight")
editor.getSession().setMode("ace/mode/" + language)
# $(editor).keypress ->
  # name = $(".filelist li.active").attr("data-name")
  # debounce(saveContent(name,editor.getValue()), 100)
  # autoSave()
editor.on 'blur',() ->
#   name = $(".filelist li.active").attr("data-name")
#   # setTimeout(saveContent(name,editor.getValue()), 500)
#   debounce(saveContent(name,editor.getValue()), 5000)
  # console.log(editor.getValue())
  autoSave()



resize = () ->
  h = $("body").height()
  $(".sidebar,.content").height(h)
  editor.resize()

autoSave = () ->
  name = $(".filelist li.active").attr("data-name")
  data = if (editor.getValue()).length != 0  then editor.getValue() else " "
  debounce(saveContent(name,data), 10000)


$ ->
  $('[data-action="create"]').click ->
  # $(".sidecontent .filelist").append ->
    newfile = newfile+1
    createFile 'untitled' + newfile
  
  getFilelist()
  resize()
  
  $(".sidecontrol").click -> 
    closeSidebar()

  if isMobile() is true
  #   alert('true')
    $("body").swipe
      swipeLeft:() ->
        $(".main").css transform:"translateX(-"+$(".sidebar").width()+"px",transition:"all 1s"
        $(".sidebar").hide()
      swipeRight:() ->
        $(".main").css transform:"",transition:"all 1s"
        $(".sidebar").show().css position:"absolute"


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
    $(".sidebar").css position:"absolute",transform:"translateX(-"+$(".sidebar").width()+"px"
    $(".sidecontent").css width:0,display:"none"
    $(".content").css width:"100%"
    $(".sidebar .open").show()
    $(".sidebar .close").hide()
    closed = true
    # console.log('close')
  )
  else if closed is true then (
    $(".sidebar").css transform:"",position:""
    $(".sidecontent").css width:"",display:"block"
    $(".content").css width:""
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
      # console.log(data)

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

    error: (XMLHttpRequest, textStatus, errorThrown) ->
      $(".notify .status").addClass("error").text("#{XMLHttpRequest}, #{textStatus}, #{errorThrown}")

deleteFile = (filename) ->
  $.ajax
    method:'DELETE',
    url:'/rest/scripts/'+filename,
    data:filename,
    success:(data)->
      # console.log(data)

getContent = (name) ->
  $.ajax
    method:'GET'
    url:'/rest/scripts/'+name
    success:(data) ->
      # console.log(data)
      editor.setValue(data.temp)
      editor.commands.addCommand
        name: "save",
        bindKey: 
          win: "Ctrl-S", mac: "Command-S"
        exec: (editor) ->
          event.preventDefault()
          saveContent(name,editor.getValue())

saveContent = (name,content) ->
  $.ajax
    method:'PUT',
    url:'/rest/scripts/'+name
    data:content
    success:(data) ->
      # console.log(name + " saved!")

commitContent = (name) ->
  $.ajax
    method:'PUT',
    url:'/rest/scripts/commit/'+name
    success:(data) ->
      console.log(name+" commited!")

revertContent = (name) ->
  $.ajax
    method:'PUT',
    url:'/rest/scripts/revert/'+name
    success:(data) ->
      console.log("#{name} Reverted!")

getFilelist = () ->
  # filelist = $(".filelist")
  $(".filelist ul.row li").remove()
  ul = $(".filelist ul.row")
  $.ajax
    method:'GET'
    url:'/rest/scripts'
    success:(data) ->
      # console.log(data)
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
          revertContent($(@).parent().parent().attr('data-name'))
        else
          console.log($(@).index()+" not Reverted")

      $('[data-action="commit"]').click ->
        if confirm('Commit?') is true
          commitContent($(@).parent().parent().attr('data-name'))
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
      