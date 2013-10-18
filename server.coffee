SERVICE_NAME = "Hackathon"

require "colors"
require "./config/globals"


{port: PORT} = (require("./config/arguments") SERVICE_NAME)


require("zappajs") PORT, ->
  @server.on "listening", -> o_ "#{SERVICE_NAME} server listening on".rainbow.inverse, "#{PORT}".green
  @use logger: "dev", "static"
  @io.set "log level", 0
  @set "view engine": "jade"

  @get "/": -> 
    @render "index.jade",
      service_name: SERVICE_NAME

  @include "./config/builders"

