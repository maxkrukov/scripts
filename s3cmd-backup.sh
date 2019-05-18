#!/bin/bash -e

export BUCKET='s3://gadfull/mysql/backup-new'

cd /var/www

mysqldump_() {
 docker-compose exec -T docker-mysql mysqldump -ueva -p02hDPHr73TP66Nr1c eva 2>/dev/null | gzip
}

d1=$(date +%s)
d2=$(date +%F)


mysqldump_ | s3cmd put - ${BUCKET}/eva-$d1-$d2.sql.gz


limit() {
    count=$(s3cmd ls $1 | wc -l)
    del=$(($count-$2))

    if [ $del -gt 0 ]; then
      ( s3cmd ls $1 | head -$del | awk '{print$NF}' | xargs s3cmd rm ) || true
    else
       echo "no backups to delete"
    fi 
}

#annual
s3cmd ls  ${BUCKET}/ | grep '.sql.gz' | grep -E "^[0-9]{4}-02-16" | awk '{print$NF}' | while read file; do
    s3cmd mv $file ${BUCKET}/annual/$(basename $file)
done
limit ${BUCKET}/annual/ 3


#monthly
s3cmd ls  ${BUCKET}/ | grep '.sql.gz' | grep -E "^[0-9]{4}-[0-9]{2}-01" | awk '{print$NF}' | while read file; do
    s3cmd mv $file ${BUCKET}/monthly/$(basename $file)
done
limit ${BUCKET}/monthly/ 12


#daily
s3cmd ls  ${BUCKET}/ | grep '.sql.gz' | grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}" | awk '{print$NF}' | while read file; do
    s3cmd mv $file ${BUCKET}/daily/$(basename $file)
done
limit ${BUCKET}/daily/ 14
