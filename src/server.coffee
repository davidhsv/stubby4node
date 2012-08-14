#!/usr/bin/env coffee

Admin = require('./portals/admin').Admin
Stub = require('./portals/stub').Stub
Endpoint = require('./models/endpoint').Endpoint
CLI = require('./cli').CLI
http = require 'http'

args = CLI.getArgs()
endpoint = new Endpoint(args.file)

onListening = (portal, port) ->
   CLI.info "#{portal} portal running at localhost:#{port}"
onError = (err, port) ->
   switch err.code
      when 'EACCES'
         CLI.error "Permission denied for use of port #{port}. Exiting..."
         process.exit()
      when 'EADDRINUSE'
         CLI.error "Port #{port} is already in use! Exiting..."
         process.exit()

stubServer = (new Stub(endpoint)).server
stubServer = http.createServer(stubServer)
stubServer.on 'listening', -> onListening 'Stub', args.stub
stubServer.on 'error', (err) -> onError(err, args.stub)
stubServer.listen args.stub

adminServer = (new Admin(endpoint)).server
adminServer = http.createServer(adminServer)
adminServer.on 'listening', -> onListening 'Admin', args.admin
adminServer.on 'error', (err) -> onError(err, args.admin)
adminServer.listen args.admin

console.log '\nLog:'
