fs = require 'fs'
{ exec } = require 'child_process'
through = require 'through'


transform = (getInfo) -> (program) ->
  result = []
  walk = ({ id, type, token, children }, path) ->
    path += '/' + id
    result.push "  \"#{path}\" [label = \"#{type}:#{token}\"];"
    for child in children or []
      if childInfo = getInfo child
        result.push "  \"#{path}\" -> \"#{path}/#{childInfo.id}\";"
        walk childInfo, path

  if programInfo = getInfo program
    result.push 'digraph {'
    walk programInfo, ''
    result.push '}'
    @queue result.join '\n'


module.exports = (dir, getInfo) ->
  s = through transform getInfo
  s.pipe fs.createWriteStream "#{dir}/result.dot", encoding: 'utf-8'
    .on 'finish', ->
      exec "dot -Tpng -o#{dir}/result.png #{dir}/result.dot", (e, out, err) ->
        console.log out + err
  s
