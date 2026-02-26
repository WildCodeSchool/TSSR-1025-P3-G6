

|   |   |
|---|---|
|From|[root@hera.ecotech.tssr](mailto:root@hera.ecotech.tssr "root@hera.ecotech.tssr")|
|To|[postmaster@ecotech.tssr](mailto:postmaster@ecotech.tssr "postmaster@ecotech.tssr")|
|Date|Mon 16:09|

[Summary](https://hera.ecotech.tssr/mail/?_task=mail&_caps=pdf%3D1%2Cflash%3D0%2Ctiff%3D0%2Cwebp%3D1%2Cpgpmime%3D0&_uid=1&_mbox=INBOX&_framed=1&_action=preview#headers) [Headers](https://hera.ecotech.tssr/mail/?_task=mail&_caps=pdf%3D1%2Cflash%3D0%2Ctiff%3D0%2Cwebp%3D1%2Cpgpmime%3D0&_uid=1&_mbox=INBOX&_framed=1&_action=preview#all-headers)

Admin of domain ecotech.tssr:  
  
    * Account: [postmaster@ecotech.tssr](mailto:postmaster@ecotech.tssr)  
    * Password: Azerty1*2025  
  
    You can login to iRedAdmin with this account, login name is full email address.  
  
First mail user:  
    * Username: [postmaster@ecotech.tssr](mailto:postmaster@ecotech.tssr)  
    * Password: Azerty1*2025  
    * SMTP/IMAP auth type: login  
    * Connection security: STARTTLS or SSL/TLS  
  
    You can login to webmail with this account, login name is full email address.  
  
* Enabled services:  rsyslog postfix mysql nginx php-fpm dovecot clamav-daemon amavis clamav-freshclam fail2ban cron nftables  
  
  
SSL cert keys (size: 4096):  
    - /etc/ssl/certs/iRedMail.crt  
    - /etc/ssl/private/iRedMail.key  
  
Mail Storage:  
    - Mailboxes: /var/vmail/vmail1  
    - Mailbox indexes:  
    - Global sieve filters: /var/vmail/sieve  
    - Backup scripts and backup copies: /var/vmail/backup  
  
MySQL:  
    * Root user: root, Password: "Azerty1*2025" (without quotes)  
    * Bind account (read-only):  
        - Username: vmail, Password: XH1n8z71uAmrTVPfXT0ZM25skOXa9r0m  
    * Vmail admin account (read-write):  
        - Username: vmailadmin, Password: swRnasr2kqxRU1HRCt0GD0pIQn4aA3It  
    * Config file: /etc/mysql/my.cnf  
    * RC script: /etc/init.d/mysql  
  
Virtual Users:  
    - /home/wilder/iRedMail-1.7.4/samples/iredmail/iredmail.mysql  
    - /home/wilder/iRedMail-1.7.4/runtime/*.sql  
  
Backup MySQL database:  
    * Script: /var/vmail/backup/backup_mysql.sh  
    * See also:  
        # crontab -l -u root  
  
Postfix:  
    * Configuration files:  
        - /etc/postfix  
        - /etc/postfix/aliases  
        - /etc/postfix/main.cf  
        - /etc/postfix/master.cf  
  
    * SQL/LDAP lookup config files:  
        - /etc/postfix/mysql  
  
Dovecot:  
    * Configuration files:  
        - /etc/dovecot/dovecot.conf  
        - /etc/dovecot/dovecot-ldap.conf (For OpenLDAP backend)  
        - /etc/dovecot/dovecot-mysql.conf (For MySQL backend)  
        - /etc/dovecot/dovecot-pgsql.conf (For PostgreSQL backend)  
        - /etc/dovecot/dovecot-used-quota.conf (For real-time quota usage)  
        - /etc/dovecot/dovecot-share-folder.conf (For IMAP sharing folder)  
    * Syslog config file:  
        - /etc/rsyslog.d/1-iredmail-dovecot.conf (present if rsyslog >= 8.x)  
    * RC script: /etc/init.d/dovecot  
    * Log files:  
        - /var/log/dovecot/dovecot.log  
        - /var/log/dovecot/sieve.log  
        - /var/log/dovecot/lmtp.log  
        - /var/log/dovecot/lda.log (present if rsyslog >= 8.x)  
        - /var/log/dovecot/imap.log (present if rsyslog >= 8.x)  
        - /var/log/dovecot/pop3.log (present if rsyslog >= 8.x)  
        - /var/log/dovecot/sieve.log (present if rsyslog >= 8.x)  
    * See also:  
        - /var/vmail/sieve/dovecot.sieve  
        - Logrotate config file: /etc/logrotate.d/dovecot  
  
Nginx:  
    * Configuration files:  
        - /etc/nginx/nginx.conf  
        - /etc/nginx/sites-available/00-default.conf  
        - /etc/nginx/sites-available/00-default-ssl.conf  
    * Directories:  
        - /etc/nginx  
        - /var/www/html  
    * See also:  
        - /var/www/html/index.html  
  
php-fpm:  
    * Configuration files: /etc/php//fpm/pool.d/[www.conf](http://www.conf)  
  
PHP:  
    * PHP config file for Nginx:  
    * Disabled functions: posix_uname,eval,pcntl_wexitstatus,posix_getpwuid,xmlrpc_entity_decode,pcntl_wifstopped,pcntl_wifexited,pcntl_wifsignaled,phpAds_XmlRpc,pcntl_strerror,ftp_exec,pcntl_wtermsig,mysql_pconnect,proc_nice,pcntl_sigtimedwait,posix_kill,pcntl_sigprocmask,fput,phpinfo,system,phpAds_remoteInfo,ftp_login,inject_code,posix_mkfifo,highlight_file,escapeshellcmd,show_source,pcntl_wifcontinued,fp,pcntl_alarm,pcntl_wait,ini_alter,posix_setpgid,parse_ini_file,ftp_raw,pcntl_waitpid,pcntl_getpriority,ftp_connect,pcntl_signal_dispatch,pcntl_wstopsig,ini_restore,ftp_put,passthru,proc_terminate,posix_setsid,pcntl_signal,pcntl_setpriority,phpAds_xmlrpcEncode,pcntl_exec,ftp_nb_fput,ftp_get,phpAds_xmlrpcDecode,pcntl_sigwaitinfo,shell_exec,pcntl_get_last_error,ftp_rawlist,pcntl_fork,posix_setuid  
  
ClamAV:  
    * Configuration files:  
        - /etc/clamav/clamd.conf  
        - /etc/clamav/freshclam.conf  
        - /etc/logrotate.d/clamav  
    * RC scripts:  
            + /etc/init.d/clamav-daemon  
            + /etc/init.d/clamav-freshclam  
  
Amavisd-new:  
    * Configuration files:  
        - /etc/amavis/conf.d/50-user  
        - /etc/postfix/master.cf  
        - /etc/postfix/main.cf  
    * RC script:  
        - /etc/init.d/amavis  
    * SQL Database:  
        - Database name: amavisd  
        - Database user: amavisd  
        - Database password: 5TqENXcUqJgs8lAAXK1Tt2qEUQMFRf3G  
  
DNS record for DKIM support:  
  
  
SpamAssassin:  
    * Configuration files and rules:  
        - /etc/mail/spamassassin  
        - /etc/mail/spamassassin/local.cf  
  
iRedAPD - Postfix Policy Server:  
    * Version: 5.9.1  
    * Listen address: 127.0.0.1, port: 7777  
    * SQL database account:  
        - Database name: iredapd  
        - Username: iredapd  
        - Password: g0Zm3z7inLMNsba8oRrpq0h8155ro91W  
    * Configuration file:  
        - /opt/iredapd/settings.py  
    * Related files:  
        - /opt/iRedAPD-5.9.1  
        - /opt/iredapd (symbol link to /opt/iRedAPD-5.9.1  
  
iRedAdmin - official web-based admin panel:  
    * Version: 2.6  
    * Root directory: /opt/www/iRedAdmin-2.6  
    * Config file: /opt/www/iRedAdmin-2.6/settings.py  
    * Web access:  
        - URL: [https://hera.ecotech.tssr/iredadmin/](https://hera.ecotech.tssr/iredadmin/)  
        - Username: [postmaster@ecotech.tssr](mailto:postmaster@ecotech.tssr)  
        - Password: Azerty1*2025  
    * SQL database:  
        - Database name: iredadmin  
        - Username: iredadmin  
        - Password: PNwwbbgLs42B7dQZnTYP4JGf3TzRgNOs  
  
Roundcube webmail: /opt/www/roundcubemail-1.6.11  
    * Config file: /opt/www/roundcubemail-1.6.11/config  
    * Web access:  
        - URL: [http://hera.ecotech.tssr/mail/](http://hera.ecotech.tssr/mail/) (will be redirected to https:// site)  
        - URL: [https://hera.ecotech.tssr/mail/](https://hera.ecotech.tssr/mail/) (secure connection)  
        - Username: [postmaster@ecotech.tssr](mailto:postmaster@ecotech.tssr)  
        - Password: Azerty1*2025  
    * SQL database account:  
        - Database name: roundcubemail  
        - Username: roundcube  
        - Password: GRhTivPIrOXzxmhCySqgn0giEL4qkKXz  
    * Cron job:  
        - Command: "crontab -l -u root"  
  
netdata (monitor):  
    - Config files:  
        - All config files: /opt/netdata/etc/netdata  
        - Main config file: /opt/netdata/etc/netdata/netdata.conf  
        - Modified modular config files:  
            - /opt/netdata/etc/netdata/go.d  
    - HTTP auth file (if you need a new account to access netdata, please  
      update this file with command like 'htpasswd' or edit manually):  
        - /etc/nginx/netdata.users  
    - Log directory: /opt/netdata/var/log/netdata  
    - SQL:  
        - Username: netdata  
        - Password: 0FdRgWernDcVOhBcfIANTY94wN7YDlss  
        - NOTE: No database required by netdata.