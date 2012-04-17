mongoose = require 'mongoose'
twitter = require './immortal-ntwitter.js'

config =
  consumer_key: 'sPzcEJQnfKd5rjWx61yDFw'
  consumer_secret: 'oJ62zzIpcckfsqysjxjOkXCgUwCMvDhe6HjuVI6fmY0'
  access_token_key: '14217347-duzlvWOWTgXwD3lme1niJnjhHPFkh0jLo2O5gucoV'
  access_token_secret: 'oEUbZJBDJ4H8rMbMeOQUIuHmWct82uPv5ftuZmzlPrI'

track = ['Redskins', 'Terps', 'Ravens', 'Hokies']

mongodb = mongoose.connect('mongodb://moveline:moveline@ds031857.mongolab.com:31857/moveline')

TweetSchema = new mongoose.Schema({
  message: String
  username: String
})

Tweet = mongoose.model('Tweets', TweetSchema)

twit = new twitter(config)
twit.immortalStream 'statuses/filter', {"track": track.join(",")}, (stream) ->
  stream.on 'data', (data) ->
    tweet = new Tweet()
    tweet.message = data.text
    tweet.username = data.user.name
    tweet.save (err) ->
      if err
        console.log err
      else
        console.log tweet.message

http = require('http')
static = require('node-static')
file = new static.Server('../public')

server = http.createServer (request, response) ->
  request.addListener 'end', () ->
    file.serve(request, response)


server.listen 8080, () ->
  console.log '% listening at %s', server.name, server.url
