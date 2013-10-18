module.exports = (name) ->
  require("optimist")
    .usage("""
      #{name + " running server".inverse}
      #{"Usage".yellow}: $0 [-p|--port Number]
     """)
    .describe("port", "Listenning server port number")
    .alias("p", "port")
    .default("port", 4242)
    .check (args) ->
      not isNaN parseInt args.port
    .argv
