#!/bin/bash -eu

mysql=( mysql --protocol=socket -uroot )

"${mysql[@]}" <<-EOSQL
  CREATE DATABASE IF NOT EXISTS history;
  GRANT ALL ON history.* TO '${MYSQL_USER}'@'%' ;
  CREATE DATABASE IF NOT EXISTS manager;
  GRANT ALL ON manager.* TO '${MYSQL_USER}'@'%' ;
EOSQL

cd /docker-entrypoint-initdb.d/

if [ -e ./${HISTORY_DUMP_FILENAME} ]; then
  echo "import history from ${HISTORY_DUMP_FILENAME}..."
  mysql --protocol=socket -u${MYSQL_USER} -p${MYSQL_PASSWORD} history < /sql/history.sql
fi

if [ -e ./${MANAGER_DUMP_FILENAME} ]; then
  echo "import manager from ${MANAGER_DUMP_FILENAME}..."
  mysql --protocol=socket -u${MYSQL_USER} -p${MYSQL_PASSWORD} manager < /sql/manager.sql
fi
