var os = require('os')
  , mongo = require('mongoskin')
  , client = mongo.db('http://33.33.13.37:27017/test', {w: 1})
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
