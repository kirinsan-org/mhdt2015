var request = require('request-promise');
var xml2js = require('xml2js');
var clientId = require('./credentials.json').soundcloud.client_id;

module.exports = {
  search: function(query) {
    return request({
      uri: 'https://api.soundcloud.com/tracks',
      qs: {
        client_id: clientId,
        q: query
      },
      json: true
    })
  }
}
