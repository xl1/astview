fs = require 'fs'
tokenizer = require 'glsl-tokenizer'
parser = require 'glsl-parser'
through = require 'through'
tograph = require '../common/tograph'


fs.createReadStream "#{__dirname}/source.fs", encoding: 'utf-8'
  .pipe tokenizer()
  .pipe parser()
  .pipe through (node) ->
    if node.parent and not node.parent.parent
      @queue node
  .pipe tograph __dirname, (node) ->
    if node.type isnt 'placeholder'
      id: node.id
      type: node.type
      token: node.token.data
      children: node.children
