#F5Tools

## fixLocalUsers.pl
A PERL script that re-adds localusers on F5.  Supports version 9.x-12.x
### Directions:
  * Copy file to F5 in `/root/cron`.  Make the directory if it's not there already with `mkdir /root/cron/`
  * `chmod 744` so it can be executed
  * Add it to `crontab -e`.
### Example:
```
[root@lbal1:Active:In Sync] cron # ll
total 5
-rwxr--r-- 1 root root 3427 Jun 10 13:22 fixLocalUsers.pl
[root@lbal1:Active:In Sync] cron # pwd
/root/cron
[root@lbal1:Active:In Sync] cron # crontab -e
!-- Add this line at the bottom:
*/15 * * * * /root/cron/fixLocalUsers.pl
[/code]
```
### Running it manually
```
[root@lbal1:Standby:In Sync] cron # ./fixLocalUsers.pl debug
DEBUG::Determining device version
DEBUG::Device Version is 11.5.4.1.0.286
DEBUG::Checking /config/bigip/auth/localusers for the defined local users
DEBUG::User [dpham] is not defined in localusers file
DEBUG::Adding dpham to the localusers file
```
