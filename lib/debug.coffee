util = require "util"
module.exports = (args...) -> 
  console.log (
    for arg in args
      switch typeof arg
        when "object"
          util.inspect arg, colors: true, depth: null
        else
          arg
  )...
