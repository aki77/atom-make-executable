path = require 'path'
{CompositeDisposable} = require 'atom'
helper = require './helper'

module.exports =
  config:
    disabledExtensions:
      type: 'array'
      default: []

  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add(atom.workspace.observeTextEditors((editor) =>
      @handleEvents(editor)
    ))

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  handleEvents: (editor) ->
    editorSavedSubscription = editor.onDidSave( =>
      @makeExecutableIfScript(editor)
    )

    editorDestroyedSubscription = editor.onDidDestroy( =>
      editorSavedSubscription.dispose()
      editorDestroyedSubscription.dispose()

      @subscriptions.remove(editorSavedSubscription)
      @subscriptions.remove(editorDestroyedSubscription)
    )

    @subscriptions.add(editorSavedSubscription)
    @subscriptions.add(editorDestroyedSubscription)

  makeExecutableIfScript: (editor) ->
    fileExtension = path.extname(editor.getPath())
    fileExtension = fileExtension.substr(1)
    return if fileExtension in atom.config.get('make-executable.disabledExtensions')

    shebang = editor.getTextInBufferRange([[0, 0], [0, 2]])
    return unless shebang is '#!'

    helper.makeExecutable(editor.getPath()).catch((error) ->
      atom.notifications.addError('make-executable error', detail: error)
    )
