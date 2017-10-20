# vpngate-utils

vpngate client utils.

## How to use

1. First, copy servicefile to create vpn client daemon.
```
$ sudo cp ./vpngate-client.service /etc/systemd/system/vpngate-client.service
```

2. Second, run shell script with root and input your password.

```
$ sudo ./setup-client.sh -s vpngate-server.com:443 -b VPN -u user1

password : ********
retype   : ********
```
