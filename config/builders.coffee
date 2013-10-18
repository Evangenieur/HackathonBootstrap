FS = require "q-io/fs"
watchr = require "watchr"
coffee = require "coffee-script"

@include = ->
  directories = 

    vendor: 
      dir: "./public/vendors"
      route: "/js/vendors/"
      bundle: "/js/vendors/all.js"
      files: {}

    client:
      dir: "./client"
      route: "/js/"
      bundle: "/js/client-all.js"
      files: {}

  

  local_file2route = (filename, dir_props) ->
    dir_props.route + filename[(dir_props.dir.length - 1)..-1]
      .replace(".coffee", ".js")

  route2local_file = (filename, dir_props) ->
    dir_props.dir + filename[(dir_props.route.length - 1)..-1]

  read_javascript = (filename) ->
    if filename.match /\.js$/
      FS.read(filename).then (data) ->
        _.object [filename], [data]
    else if filename.match /\.coffee$/
      FS.read(filename)
        .then (data) ->          
          _.object(
            [filename.replace(".coffee", ".js")]
            [coffee.compile data]
          )

  update_file_data = (props) -> (js_entry) ->
    _(props.files).extend \
      _.object(
        [local_file2route( _(js_entry).chain().keys().value()[0], props)]
        _(js_entry).values()
      )

  Q.all(

    _(directories).map (props, name) ->
      FS.listTree(props.dir).then (files) ->
        Q.all(
          _(files).map (file) -> read_javascript file
        )
        
        .then (js_files_data) ->
          _(js_files_data).chain().compact().each update_file_data props
        
  ).done =>
    _(directories).each (dir_props, dir_name) =>
      
      # Bundle #
      @app.get dir_props.bundle, (req, res) ->
        res.header "Content-Type", "text/javascript"
        res.send _(dir_props.files).reduce(
          (memo, data, filename) ->
              memo += "/* ####### #{filename} ####### */\n"
              memo += data + "\n"
          "")

      # Individual
      @app.get dir_props.route + "*", (req, res) ->
        res.header "Content-Type", "text/javascript"
        res.send dir_props.files[req.url] or 404
      
      # Watch
      watchr.watch 
        path: dir_props.dir
        listener: (event, filename) ->
          filename = filename
          o_ "watchr :".yellow, "'#{event.green}'", filename
          switch event
            when "create", "update"
              read_javascript(filename).then update_file_data dir_props
            when "delete"
              o_ filename, local_file2route filename, dir_props, dir_props[local_file2route filename, dir_props]?
              delete dir_props.files[local_file2route filename, dir_props]
