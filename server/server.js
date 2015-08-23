var express = require('express');
var cors = require('cors');
var app = express();
var credentials = require('./credentials.json');
var sns = require('./sns.js');

app.use(cors());

var Spotify = require('./Spotify.js');
var Recochoku = require('./Recochoku.js');
var SoundCloud = require('./SoundCloud.js');
var Gracenote = require('./Gracenote.js');

app.use(express.static(__dirname + '/public'));

app.get('/search', function(req, res, next) {

  var promises = [

    Spotify.search(req.query.q),
    SoundCloud.search(req.query.q),
    Recochoku.search(req.query.q)

  ];

  Promise.all(promises).then(function(data) {

    var spotify = convertSpotify(data[0]);
    var soundcloud = convertSoundCloud(data[1]);
    var recochoku = convertRecochoku(data[2]);

    var array = spotify.results
      .concat(soundcloud.results)
      .concat(recochoku.results)
      .filter(function(item) {
        return item.url && item.image
      });

    res.json({
      results: array
    });

  }, next);
});

app.get('/details', function(req, res, next) {

  Gracenote.search(req.query.artist, req.query.title).then(function(result) {
    res.json(result);
  }, next)
})

app.get('/registerAPNS', function(req, res, next) {

  sns.registerAPNS(req.query.token)
    .then(function(result) {
      res.json(result);
    }, next);

})

app.get('/registerGCM', function(req, res, next) {

  sns.registerGCM(req.query.token)
    .then(function(result) {
      res.json(result);
    }, next);

})

app.get('/listArn', function(req, res, next) {

  sns.listArn()
    .then(function(result) {
      res.json(result.Subscriptions.map(function(i) {
        return i.Endpoint
      }));
    }, next);

})

app.get('/broadcast', function(req, res, next) {
  sns.broadcast({
    id: req.query.id,
    title: req.query.title,
    image: req.query.image,
    artist: req.query.artist,
    url: req.query.url,
    source: req.query.source
  }, {
    arn: req.query.arn,
    avator: req.query.avator
  }).then(function(result) {
    res.json(result);
  }, next);

})

app.listen(8888, function() {
  console.log('Started');
});

function convertSoundCloud(raw) {

  return {
    results: raw.map(function(i) {
      return {
        id: String(i.id),
        title: i.title,
        image: i.artwork_url || i.user.avatar_url,
        artist: i.user.username,
        url: i.stream_url + '?client_id=' + credentials.soundcloud.client_id,
        source: 'soundcloud'
      }
    })
  };

}

function convertSpotify(raw) {

  return {
    results: raw.body.tracks.items.map(function(i) {
      return {
        id: i.id,
        title: i.name,
        image: i.album && i.album.images && i.album.images[0] && i.album.images[0].url,
        artist: i.artists[0].name,
        url: i.preview_url,
        source: 'spotify'
      }
    })
  };
}

function convertRecochoku(raw) {

  if (!raw.musics || !raw.musics.music || !raw.musics.music.map) {
    return {
      results: []
    };
  }

  return {
    results: raw.musics.music.map(function(m) {

      var result = {
        id: m.id[0],
        title: m.title[0]._,
        artist: m.artist[0].name[0]._,
        source: 'recochoku'
      };

      if (m.link) {
        m.link.forEach(function(link) {
          if (link.$.rel === 'photo') {
            result.image = link.$.href;
          }
        });
      }

      if (m.trials && m.trials[0] && m.trials[0].trial && m.trials[0].trial[0] && m.trials[0].trial[0].link && m.trials[0].trial[0].link[0] && m.trials[0].trial[0].link[0].$.href) {
        result.url = m.trials[0].trial[0].link[0].$.href;
      }

      return result;
    })
  };
}
