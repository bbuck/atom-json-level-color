# coffeelint: disable=max_line_length
stream = require("stream")
path = require("path")
fs = require("fs")

defaultDepth = 10
defaultColors = "#c792ea, #ffcb6b, #f78c6c, #ff5370, #c17e70, #82aaff, #f07177"

module.exports =
  config:
    MaximumDepth:
      type: "number"
      default: defaultDepth
      description: "You may never need to set ths, but this controls how deep the styles get generated for the coloring the keys. After this point it falls back to syntax theme. <br /></br /><strong>You must reload after changing this value.</strong>"
    Colors:
      type: "string"
      default: defaultColors
      description: "Provide a list of CSS colors to use per level. The list can be as long or as short as you prefer. <br /><br /><strong>You must reload after changing this value.</strong>"

currentDepth = atom.config.get("json-level-color.MaximumDepth") or defaultDepth
currentColors = atom.config.get("json-level-color.Colors") or defaultColors

varFilename = path.join(atom.packages.getPackageDirPaths().toString(),
  "json-level-color",
  "styles",
  "json-level-color-variables.less"
)

console.log varFilename

atom.config.onDidChange "json-level-color.MaximumDepth", ({newValue, oldValue}) ->
  if newValue? and oldValue isnt newValue
    currentDepth = newValue
  configureCSS()

atom.config.onDidChange "json-level-color.Colors", ({newValue, oldValue}) ->
  if newValue? and oldValue isnt newValue
    currentColors = newValue
  configureCSS()

configureCSS = ->
  vars = getVarStream()
  writer = fs.createWriteStream(varFilename)
  vars.pipe(writer)

# helpers

getVarStream = ->
  vars = stream.Readable()
  vars._read = (->)
  vars.push("""
@defined-colors: #{currentColors};
@depth: #{currentDepth};
  """)
  vars.push(null)
  vars
