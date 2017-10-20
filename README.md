# vpngate-utils

vpngate client utils.

## How to use

1. First, copy servicefile to create vpn client daemon.

```
$ sudo cp ./vpngate-client.service /etc/systemd/system/vpngate-client.service
$ sudo systemctl daemon-reload
```

2. Second, start vpn client daemon.

```
$ sudo systemctl start vpngate-client.service
```

3. Finally, run shell script with root and input your password.

```
$ sudo ./setup-client.sh -s vpngate-server.com:443 -b VPN -u user1

password : ********
retype   : ********
```
