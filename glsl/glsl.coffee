fs = require 'fs'
uuid = require 'uuid'
tokenizer = require 'glsl-tokenizer'
parser = require 'glsl-parser'
through = require 'through'
tograph = require '../common/tograph'


fs.createReadStream "#{__dirname}/source.fs", encoding: 'utf-8'
  .pipe tokenizer()
  .pipe parser()
  .pipe through (node) ->
    if not node.parent
      @queue node
  .pipe tograph __dirname, (node) ->
    if node.type isnt 'placeholder'
      id: uuid.v4()
      type: node.type
      token: node.token.data
      children: node.children
