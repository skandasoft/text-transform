{View,$} = require 'atom-space-pen-views'

class Feeler extends View
  initialize: (@tt)->

  @content: ->
    display = atom.config.get('text-transform.display')
    @div class: "text-transform-feeler #{display}", outlet: 'feeler',mouseover: 'mouseOver'

  mouseOver: (evt)->
    @tt.toggle()


class TextTransformView extends View

  initialize: (transforms,@tt)->
    hideLib = (grammar)=>
      fileTypes = grammar.fileTypes
      utls =  @find('.transform-require')
      for utl in utls
        $utl = $(utl)
        types = $utl.data('filetypes').split(',')
        for typ in types
          if typ in fileTypes
            $utl.show()
            return

        $utl.hide()

    grammar = atom.workspace.getActiveTextEditor()?.getGrammar()
    hideLib(grammar) if grammar
    atom.workspace.onDidChangeActivePaneItem (activePane)=>
      return unless( activePane?.getGrammar?()? )
      hideLib activePane.getGrammar()
      subscribe?.dispose?()
      subscribe = activePane.onDidChangeGrammar?  (grammar)->
        hideLib grammar

    @find('.transform-heading').parent().children('.transform-items').hide()
  @content: (transforms)->
    display = atom.config.get('text-transform.display')
    @div class: "text-transform #{display}", =>
      # @div class: 'text-transform-panel',  outlet: 'panel', =>
      @div class:'resizer-drag', mousedown: 'dragStart'
      @h1 'Text Transform'
      @div class:'transforms', click:'transform', =>
        @subview 'transforms', new TransformView(transforms,@tt)


  transform: (evt,view)->
    if (div = $(evt.target))?.hasClass('transform-item')
      atom.commands.dispatch atom.views.getView(atom.workspace.getActiveTextEditor()), "text-transform:"+div.text()
    if (div = $(evt.target))?.hasClass('transform-heading')
      $(evt.target).parent().children(".transform-items").slideToggle("slow")

  dragStart: (evt,ele)->
      parent = @view().parent()
      view = @view()
      @orgWidth = view.width() unless @orgWidth
      width = view.width()
      left = parent.position().left
      view.css position :'fixed'
      view.css left: evt.pageX
      view.css width: width

      $(document).mousemove (evt,ele)=>
        view = @view()
        parent = @view().parent()
        parent.css left: evt.pageX
        view.css left: evt.pageX
        wd = width + left - evt.pageX
        if wd < @orgWidth
          wd = @orgWidth
        view.css width: wd

      $(document).mouseup (evt,ele)=>
        view = @view().view()
        parent = @view().parent()
        parent.css left: 0
        view.css position :'static'
        $(document).unbind('mousemove')


  @initialize:(state)->

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()


class TransformView extends View
  initialize: (transforms,@tt)->

  @content: (transforms=[])->
    @div class:'transform-items', =>
      for transform in transforms
        if typeof transform is 'string'
          @div class:'transform-item', transform
        else
          @div class:'transform-require', 'data-fileTypes':transform['fileTypes'], 'data-scopeName':transform['scopeName'], =>
            @h2 class:'transform-heading', transform['heading']
            @subview 'transform-subs', new TransformView(transform['fun'])

module.exports = {TextTransformView,Feeler}
