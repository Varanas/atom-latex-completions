fs = require 'fs'
path = require 'path'

module.exports =
  scopeSelector: '.source, .text'
  disableForScopeSelector: '.tex, .latex'
  textEditorSelectors: 'atom-text-editor'
  filterSuggestions: true
  inclusionPriority: 5

  getTextEditorSelector: -> 'atom-text-editor'

  completions: {}

  texPattern: /\\([\w\d^-]*)$/

  load: (p) ->
    @scopeSelector = atom.config.get("latex-completions.selector")
    @disableForScopeSelector = atom.config.get("latex-completions.disabledScopes")
    return if p == ''
    p ?= path.resolve(__dirname, '..', 'completions', 'completions.json')
    fs.readFile p, (error, content) =>
      return if error?
      for name, char of JSON.parse(content)
        @completions[name] = char

  getSuggestions: ({bufferPosition, editor}) ->
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    prefix = line.match(@texPattern)?[1]
    prefix? && ({text: word, leftLabel: char, replacementPrefix: prefix} for word, char of @completions)

  onDidInsertSuggestion: ({editor, triggerPosition, suggestion}) ->
    word = suggestion.text
    editor.selectLeft(word.length + 1)
    editor.insertText(@completions[word])
