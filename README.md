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

<img width="500" height="230" alt="image" src="https://github.com/user-attachments/assets/b8bd8d51-8feb-4cf9-8176-ed36b02574b1" />
<img width="500" height="230" alt="image" src="https://github.com/user-attachments/assets/54ceaefc-6eba-4998-8e33-0344150bdb48" />



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
```curl -fsSL https://raw.githubusercontent.com/vasillieux/vlab-toolkit/main/bootstrap.sh | sudo bash```

after you can use the same command to call `vlab.sh` or 
call it directly
```sudo /usr/share/vlab/core/vlab.sh```

## todo 

- snapshots 
- more default and non-default stuff, kinda weirdo labs. suggest this requires catalogue..
- linking, prebuilt docker images for weird project 
- setup vpn, rdp, and stuff.
- simpler clone&usage, better oneliner 

## disclaimer

this toolkit installs security software. use it responsibly and only on systems you are authorized to test. the authors are not responsible for any misuse.
