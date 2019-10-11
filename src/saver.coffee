fs = require 'fs-plus'
path = require 'path'
mkdirp = require 'mkdirp'
reader = require './reader'
Record = require './record'

exports.saveRequest = (req, db, callback) ->
  Record.createFromRequest req, (err, record) ->
    return callback new Error("Invalid breakpad request") if err?

    dist = "pool/files/minidump"
    mkdirp dist, (err) ->
      return callback new Error("Cannot create directory: #{dist}") if err?

      filename = path.join dist, record.id
      fs.copy record.path, filename, (err) ->
        return callback new Error("Cannot create file: #{filename}") if err?

        record.path = filename
        reader.createStackTraceFromRecord record, (err, report) ->
          return callback new Error("Cannot create stack trace #{filename}") if err?
          fs.writeFile filename, report, (err) ->
            return callback new Error("Cannot save stack info") if err?
            db.saveRecord record, (err) ->
              return callback new Error("Cannot save record to database") if err?
              callback null, filename
