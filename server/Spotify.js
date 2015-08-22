var credentials = require('./credentials.json').spotify
var userId = null;

var SpotifyWebApi = require('spotify-web-api-node');

// credentials are optional
var spotifyApi = new SpotifyWebApi({
  clientId: credentials.clientId,
  clientSecret: credentials.clientSecret,
  redirectUri: 'http://localhost:8888/callback'
});

module.exports = {
  search: function(query) {
    return spotifyApi.searchTracks(query);
  }
}
