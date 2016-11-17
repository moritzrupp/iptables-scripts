# iptables Scripts

iptables Scripts provides a set of scripts of easily managaing and configuring
your iptables and ip6tables based firewalls on your unix-based setup.

## Original work
The scripts are originally provided by [Ray-works.de]. So kudos to him. Because
I am using those scripts a lot and made some modifications to them, I decided to
put them under MIT license and publish them on GitHub. This way, people can
easier find and use them.

## Download
Just download and extract the latest release of the scripts to your server:
```
$ wget https://github.com/moritzrupp/iptables-scripts/releases/latest
$ tar -zxvf iptables-scripts-{version}.tar.gz
```

I recommend to copy the two scripts to `/usr/local/bin` so that they are
available in the path.
```
$ cp iptables-scripts/* /usr/local/bin
```

## Configuration
Now you are ready to configure your firewall easily. Just edit the files using
your preferred text editor. I'm preferring `vi`, but you can use whichever
editor you want:
```
$ vi /usr/local/bin/ipv4settings

$ vi /usr/local/bin/ipv6settings
```

### ipv4settings
Starting from line `42` you can configure the script.

| Parameter   | Values       | Default | Description |
|-------------|--------------|---------|-------------|
| NFS Storage | `yes` / `no` | `no`    | Allow `tcp` and `udp` traffic between the server and NFS storage |
| VPN Forward | `yes` / `no` | `no`    | If you've configured a `VPN` server and want to forward all traffic to the `VPN`, you have to set this to `yes` and configure the `VPN` subnet |
| Fail2Ban    | `yes` / `no` | `no`    | If you use fail2ban, setting this to `yes` will start fail2ban, so that fail2ban rules are re-added |
| Docker      | `yes` / `no` | `no`    | If you have docker installed, you should set this to `yes`. Docker is restarted and traffic outgoing traffic from the server to the docker bridge is allowed. Keep in mind configuring the correct docker subnet |

From line `67` to line `75` you have to configure the ports you want to open.
For example, if you want to open port 22 for ssh, and you want to run a
webserver with http and https:

```
# TCP & UDP Ports for incoming traffic
INTCPPORTS="ssh http https"
INUDPPORTS=""

# TCP & UDP Ports for outgoing traffic
OUTTCPPORTS="ssh http https"
OUTUDPPORTS=""

# SSH Port for extra protection via limits
SSHPORT="22"
```

It is important that you specify the `in tcp ports` and the `out tcp ports`, as
we have set the `OUTPUT` policy to `DROP`.

### ipv6settings
For the `ipv6settings` script, you can only configure your ports starting from
line `33`. It's playing by the same rules as `ipv4settings`.

## Usage
After the configuration of the scripts, it's time to enable your firewall and
proctecting your system.
```
$ ipv4settings starting
Firewall (iptables): enabled.
```

And if you want to allow all access again:
```
$ ipv4settings stop
Firewall (iptables): disabled. (allowing all access)
```

## Remarks
Using this script, your `iptables` configuration is not peristent. After a
reboot, you have to `start` `ipv4settings` and/or `ipv6settings` again. For
Debian, the package [iptables-persistent] can help you.

## Issues
If you have a question, problem or you found a bug, please don't hesitate to
create a [new issue] and get in touch with me.

## Contribution
If you find these scripts useful and you have a use case which is not dealt
with, feel free to contribute to the work. Read more about [contributing].

## License
This work is licensed under the [MIT license].

[Ray-works.de]: https://ray-works.de/
[iptables-persistent]: https://packages.debian.org/search?keywords=iptables-persistent
[MIT license]: https://github.com/moritzrupp/iptables-scripts/blob/master/LICENSE
[new issue]: https://github.com/moritzrupp/iptables-scripts/issues/new
[contributing]: https://github.com/moritzrupp/iptables-scripts/blob/master/CONTRIBUTING.md
