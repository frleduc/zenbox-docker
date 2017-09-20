var proxy = require('express-http-proxy');
var express = require('express');
var app = express();

app.use('/', express.static('static'));
app.use('/api', proxy('api:8080', {
  filter: function(req, res) {
    //console.log(req);
     return true;
  },
  forwardPath: function(req, res) {
    return '/api/' + require('url').parse(req.url).path;
  }
}));

var server = app.listen(3000, function () {});
