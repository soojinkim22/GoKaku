var mysql = require("mysql");
var Pool = undefined;

// MySQL用のConnection poolの初期化
exports.init = function() {
  var config = {
    host: 'mysql',
    port: 3306,
    user: 'root',
    password: null,
    database: 'manager',
    connectionLimit: 16,
    queueLimit: 0,
    multipleStatements: false
  };

  Pool = mysql.createPool(config);

  Pool.on("error", err=> {
    console.error(err.stack);     
  });
}

// Query実行
exports.query = function(sql, data, callback) {
  Pool.query(sql, data, (err, rows) => {
    callback(err, rows);
    return
  });
}
