var os = require('os')
  , mongo = require('mongoskin')
  , client = mongo.db('http://192.168.33.10:27017/test', {w: 1})
  , tags = client.collection('tags');
/*
 * GET home page.
 */

exports.index = function(req, res) {
  tags.count(function(err, count) {
    if (err) throw err;
    res.render('index', { title: 'Express on ' + os.hostname() + " " + count});
  });
};
