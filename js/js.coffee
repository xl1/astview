fs = require 'fs'
uuid = require 'uuid'
esprima = require 'esprima'
Stream = require 'stream'
tograph = require '../common/tograph'


converters =
  AssignmentExpression:
    ({ operator, left, right }) -> [operator, [left, right]]
  ArrayExpression:
    ({ elements }) -> ['', elements]
  BlockStatement:
    ({ body }) -> ['', body]
  BinaryExpression:
    ({ operator, left, right }) -> [operator, [left, right]]
  BreakStatement:
    ({ label }) -> ['', [label]]
  CallExpression:
    (node) -> ['', node.arguments.concat [node.callee]]
  CatchClause:
    ({ param, body }) -> ['', [param, body]]
  ConditionalExpression:
    ({ test, alternate, consequent }) -> ['', [test, consequent, alternate]]
  ContinueStatement:
    ({ label }) -> ['', [label]]
  DoWhileStatement:
    ({ test, body }) -> ['', [body, test]]
  DebuggerStatement:
    -> ['']
  EmptyStatement:
    -> ['']
  ExpressionStatement:
    ({ expression }) -> ['', [expression]]
  ForStatement:
    ({ init, test, update, body }) -> ['', [init, test, update, body]]
  ForInStatement:
    ({ left, right, body }) -> ['', [left, right, body]]
  FunctionDeclaration:
    ({ id, params, body }) -> ['', [id].concat(params).concat [body]]
  FunctionExpression:
    ({ id, params, body }) -> ['', [id].concat(params).concat [body]]
  Identifier:
    ({ name }) -> [name]
  IfStatement:
    ({ test, consequent, alternate }) -> ['', test, [consequent, alternate]]
  Literal:
    ({ value }) -> [value]
  LabeledStatement:
    ({ label, body }) -> [label, [body]]
  LogicalExpression:
    ({ operator, left, right }) -> [operator, [left, right]]
  MemberExpression:
    ({ object, property, computed }) -> [(if computed then '[' else '.'), [object, property]]
  NewExpression:
    (node) -> ['', node.arguments.concat [node.callee]]
  ObjectExpression:
    ({ properties }) -> ['', properties]
  Program:
    ({ body }) -> ['', body]
  Property:
    ({ key, value }) -> ['', [key, value]]
  ReturnStatement:
    ({ argument }) -> ['', [argument]]
  SequenceExpression:
    ({ expressions }) -> ['', expressions]
  SwitchStatement:
    ({ descriminant, cases }) -> ['', [descriminant].concat cases]
  SwitchCase:
    ({ test, consequent }) -> ['', [test].concat consequent]
  ThisExpression:
    -> ['']
  ThrowStatement:
    ({ argument }) -> ['', [argument]]
  TryStatement:
    ({ block, handler, finalizer }) -> ['', [block, handler, finalizer]]
  UnaryExpression:
    ({ operator, argument }) -> [operator, [argument]]
  UpdateExpression:
    ({ operator, argument }) -> [operator, [argument]]
  VariableDeclaration:
    ({ declarations, kind }) -> [kind, declarations]
  VariableDeclarator:
    ({ id, init }) -> ['', [id, init]]
  WhileStatement:
    ({ test, body }) -> ['', [test, body]]
  WithStatement:
    ({ object, body }) -> ['', [object, body]]


stream = new Stream
stream.pipe tograph __dirname, (node) ->
  if node
    if node.type
      [token, children] = converters[node.type] node
      id: uuid.v4()
      type: node.type
      token: token
      children: children or []

fs.readFile "#{__dirname}/source.js", encoding: 'utf-8', (err, data) ->
  stream.emit 'data', esprima.parse data
  stream.emit 'end'
