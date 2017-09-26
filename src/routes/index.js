var express = require('express');
var router = express.Router();
var users = require('./users');
var auth = require('./auth');

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

router.get('/:view', function(req, res, next) {
  var view = req.params.view;
  res.render(view, { title: 'Express' });
});

router.use('/api/users', users);
router.use('/api/auth', auth);

module.exports = router;
