var sns = require('./sns-promise.js')
var TOPIC_ARN = 'arn:aws:sns:ap-northeast-1:719986071946:MusicHackDayTokyo2015-global';
var APPRICATION_ARN_GCM = 'arn:aws:sns:ap-northeast-1:719986071946:app/GCM/nemimi';
var APPRICATION_ARN_APNS = 'arn:aws:sns:ap-northeast-1:719986071946:app/APNS_SANDBOX/MusicHackDayTokyo2015';

module.exports = {

  registerAPNS: function(token) {

    // create endpoint
    return sns.createPlatformEndpoint({
      PlatformApplicationArn: APPRICATION_ARN_APNS,
      Token: token,
      CustomUserData: String(Date.now())
    }).then(function(data) {

      var endpointArn = data.EndpointArn;

      var params = {
        Protocol: 'application',
        TopicArn: TOPIC_ARN,
        Endpoint: endpointArn
      };

      return sns.subscribe(params);

    });
  },

  registerGCM: function(token) {

    // create endpoint
    return sns.createPlatformEndpoint({
      PlatformApplicationArn: APPRICATION_ARN_GCM,
      Token: token,
      CustomUserData: String(Date.now())
    }).then(function(data) {

      var endpointArn = data.EndpointArn;

      var params = {
        Protocol: 'application',
        TopicArn: TOPIC_ARN,
        Endpoint: endpointArn
      };

      return sns.subscribe(params);

    });
  },

  listArn: function() {

    return sns.listSubscriptionsByTopic({
      TopicArn: TOPIC_ARN
    })
  },

  broadcast: function(track, from) {

    return sns.publish({
      Message: JSON.stringify({
        'default': 'This is default Message!',
        'APNS': JSON.stringify({
          track: track,
          from: from
        }),
        'GCM': JSON.stringify({
          data: {
            track: track,
            from: from
          }
        })
      }),
      MessageStructure: 'json',
      TopicArn: TOPIC_ARN
    })

  }

};
