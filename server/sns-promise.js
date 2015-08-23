
var AWS = require('aws-sdk')

var sns = new AWS.SNS({
  region: 'ap-northeast-1'
});

for (var method in sns) {
  if (typeof sns[method] === 'function')
    exports[method] = (function(method) {
      return function(params) {
        return new Promise(function(resolve, reject) {
          sns[method](params, function(err, result) {
            if (err)
              reject(err);
            else
              resolve(result);
          });
        });
      }
    })(method);
}