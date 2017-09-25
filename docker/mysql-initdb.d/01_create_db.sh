#!/bin/bash -eu

mysql=( mysql --protocol=socket -uroot )

"${mysql[@]}" <<-EOSQL
  CREATE DATABASE IF NOT EXISTS ophis;
  GRANT ALL ON ophis.* TO '${MYSQL_USER}'@'%' ;
  CREATE DATABASE IF NOT EXISTS umi;
  GRANT ALL ON umi.* TO '${MYSQL_USER}'@'%' ;
EOSQL

cd /docker-entrypoint-initdb.d/

if [ -e ./${OPHIS_DUMP_FILENAME} ]; then
  echo "import ophis from ${OPHIS_DUMP_FILENAME}..."
  mysql --protocol=socket -u${MYSQL_USER} -p${MYSQL_PASSWORD} ophis < /sql/ophis.sql
fi

if [ -e ./${UMI_DUMP_FILENAME} ]; then
  echo "import umi from ${UMI_DUMP_FILENAME}..."
  mysql --protocol=socket -u${MYSQL_USER} -p${MYSQL_PASSWORD} umi < /sql/umi.sql
fi
