var express = require('express');
var router = express.Router();

/* GET users listing. */
router.post('/', function(req, res, next) {
  console.log(req.body);

  var username = req.body.username;
  var password = req.body.password;

  if ( username == 'soojin' && password == '1234') {
  	res.status(200).send('success');
  } else {
	res.status(401).send('failed auth');
  }
});

module.exports = router;
