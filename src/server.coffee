nodeStatic = require('node-static')
file = new nodeStatic.Server('./public')

handler = (request, response) ->
  console.log 'request came in'
  request.addListener 'end', () ->
    file.serve request, response, (e, err) ->
      console.log 'server static'
      if (e && (e.status == 404))
        console.log 'file not found'

app = require('http').createServer(handler)
io = require('socket.io').listen(app)

io.sockets.on 'connection', (socket) ->
  Tweet.find().limit(10).asc('created_at').run (err,docs) ->
    if err
      console.log err
    else
      for tweet in docs
        socket.emit 'tweet', {message: tweet.message, username: tweet.username, teams: tweet.teams}

app.listen 8080, () ->
  console.log '%s listening at %s', app.host, app.port

mongoose = require 'mongoose'
twitter = require './immortal-ntwitter.js'

config =
  consumer_key: 'sPzcEJQnfKd5rjWx61yDFw'
  consumer_secret: 'oJ62zzIpcckfsqysjxjOkXCgUwCMvDhe6HjuVI6fmY0'
  access_token_key: '14217347-duzlvWOWTgXwD3lme1niJnjhHPFkh0jLo2O5gucoV'
  access_token_secret: 'oEUbZJBDJ4H8rMbMeOQUIuHmWct82uPv5ftuZmzlPrI'

teams = ['Redskins', 'Terps', 'Ravens', 'Hokies']

mongodb = mongoose.connect('mongodb://moveline:moveline@ds031857.mongolab.com:31857/moveline')

TweetSchema = new mongoose.Schema({
  message: String
  username: String
  created_at: Date
  teams: [String]
})

Tweet = mongoose.model('Tweets', TweetSchema)

twit = new twitter(config)
twit.immortalStream 'statuses/filter', {"track": teams.join(",")}, (stream) ->
  stream.on 'data', (data) ->
    tweet = new Tweet()
    tweet.message = data.text
    tweet.username = data.user.name
    tweet.created_at = data.created_at
    for team in teams
      if data.text.indexOf(team) isnt -1
        tweet.teams.push(team)

    tweet.save (err) ->
      if err
        console.log err
      else
        console.log tweet.teams.join(', '), tweet.message
        io.sockets.emit('tweet', {message: tweet.message, username: tweet.username, teams: tweet.teams})

