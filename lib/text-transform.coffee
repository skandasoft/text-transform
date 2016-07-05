{TextTransformView,Feeler} = require './text-transform-view'
{CompositeDisposable} = require 'atom'
{$} = require 'atom-space-pen-views'

module.exports =
  textTransformView: null
  modalPanel: null
  subscriptions: null
  config:
    require:
      title: 'NPM/Require'
      type: 'array'
      default:['./md-util']
    display:
      title: 'Display Transform Functions'
      type: 'string'
      enum: ['hide','show','auto']
      default: 'show'
    feeler:
      title: 'Show Line -- mouse over for show/hide '
      type: 'boolean'
      default: true

  activate: (state) ->

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-text-editor', "text-transform:toggle": => @toggle()
    # get the basic transformations.
    transs = @addSubscription require('./transform')
    requires = atom.config.get('text-transform.require')
    for req in requires
      obj = {}
      reqq = require(req)
      obj["fun"] = @addSubscription reqq
      obj["fileTypes"] = reqq.fileTypes or []
      obj["scopeName"] = reqq.scopeName or []
      obj["heading"] = req

      transs.push obj
    # @textTransformView = new TextTransformView(state.textTransformViewState)
    @textTransformView = new TextTransformView(transs,@)
    @sidePanel = atom.workspace.addRightPanel(item: @textTransformView)
    @sidePanel.hide()
    if atom.config.get('text-transform.feeler')
      feeler = new Feeler(@)
      @feeler = atom.workspace.addRightPanel item:feeler
      feeler.sidePanel = @sidePanel


  addSubscription:(transforms)->
    transs = []
    for trans,fun of transforms
      continue unless typeof fun is 'function'
      fn = "text-transform:"+trans
      cmd = {}
      cmd[fn] = @replace(fun)
      @subscriptions.add atom.commands.add 'atom-text-editor', cmd
      transs.push(trans)
    transs

  deactivate:->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @textTransformView.destroy()

  serialize: ->
    textTransformViewState: @textTransformView.serialize()

  toggle: ->
    parent = @sidePanel.item.parent()
    if parent.isVisible()
      parent.hide()
    else
      parent.show()
      grammar = atom.workspace.getActiveTextEditor()?.getGrammar()
      return unless grammar
      fileTypes = grammar.fileTypes
      utls =  @textTransformView.find('.transform-require')
      for utl in utls
        $utl = $(utl)
        types = $utl.data('filetypes').split(',')
        for typ in types
          if typ in fileTypes
            $utl.show()
            return

        $utl.hide()

    # panel = @sidePanel.item
    # if panel.isVisible()
    #   panel.hide()
    # else
    #   panel.show()

  replace: (transform)->
    =>
      ed = atom.workspace.getActiveTextEditor()
      poss = ed.getCursorScreenPositions()
      poss = poss?.reverse()
      ed?.mutateSelectedText (selection)->
        lpad = (str,num=1,pad=" ")->
          padding = Array(num).join(pad)
          padding+str

        multi = (fn)=>
                  if transTxt.multi
                    firstTime = true
                    for i in [rn.start.row .. rn.end.row]
                      startPos = {}
                      startPos.row = i
                      if firstTime
                        startPos.column = rn.start.column
                        firstTime = false
                      if rn.end.row is i
                        startPos.column = rn.end.column
                      fn(startPos)
                  else
                    startPos = rn.end
                    fn(startPos,rn)
          start = (startPos)=>
                      startPos.column = 0
                      ed.setCursorBufferPosition(startPos)
                      ed.insertText(transTxt.txt)

          end = (startPos)=>
                  startPos.column = 0
                  ed.setCursorBufferPosition(endPos)
                  ed.moveToEndOfLine()
                  ed.insertText(transTxt.txt)

          after = (startPos,rn)=>
                  ed.setCursorScreenPosition(rn.end )
                  ed.insertNewlineBelow()
                  transTxt.after = lpad(transTxt.after,startPos.column + 1," ") if transTxt.maintCol
                  ed.insertText(transTxt.after)

          before = (startPos,rn)=>
                  ed.setCursorScreenPosition(rn.start)
                  ed.insertNewlineAbove() #if transTxt.insertLine
                  transTxt.before = lpad(transTxt.before,startPos.column + 1," ") if transTxt.maintCol
                  # startPos.row = startPos.row - 1
                  # ed.setCursorBufferPosition(startPos,{autoscroll: true})
                  ed.insertText(transTxt.before)

        if selection.isEmpty()
          cur = selection.cursor
          pos = cur.getBufferPosition()
          rn = ed.displayBuffer.bufferRangeForScopeAtPosition '.string.quoted',cur.getBufferPosition()
          if rn
            txt = ed.getTextInBufferRange(range)[1..-2]
          else
            # text = ed.getWordUnderCursor wordRegex:/[\/A-Z\.\-\d\\-_:]+(:\d+)?/i
            regx = /[\/A-Z\.\-\d\\-_:]+(:\d+)?/i
            txt = ed.getWordUnderCursor wordRegex:regx
            if txt
              rn = cur.getCurrentWordBufferRange wordRegex:regx
              ed.setSelectedBufferRange(rn)
            else
              rn = {start: ed.getCursorScreenPosition(),end: ed.getCursorScreenPosition()}
            #   rn = cur.getCurrentWordBufferRange wordRegex:regx
            # txt = ed.getTextInBufferRange(rn) if rn

          # ed.setTextInBufferRange rn,transform(txt,ed)
          # cur.setScreenPosition(pos,{autoscroll:false})
        else
          txt = selection.getText()
          rn = selection.getBufferRange()

        manipulateText = (transTxt)->
          if typeof transTxt is 'string'
            selection.insertText transTxt ,{select:true}
          else

            if transTxt.after
              multi(after)
            if transTxt.before
              multi(before)

            if transTxt.start
              multi(start)

            if transTxt.end
              multi(end)

        transTxt = transform(txt,rn,ed)
        if transTxt instanceof Promise
          transTxt.then (result)->
            manipulateText(result)
          ,(err)->
            atom.notifications.addError("Unable to transform",err)
        else
          manipulateText(transTxt)
