fs = require 'fs'

makeExecutable =  (filePath) ->
  new Promise((resolve, reject) ->
    fs.stat(filePath, (error, stat) ->
      return reject(error) if error
      newMode = (stat.mode | parseInt('0111', 8))
      return resolve() if stat.mode is newMode

      fs.chmod(filePath, newMode, (error) ->
        return reject(error) if error
        resolve()
      )
    )
  )

module.exports = {makeExecutable}
