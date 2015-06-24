path = require 'path'
temp = require 'temp'
fs = require 'fs-plus'
helper = require '../lib/helper'

describe "MakeExecutable", ->
  [activationPromise, editor, textFilePath, mainModule] = []

  beforeEach ->
    activationPromise = atom.packages.activatePackage('make-executable')

    directory = temp.mkdirSync()
    atom.project.setPaths([directory])
    filePath = path.join(directory, 'atom-make-executable')
    textFilePath = path.join(directory, 'sample.txt')
    fs.writeFileSync(filePath, '')
    fs.writeFileSync(textFilePath, '')

    atom.config.set('make-executable.disabledExtensions', [])

    waitsForPromise ->
      activationPromise.then((pack) ->
        {mainModule} = pack
        spyOn(helper, 'makeExecutable').andCallFake( ->
          new Promise((resolve) -> resolve())
        )
      )

    waitsForPromise ->
      atom.workspace.open(filePath).then((_editor) ->
        editor = _editor
      )

  describe "when 'make-executable.disabledExtensions' is []", ->
    it 'no script', ->
      editor.setText('hello')
      editor.save()
      expect(helper.makeExecutable).not.toHaveBeenCalled()

    it 'script', ->
      editor.setText("#!/bin/sh\n\necho 'hello'")
      editor.save()
      expect(helper.makeExecutable).toHaveBeenCalled()

    it 'text file', ->
      [otherEditor] = []
      waitsForPromise ->
        atom.workspace.open(textFilePath).then((_editor) ->
          otherEditor = _editor
        )

      runs ->
        otherEditor.setText("#!/bin/sh\n\necho 'hello'")
        otherEditor.save()
        expect(helper.makeExecutable).toHaveBeenCalled()

  describe "when 'make-executable.disabledExtensions' is ['txt']", ->
    beforeEach ->
      atom.config.set('make-executable.disabledExtensions', ['txt'])

    it 'no script', ->
      editor.setText('hello')
      editor.save()
      expect(helper.makeExecutable).not.toHaveBeenCalled()

    it 'script', ->
      editor.setText("#!/bin/sh\n\necho 'hello'")
      editor.save()
      expect(helper.makeExecutable).toHaveBeenCalled()

    it 'text file', ->
      [otherEditor] = []
      waitsForPromise ->
        atom.workspace.open(textFilePath).then((_editor) ->
          otherEditor = _editor
        )

      runs ->
        otherEditor.setText("#!/bin/sh\n\necho 'hello'")
        otherEditor.save()
        expect(helper.makeExecutable).not.toHaveBeenCalled()
