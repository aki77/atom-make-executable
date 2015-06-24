path = require 'path'
temp = require 'temp'
fs = require 'fs-plus'
{makeExecutable} = require '../lib/helper'

describe "helper", ->
  [directory] = []

  results =
    '0644': '0755'
    '0600': '0711'
    '0755': '0755'

  beforeEach ->
    directory = temp.mkdirSync()

  describe 'makeExecutable', ->
    Object.keys(results).forEach((mode) ->
      result = results[mode]

      it "#{mode} -> #{result}", ->
        filePath = path.join(directory, 'atom-make-executable')
        fs.writeFileSync(filePath, 'test', {mode})
        stat = fs.statSync(filePath)
        expect(stat.mode.toString(8)).toEqual("10#{mode}")

        waitsForPromise ->
          makeExecutable(filePath)

        runs ->
          stat = fs.statSync(filePath)
          expect(stat.mode.toString(8)).toEqual("10#{result}")
    )
