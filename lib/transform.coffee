str = require 'underscore.string'
module.exports =
  upper: (txt)->
    txt.toUpperCase()
  lower: (txt)->
    txt.toLowerCase()
  trim : (txt)->
    str.trim(txt)
  swapCase:(txt)->
    str.swapCase(txt)
  capitalize:(txt)->
    str.capitalize(txt)
  titleize:(txt)->
    str.titleize(txt)
  camelize:(txt)->
    str.camelize(txt)
  classify:(txt)->
    str.classify(txt)
  underscored:(txt)->
    str.underscored(txt)
  dasherize:(txt)->
    str.dasherize(txt)
  humanize:(txt)->
    str.humanize(txt)
  slugify:(txt)->
    str.slugify(txt)
  stripTags:(txt)->
    str.stripTags(txt)
  escapeHTML:(txt)->
    str.escapeHTML(txt)
  unescapeHTML:(txt)->
    str.unescapeHTML(txt)
