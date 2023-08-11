#!/bin/sh

for _var in $(env | cut -f1 -d"="); do
    case $_var in (*_FILE)
		# echo "_var : >"$_var"<"
		
		_key="${_var%_FILE}"
		# echo "_key : >"$_key"<"
		
		eval "_path=\$$_var"
		# echo "_path : >"$_path"<"
		
		_value="$(cat "$_path")"
		# echo "_value : >"$_value"<"
		
        echo "$_key" set to "$_value"
		export "$_key"="$_value"
    ;;esac
done

if ! [ -r /etc/dovecot/dh.pem.created ]
then
  echo "Using pre-generated Diffie Hellman parameters until the new one is generated."
  /usr/local/bin/dh.sh &
fi

rm -f /run/dovecot/master.pid

dockerize \
  -template /etc/dovecot/conf.d/10-master.conf.templ:/etc/dovecot/conf.d/10-master.conf \
  -template /etc/dovecot/conf.d/15-lda.conf.templ:/etc/dovecot/conf.d/15-lda.conf \
  -template /etc/dovecot/conf.d/15-fts-xapian.conf.templ:/etc/dovecot/conf.d/15-fts-xapian.conf \
  -template /etc/dovecot/conf.d/90-sieve.conf.templ:/etc/dovecot/conf.d/90-sieve.conf \
  -template /etc/dovecot/dovecot-sql.conf.ext.templ:/etc/dovecot/dovecot-sql.conf.ext \
  -wait tcp://${MYSQL_HOST}:${MYSQL_PORT} \
  -wait file://${SSL_CERT} \
  -wait file://${SSL_KEY} \
  -timeout ${WAITSTART_TIMEOUT} \
  /usr/sbin/dovecot -F
