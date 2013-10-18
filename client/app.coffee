console.log "App"
window.app = angular.module("Hackathon", ["ngRoute"])
  .config ($routeProvider) ->
    $routeProvider.when "/test",
      templateUrl: "test.html"
      controller: "TestApp"