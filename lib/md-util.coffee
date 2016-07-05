# ed.lineTextForScreenRow(ed.getCursorScreenPosition().row)
#     range = @editor.bufferRangeForBufferRow(row, includeNewline: true)
# @setBufferRange(@getBufferRange().union(range), autoscroll: true)
# @linewise = true
{View,$} = require 'atom-space-pen-views'


class Dialog extends View

  initialize: (@txt)->
    @promise = new Promise (@res,@rej)=>
    atom.commands.add @element,
      'core:confirm': => @onConfirm()
      'core:cancel': => @cancel()
    @element.onblur =  => @close

  close: ->
    atom.workspace.getActivePane().activate()
    @parent().hide()

  cancel: ->
    @close()

  open: ->
      @promise = new Promise (@res,@rej)=>
      @parent().show()


class LinkDialog extends Dialog

  # initialize: (@txt)->
  #   @promise = new Promise (@res,@rej)=>
  #   atom.commands.add @element,
  #     'core:confirm': => @onConfirm()
  #     'core:cancel': => @cancel()
  #   @element.onblur =  => @close
  #
  # close: ->
  #   atom.workspace.getActivePane().activate()
  #   @parent().hide()
  #
  # cancel: ->
  #   @close()

  @content: ->
    @div class: "text-transform-dialog native-key-bindings", =>
      @label for:"link", "Enter URL "
      @input type:'text', id:'link'
      @input type:'button', value:'Link', click:'onLink'

  onLink: ->
    link = @find('#link').val()
    @res "[#{@txt}](#{link})"
    atom.workspace.getActivePane().activate()
    @parent().hide()


class ImageDialog extends Dialog

  @content: ->
    @div class: "text-transform-dialog native-key-bindings", =>
      @label for:"link", "Enter Image URL "
      @input type:'text', id:'link'
      @br
      @label for:"altTxt", "Enter Alternate Text "
      @input type:'text', id:'altTxt'
      @br
      @label for:"imgTitle", "Enter Image Title "
      @input type:'text', id:'imgTitle'
      @br
      @input type:'button', value:'Image Link', click:'onLink'


  onLink: ->
    link = @find('#link').val()
    altTxt = @find('#altTxt').val()
    imgTitle = @find('#imgTitle').val()
    @res  "![#{altTxt}](#{link} '#{imgTitle}')"
    atom.workspace.getActivePane().activate()
    @parent().hide()


md =
  fileTypes:['md','txt']
  scopeName: ['source.marked']
  inlineLinks: (txt,rn,ed)->
    return atom.notifications.addInfo("Select a word or place cursor on the word") unless txt
    if @linkDialog
      @linkDialog.open()
    else
      @linkDialog = new LinkDialog(txt)
      atom.workspace.addModalPanel item: @linkDialog

    @linkDialog.promise

  inlineImage: (txt,rn,ed)->
    if @linkImage
      @linkImage.open()
    else
      @linkImage = new ImageDialog('')
      atom.workspace.addModalPanel item: @linkImage

    @linkImage.promise

    # obj['maintCol'] = true
  table: (txt,rn,ed)->
      obj = ""
      for num in [rn.start.row..rn.end.row]
        str = ed.lineTextForBufferRow(num)
        continue if str.trim() is ''
        obj = obj + "\n" if obj isnt ""
        str = str.replace(/\t|\s{2,}/g,' | ')
        obj = obj + str
        obj = obj + "\n---|---" if num is rn.start.row
      obj




wordFun = {
  italics: '*'
  bold: '**'
  boldItalics: '***'
  strikeout: '~~'
  underline: '__'
  inlineCode: '`'
}
wordDiffFun = {
}
wordRevFun = {
  underlineItalics: '__*'
  underlineBold: '__**'
  underlineBoldItalics: '__***'
}

lineFun = {
  h6: '###### '
  h5: '##### '
  h4: '#### '
  h3: '### '
  h2: '## '
  h1: '# '
  blockQuote: '>'
}
lineBeforAfter = {
  codePython:  ['```python','```']
  codeJavascript: ['```javascript','```']
  code: ['```','```']
}
nextLineFun = {
  horizontalRule: '---'
  horizontalRuleUnderscore: '___'
  horizontalRuleAsteriks: '***'
  heading: '==='
}
for fn,cod of wordFun
  md[fn] = do (cod)->
                (txt)->
                  return atom.notifications.addInfo("Select a work or place cursor on the workd") unless txt
                  "#{cod}#{txt}#{cod}"

for fn,cod of wordDiffFun
  md[fn] = do (cod)->
                (txt)->
                  return atom.notifications.addInfo("Select a work or place cursor on the workd") unless txt
                  "#{cod[0]}#{txt}#{cod[1]}"

for fn,cod of wordRevFun
  md[fn] = do (cod)->
                (txt)->
                  return atom.notifications.addInfo("Select a work or place cursor on the workd") unless txt
                  "#{cod}#{txt}#{cod.split("").reverse().join("")}"

for fn,cod of lineFun
  md[fn] = do (cod) ->
                (txt)->
                  obj = {}
                  obj.txt = cod
                  obj.start = true
                  obj.multi = true
                  obj.selStart = true
                  obj

for fn,cod of nextLineFun
  md[fn] = do (cod)->
                (txt,rn,ed)->
                    obj = {}
                    if txt
                      obj['after'] = cod
                    else
                      if ed.lineTextForBufferRow(rn.start.row)
                        obj['after'] = cod
                      else
                        return cod
                    obj
for fn,cod of lineBeforAfter
  md[fn] = do (cod)->
                (txt)->
                    obj = {}
                    obj['before'] = cod[0]
                    obj['after'] = cod[1]
                    obj
module.exports = md
