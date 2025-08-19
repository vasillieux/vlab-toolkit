## vlab

- you just want to get stuff done with no obselete dependencies 
when running your new qemu/docker/server lab?
- wanna get specific package but don't want to setup it few hours just to test something?
- you are not sure if your lab-system is safe?

go ahead. \

```
 /\_/\
( o o )
==_Y_==
  `-'
```

<img width="500" height="200" alt="image" src="https://github.com/user-attachments/assets/e5b76c47-aefb-4921-b825-dcfa90d28c4b" />


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

1.  **clone the repository:**
    ```sh
    git clone <repository_url>
    cd vlab-toolkit
    ```

2.  **make the main script executable:**
    ```sh
    chmod +x vlab.sh
    ```

3.  **run the toolkit with sudo:**
    ```sh
    sudo ./vlab.sh
    ```

4.  **select an option from the menu:**
    ```
    vlab toolkit // os: ubuntu
    --- install & setup ---

    >
    1) recon tools          6) --- diagnostics ---
    2) wifi tools           7) check installed
    3. general tools        8) verify sandbox
    4. evm tools            9) --- exit ---
    5) docker engine        10) quit
    ```

## todo 

- snapshots 
- more default and non-default stuff, kinda weirdo labs. suggest this requires catalogue..
- linking, prebuilt docker images for weird project 
- setup vpn, rdp, and stuff.
- simpler clone&usage, better oneliner 

## disclaimer

this toolkit installs security software. use it responsibly and only on systems you are authorized to test. the authors are not responsible for any misuse.
