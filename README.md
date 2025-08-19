## vlab

- yo want to just get stuff done with no obselete dependencies 
when running your new qemu/docker/server lab?
- wanna to get specific package but don't want to setup it few hours just to test something?
- you not sure that your lab-system is safe?

go ahead. \

```
 /\_/\
( o o )
==_Y_==
  `-'
```

## Demo
Check the demo! This is fresh-setuped Ubuntu 25.04 via [lima](https://github.com/lima-vm/lima). 
Vlab's helping to perform all quick checks and setup neccessary software, even with hard compilation process
<p align="center">
    <img width="800" height="450" alt="demo" src="https://github.com/user-attachments/assets/7d3fdebb-805a-4460-b53a-7cc802103bcb" />
</p>

## Screenshots
<p>
    <img width="500" height="230" alt="1" src="https://github.com/user-attachments/assets/b8bd8d51-8feb-4cf9-8176-ed36b02574b1" />
</p>


## features

-   **cross-distro support:** works on ubuntu, arch, and <del>nixos</del> using the native package manager.
-   **modular design:** logic is separated into a controller, installer modules, and os-specific definitions.
-   **targeted installation:** install only the toolsets you need (recon, wifi, general, evm, docker).
-   **sandbox verification:** analyzes the running environment to detect potential isolation weaknesses and provides hardening advice.
-   **.sh only** no other deps.

## prerequisites

-   a supported os: ubuntu (debian-based), arch linux, or nixos.
-   root or `sudo` privileges. (for now..)
-   an active internet connection.

## usage

install in one-line command 
```sh
curl -fsSL https://raw.githubusercontent.com/vasillieux/vlab-toolkit/main/bootstrap.sh | sudo bash
```

after you can use the same command to call `vlab.sh` or 
call it directly \
```sudo /usr/share/vlab/core/vlab.sh```

## addons 

You can install additional modules via vlab's menu \
The recommended (yet empty) repo is:

`https://github.com/vasillieux/vlab-modules-community`

## todo 

- snapshots 
- more default and non-default stuff, kinda weirdo labs. suggest this requires catalogue..
- linking, prebuilt docker images for weird project 
- setup vpn, rdp, and stuff.
- simpler clone&usage, better oneliner 

## disclaimer

this toolkit installs security software. use it responsibly and only on systems you are authorized to test. the authors are not responsible for any misuse.
