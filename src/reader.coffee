fs = require 'fs-plus'
path = require 'path'
minidump = require 'minidump'
cache = require './cache'

exports.getStackTraceFromRecord = (record, callback) ->
  return callback(null, cache.get(record.id)) if cache.has record.id
  fs.readFile record.path, (err, content) ->
    cache.set record.id, content unless err?
    callback(err, content)

exports.createStackTraceFromRecord = (record, callback) ->
  symbolPaths = [ path.join 'pool', 'symbols' ]
  minidump.walkStack record.path, symbolPaths, (err, report) ->
    cache.set record.id, report unless err?
    callback err, report
