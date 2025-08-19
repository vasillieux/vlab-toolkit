
Theoretically
The workflow around bypassing sandbox is described below 
That means, all the visible points are the points to check.                               

                               +---------------------------+
                               | Attacker Gains Shell      |
                               | Inside Sandbox (VM/Container) 
                               +---------------------------+
                                           |
                                           v
                          +--------------------------------+
                          |      Initial Enumeration       |
                          |  - `uname -a` (Kernel Version) |
                          |  - `ls -la /` (Check mounts)   |
                          |  - `ip a` (Check network)      |
                          |  - `find / -name docker.sock`  |
                          +--------------------------------+
                                           |
                                           v
                 +-------------------------------------------------+
                 |        Is this a container or a VM?             |
                 |      (`systemd-detect-virt`, check /proc)       |
                 +-------------------------------------------------+
                      | (Container)                  | (VM)
                      v                              v
+------------------------------------------+   +---------------------------------------+
|  **CONTAINER ESCAPE FLOW**               |   |  **VM ESCAPE FLOW**                   |
|------------------------------------------|   |---------------------------------------|
|                                          |   |                                       |
|  [Check for Misconfigurations First]     |   |  [Check for Misconfigurations First]  |
|                                          |   |                                       |
|  1. Is `/var/run/docker.sock` mounted? --(Yes)-->[**Escape via Docker Client**]      |     1. Is a "Shared Folder" mounted? 
|  2. Is container `--privileged`?       --(Yes)-->[**Escape via Host Devices**]       |     2. Is network Bridged?           
|  3. Is `/` or `/etc` mounted?          --(Yes)-->[**Escape via Cron/SSH**]           |                                          
|                                          |   |                                       |
| (No Misconfigs Found)                    |   | (No Misconfigs Found)                 |
|                      |                   |   |                      |                |
|                      v                   |   |                      v                |
|  [Attack the Shared Kernel]              |   |  [Attack the Hypervisor]              |
|                                          |   |                                       |
|  1. Find Kernel Version (e.g., 5.4.0)    |   |  1. Enumerate Virtual Hardware        |
|  2. Search Exploit-DB for LPE CVEs       |   |     (Graphics, NIC, USB, etc.)        |
|  3. Find a match?                      --(Yes)-->[**Compile & Run Kernel Exploit**]  |   |  2. Find a known CVE for that component
|                                          |   |                                       |
+------------------------------------------+   +---------------------------------------+
                      |                                       |
                      +----------------------+----------------+
                                             |
                                             v
                             +-------------------------------+
                             |                               |
                             | **CODE EXECUTION ON HOST**    |
                             |      (ESCAPE SUCCESSFUL)      |
                             |                               |
                             +-------------------------------+