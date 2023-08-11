#!/bin/sh
set -e

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

postconf myhostname="${MAILNAME}"
postconf mynetworks="${MYNETWORKS}"
postconf recipient_delimiter="${RECIPIENT_DELIMITER}"
postconf smtpd_milters="inet:${RSPAMD_HOST}:11332"
postconf non_smtpd_milters="inet:${RSPAMD_HOST}:11332"

if [ "${FILTER_MIME}" == "true" ]
then
  postconf mime_header_checks=regexp:/etc/postfix/mime_header_checks
fi

if [ "${RELAYHOST}" != "false" ]
then
  postconf relayhost=${RELAYHOST}
fi

dockerize \
  -template /etc/postfix/mysql-email2email.cf.templ:/etc/postfix/mysql-email2email.cf \
  -template /etc/postfix/mysql-virtual-alias-maps.cf.templ:/etc/postfix/mysql-virtual-alias-maps.cf \
  -template /etc/postfix/mysql-virtual-mailbox-domains.cf.templ:/etc/postfix/mysql-virtual-mailbox-domains.cf \
  -template /etc/postfix/mysql-virtual-mailbox-maps.cf.templ:/etc/postfix/mysql-virtual-mailbox-maps.cf \
  -template /etc/postfix/mysql-recipient-access.cf.templ:/etc/postfix/mysql-recipient-access.cf \
  -template /etc/postfix/mysql-email-submission.cf.templ:/etc/postfix/mysql-email-submission.cf \
  -wait tcp://${MYSQL_HOST}:${MYSQL_PORT} \
  -wait tcp://${MDA_HOST}:2003 \
  -wait tcp://${RSPAMD_HOST}:11332 \
  -wait file://${SSL_CERT} \
  -wait file://${SSL_KEY} \
  -timeout ${WAITSTART_TIMEOUT} \
  /usr/sbin/postfix start-fg
