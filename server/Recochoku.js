var request = require('request-promise');
var xml2js = require('xml2js');
var key = require('./credentials.json').recochoku.key;

module.exports = {
  search: function(query) {
    // レコチョク
    return request({
      uri: 'https://recoapi-mhd.cloud.recochoku.jp/v2/musics',
      headers: {
        'User-Agent': key
      },
      qs: {
        q: query
      }
    }).then(function(data) {

      return new Promise(function(resolve, reject) {
        xml2js.parseString(data, function(err, xml) {

          if (err)
            reject(err);
          else
            resolve(xml);

        });
      });

    })
  }
}
