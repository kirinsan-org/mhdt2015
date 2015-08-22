var request = require('request-promise');
var xml2js = require('xml2js');
var builder = new xml2js.Builder();
var credentials = require('./credentials.json').gracenote;

module.exports = {
  search: function(artist, title) {

    var xml = builder.buildObject({
      QUERIES: {
        LANG: 'jpn',
        AUTH: {
          CLIENT: credentials.client,
          USER: credentials.user
        },
        QUERY: {
          $: {
            CMD: 'ALBUM_SEARCH'
          },
          MODE: 'SINGLE_BEST_COVER',
          TEXT: [{
            $: {
              TYPE: 'ARTIST'
            },
            _: artist
          }, {
            //   $: {
            //     TYPE: 'ALBUM_TITLE'
            //   },
            //   _: query
            // }, {
            $: {
              TYPE: 'TRACK_TITLE'
            },
            _: title
          }],
          OPTION: [{
            PARAMETER: 'SELECT_EXTENDED',
            VALUE: 'COVER,ARTIST_IMAGE,ARTIST_OET,MOOD,TEMPO'
          }, {
            PARAMETER: 'SELECT_DETAIL',
            VALUE: 'MOOD:1LEVEL,TEMPO:1LEVEL'
          }]
        }
      }
    });

    // console.log(xml)

    return request({
      uri: 'https://c' + credentials.client_id + '.web.cddbp.net/webapi/xml/1.0/',
      method: 'POST',
      body: xml
    }).then(function(data) {

      return new Promise(function(resolve, reject) {

        xml2js.parseString(data, function(err, xml) {

          if (err)
            reject(err);
          else
            resolve(convertGracenote(xml));

        });

      });
    })
  }
}

function convertGracenote(raw) {

  if (!raw.RESPONSES.RESPONSE || !raw.RESPONSES.RESPONSE[0] || !raw.RESPONSES.RESPONSE[0].ALBUM || !raw.RESPONSES.RESPONSE[0].ALBUM[0] || !raw.RESPONSES.RESPONSE[0].ALBUM[0].TRACK)
    return;

  var album = raw.RESPONSES.RESPONSE[0].ALBUM[0];
  var track = album.TRACK[0];

  // console.log(album)
  var result = {
    title: track.TITLE[0],
    artist: album.ARTIST[0]
  };

  if (album.URL) {
    result.image = album.URL[0]._;
  }

  // parse tempo
  if (track.TEMPO) {

    track.TEMPO.forEach(function(t) {
      var matchResult = t._.match(/(\d+)/);
      if (matchResult) {
        result.tempo = Number(matchResult[1]);
      }
    });
  }

  if (track.MOOD) {

    var color;
    switch (track.MOOD[0].$.ID) {
      case '65322':
      case '65323':
      case '65324':
      case '65325':
        color = {
          r: 1.0,
          g: 0.75,
          b: 0
        };
        break;
      case '42942':
      case '42946':
      case '42954':
      case '42947':
      case '65327':
        color = {
          r: 0.54,
          g: 0.76,
          b: 0.3
        };
        break;
      case '65326':
      case '42948':
      case '42949':
      case '65328':
      case '65329':
        color = {
          r: 0.25,
          g: 0.32,
          b: 0.71
        };
        break;
      case '42953':
      case '42951':
      case '42958':
      case '65330':
      case '42960':
      case '42961':
      case '65331':
      case '65332':
      case '65333':
      case '42945':
        color = {
          r: 0.96,
          g: 0.26,
          b: 0.21
        };
        break;
      case '42955':
      case '42966':
        color = {
          r: 1.0,
          g: 1.0,
          b: 1.0
        };
        break;
    }
    result.mood = {
      id: track.MOOD[0].$.ID,
      text: track.MOOD[0]._,
      color: color
    };
  }

  return result;
};
