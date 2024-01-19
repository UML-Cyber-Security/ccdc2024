# Teleport  <!-- omit from toc -->
This is a document detailing the installation, setup and use of **Teleport**. This will Primarily focus on the use of a host-based install. Not a Container based install. We can look into the use of Teleport with containers, however this will involve the [Amazon Elastic Container Registry](https://aws.amazon.com/ecr/).

## Table of Contents <!-- omit from toc -->
- [Host Based](#host-based)
  - [System Install](#system-install)
  - [Server Access](#server-access)
    - [Disable MFA](#disable-mfa)
  - [Linux Trusted Cert Store](#linux-trusted-cert-store)
  - [Adding Nodes CLI Method -- Not Recommended](#adding-nodes-cli-method----not-recommended)
  - [Adding Nodes Web Interface (Linux)](#adding-nodes-web-interface-linux)
- [Add Teleport Certificate to Windows](#add-teleport-certificate-to-windows)
  - [Add Windows RDP  Console](#add-windows-rdp--console)
  - [Add Windows RDP Web](#add-windows-rdp-web)
- [Disable Session Recordings](#disable-session-recordings)
- [User Management](#user-management)

## Host Based 
Please follow the instructions located at the official <a href="https://goteleport.com/docs/installation/">Teleport documentation</a>. This will give a more detailed explication of the commands provided below (Except for Docker, they dont tell us much there).

We have the option of installing Teleport on the System, or as a Container.

**Notice**: The Host should have > 1 CPU and 4 - 6 GB of memory to function properly.
### System Install
This is taken from the <a href="https://goteleport.com/docs/installation/">Teleport documentation</a>.

Run the following commands (On Debian based systems)
```sh
# Add the GPG Key 
sudo curl https://apt.releases.teleport.dev/gpg \
-o /usr/share/keyrings/teleport-archive-keyring.asc

# Add environment variables from os-release
source /etc/os-release

# Add teleport repository, this needs to be updated for each major release
echo "deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.asc] \
https://apt.releases.teleport.dev/${ID?} ${VERSION_CODENAME?} stable/v13" \
| sudo tee /etc/apt/sources.list.d/teleport.list > /dev/null

# Update package list and install
sudo apt-get update
sudo apt-get install teleport
```

An alternative method we can use is described at [Getting Started](https://goteleport.com/docs/get-started/).
```sh
# Download and run the script
curl https://goteleport.com/static/install.sh | bash -s 13.1.1
```
### Server Access 
This is taken from the guides listed at <a href="https://goteleport.com/docs/server-access/introduction/">Server Teleport Access Guides</a>

First follow the instructions at [Getting Started](https://goteleport.com/docs/get-started/).

1. Configure DNS, (If we can, since this is internal we will be port forwarding... so make sure the certificate matches the outer-router IP)
    * If this were an outward facing system, we would use lets-encrypt or some other CA service
2. Install (Should already be done)
3. Use the Private network method. 
    * [Generate a certificate](https://goteleport.com/docs/management/admin/self-signed-certs/) (We can use self signed) For this we will use *openssl* to generate a self signed certificate and key pair. **If you would like to make te certificate trusted see [Linux Trusted Cert](#linux-trusted-cert-store)**
        ```
            # make a directory to store this info (Configure permissions correctly)
            sudo mkdir -p /var/lib/teleport-info

            sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /var/lib/teleport-info/privkey.pem -out /var/lib/teleport-info/fullchain.pem 
        ```
        * The *sudo* is needed as the teleport private key file is protected, now that we are using our own directory, we will not need it. But I have kept it, to prevent future issues.
        * Fill out the information as desired the **ONLY** field that matters is the common name  which should be the URL that resolves to the ip hosting teleport, or the IP address directly. An **example** is shown below. As we are using HAProxy to provide SSL to the client, the IP or DNS name used should be the **INTERNAL ONE**.

            <img src="Images/TLS-Gen.png" width=800>

    * Place a valid private key in ```/var/lib/teleport-info/privkey.pem``` (Done by openssl command)
    * Place a valid certificate chain ```/var/lib/teleport-info/fullchain.pem``` (Done by openssl command)
4. Configure the Teleport Server, replace \<IP\> with the machine's IP!
    ``` sh
    sudo teleport configure -o file \
    --cluster-name=Practice_Infra \
    --public-addr=<IP>:443 \
    --cert-file=/var/lib/teleport-info/fullchain.pem \
    --key-file=/var/lib/teleport-info/privkey.pem
    ```
    * Replace the IP there, with your IP or a Domain name that will resolve.
    * May need to remove an existing file 
        ```
        rm -f /etc/teleport.yaml
        ```
5. Start Teleport
    * Command Provided 
        ```
        sudo teleport start --config="/etc/teleport.yaml"
        # Then Enable 
        sudo systemctl enable teleport
        ```
    * Enable and Start Teleport
        ```
        sudo systemctl enable teleport && \
        sudo systemctl start teleport
        ```
6. Run ```sudo tctl status``` we should see output like the following 
    <img src="Images/tctl-status1.png" width=800>
7. Create an administrator, use the following command. If we do not want MFA **Refer to** [Disable MFA](#disable-mfa) before going further.
    ```
    # Create a privileged user teleport-admin
    # --logins provides a list of allowed logins from this account
    sudo tctl users add teleport-admin --roles=editor,access --logins=root,ubuntu,ec2-user,student
    ```
8.  Use the URL outputted by the command to finalize the creation of the account. And example is shown below.

    <img src="Images/user-add.png" width=800>

9.  Click Get Started

    <img src="Images/get-started.png" width=800>

10. Create a password

    <img src="Images/get-started2.png" width=800>

11. Setup 2FA as shown below, Use google authenticator or some other 2FA app. **Refer to** [Disable MFA](#disable-mfa) if we do not want this.

    <img src="Images/get-started3.png" width=800>

12. Goto the dashboard 

    <img src="Images/get-started4.png" width=800>

13. We should see the Sever as listed below 

    <img src="Images/get-started5.png" width=800>

#### Disable MFA
The following is based on the official [teleport documentation](https://goteleport.com/docs/reference/authentication/)

1. Open ```/etc/teleport.yaml``` in a text editor. You should see something like the following 

    <img src="Images/MFA1.png" width=500>

2. Look for the auth service section 
    ```
    auth_service:
    enabled: "yes"
    listen_addr: 0.0.0.0:3025
    cluster_name: Practice_Infra
    proxy_listener_mode: multiplex
    ```
3. Modify the above section so it looks like the following 
    ```
    auth_service:
    enabled: "yes"
    listen_addr: 0.0.0.0:3025
    cluster_name: Practice_Infra
    proxy_listener_mode: multiplex
    authentication:
        type: local
        second_factor: off
    ```

### Linux Trusted Cert Store
1. Generate the Certificate with a SAN
    ```
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /var/lib/teleport-info/privkey.pem  -addext "subjectAltName = DNS:<DNS_URL>, IP:<IP>" -out /var/lib/teleport-info/fullchain.pem 
    ```
2. Copy certificate over that is used by the teleport server. This can be through the use of ```scp``` or something
    * You can copy it directly to the necessary location
      * Debian
            ```
            scp <user>@<IP>:/var/lib/teleport-info/fullchain.pem /usr/local/share/ca-certificates/teleport-server.crt
            ```
      * RHEL
            ```
            scp <user>@<IP>:/var/lib/teleport-info/fullchain.pem /etc/pki/ca-trust/source/anchors/teleport-server.crt
            ```
            * This may also be ```/etc/pki/ca-trust/source/whitelist/```
3. Move the certificate to the ```/usr/local/share/ca-certificates/``` directory if you are using a debian system. Otherwise for RHEL systems we would copy it to ```/etc/pki/ca-trust/source/whitelist/``` or ```/etc/pki/ca-trust/source/anchors/```. An example for Debain systems is shown below. This should be the root certificate.
    ```
    mv servercert.crt /usr/local/share/ca-certificates/servercert.crt
    ```
    * Ensure the file ends in .crt! 
        ![CA-Update](Images/LTS.png)
4. Run the following command to update the trusted certificate store
    * Debian Systems
        ```
        sudo update-ca-certificates
        ```
   * RHEL Systems 
        ```
        sudo update-ca-trust
        ```
   * You may want to test that it was loaded properly, by curling the Teleport server 
        ```
        curl https://<IP>
        ```
5. Originally I had a validation error. This was possibly due to the lack of a SAN, or that I forgot to run the ```update-ca-certificates``` command. After setting up teleport with the ```--insecure``` flag I transitioned to this trusted method, and it worked. 
6. If you are running Teleport with the ```--insecure``` flag, you can now remove it
   1. Remove the  ```--insecure``` flag
        ```
        vim /lib/systemd/system/teleport.service 
        ```
   2. Reload the daemon
        ```
        systemctl daemon-reload
        ```
   3. Restart Teleport
        ```
        systemctl restart teleport
        ```

The Linux system has a [Trusted Certificate Store](https://ubuntu.com/server/docs/security-trust-store). The ```update-ca-certificates``` command updates the ```/etc/ssl/certs/ca-certificates.crt``` file which is a list of all trusted root certificates. It reads in the new certificates from ```/usr/local/share/ca-certificates/*```. In RHEL systems a similar thing is done to update root [certificates](https://www.redhat.com/sysadmin/configure-ca-trust-list). 
### Adding Nodes CLI Method -- Not Recommended
1. Enter into **Teleport Server**
2. Install Teleport (**This should already be done if the previous steps have been done**)
    ```
    # Download run script
    curl https://goteleport.com/static/install.sh | bash -s 13.1.1
    ```
3. Add a server to our cluster, to do this we will use the ```tctl``` command, short for teleport-control.
    ```
    # Generate a join token, and save it to a file (with redirection!)
    tctl tokens add --type=node --format=text > token.file
    ```
4. Transfer the generated *token.file* to the target machine 
5. Install Teleport on the **TARGET MACHINE**
    ```
    # Download run script
    curl https://goteleport.com/static/install.sh | bash -s 13.1.1
6. Generate a configuration file on the target machine using the *token file*
    ```
    sudo teleport node configure \
   --output=file:///etc/teleport.yaml \
   --token=/path/to/token.file \
   --proxy=tele.example.com:443
    ```
    * **Replace** /path/to/token.file with the path
    * **Replace** tele.example.com with the IP or DNS
7. Start and enable teleport
    ```
    sudo systemctl enable teleport && \
    sudo systemctl start teleport
    ```
### Adding Nodes Web Interface (Linux)

1. Login to the Teleport web-interface 
2. Click Add Server as shown below

    <img src="Images/node-web1.png" width=800>

3. Click on the Distribution you would like to add 

    <img src="Images/node-web2.png" width=800>

4. Follow the provided instructions (run the command on the host we want to add)

    <img src="Images/node-web3.png" width=800>
    
    * Add a ```--insecure``` flag to curl if using self signed certs with teleport.  
    * May need to modify the URL to match the INTERNAL IP and to use port 443
5. See the section 
6. Modify the ```/lib/systemd/system/teleport.service```, look at the output of ```systemctl status teleport``` if this is not the location to find it. It should look like the following. **See** [The Alt Section](#look-into-alternate-way-to-make-it-trusted) if using an actual CA.
    ```
    [Unit]
    Description=Teleport Service
    After=network.target

    [Service]
    Type=simple
    Restart=on-failure
    EnvironmentFile=-/etc/default/teleport
    ExecStart=/usr/local/bin/teleport start --pid-file=/run/teleport.pid --insecure
    ExecReload=/bin/kill -HUP $MAINPID
    PIDFile=/run/teleport.pid
    LimitNOFILE=524288

    [Install]
    WantedBy=multi-user.target`
    ```
    * The line ```ExecStart=/usr/local/bin/teleport start --pid-file=/run/teleport.pid``` needs ```--insecure``` added 
7. Restart the process
    ```
    sudo systemctl daemon-reload && \
    sudo systemctl restart teleport.service
    ```
8. If using tsh, we will need to use the ```--insecure``` flag
9. We should see the following on a success

    <img src="Images/node-web4.png" width=800>

10. Configure the users that can be accessed. An example is shown below.

    <img src="Images/node-web5.png" width=800>

11. Test the connection

    <img src="Images/node-web6.png" width=800>


## Add Teleport Certificate to Windows
https://learn.microsoft.com/en-us/skype-sdk/sdn/articles/installing-the-trusted-root-certificate
### Add Windows RDP  Console 
https://goteleport.com/docs/desktop-access/active-directory-manual/#allow-remote-rdp-connections -- Manual
https://goteleport.com/docs/desktop-access/getting-started/ -- Non-Manual


1. Open Powershell
2. Run the commands
    ```
    $Name="Teleport Service Account"
    $SamAccountName="svc-teleport"

    # Generate a random password that meets the "Password must meet complexity
    # requirements" security policy setting.
    # Note: if the minimum complexity requirements have been changed from the
    # Windows default, this part of the script may need to be modified.
    Add-Type -AssemblyName 'System.Web'
    do {
    $Password=[System.Web.Security.Membership]::GeneratePassword(15,1)
    } until ($Password -match '\d')
    $SecureStringPassword=ConvertTo-SecureString $Password -AsPlainText -Force

    New-ADUser `
    -Name $Name `
    -SamAccountName $SamAccountName `
    -AccountPassword $SecureStringPassword `
    -Enabled $true
    ```
3. In the **SAME POWERSHELL WINDOW**, run the following 
    ```
    # Save your domain's distinguished name to a variable.
    $DomainDN=$((Get-ADDomain).DistinguishedName)

    # Create the CDP/Teleport container.
    # If the command fails with "New-ADObject : An attempt was made to add an object
    # to the directory with a name that is already in use", it means the object
    # already exists and you can move on to the next step.
    New-ADObject -Name "Teleport" -Type "container" -Path "CN=CDP,CN=Public Key Services,CN=Services,CN=Configuration,$DomainDN"

    # Gives Teleport the ability to create LDAP containers in the CDP container.
    dsacls "CN=CDP,CN=Public Key Services,CN=Services,CN=Configuration,$DomainDN" /I:T /G "$($SamAccountName):CC;container;"
    # Gives Teleport the ability to create and delete cRLDistributionPoint objects in the CDP/Teleport container.
    dsacls "CN=Teleport,CN=CDP,CN=Public Key Services,CN=Services,CN=Configuration,$DomainDN" /I:T /G "$($SamAccountName):CCDC;cRLDistributionPoint;"
    # Gives Teleport the ability to write the certificateRevocationList property in the CDP/Teleport container.
    dsacls "CN=Teleport,CN=CDP,CN=Public Key Services,CN=Services,CN=Configuration,$DomainDN " /I:T /G "$($SamAccountName):WP;certificateRevocationList;"
    # Gives Teleport the ability to create and delete certificationAuthority objects in the NTAuthCertificates container.
    dsacls "CN=NTAuthCertificates,CN=Public Key Services,CN=Services,CN=Configuration,$DomainDN" /I:T /G "$($SamAccountName):CCDC;certificationAuthority;"
    # Gives Teleport the ability to write the cACertificate property in the NTAuthCertificates container.
    dsacls "CN=NTAuthCertificates,CN=Public Key Services,CN=Services,CN=Configuration,$DomainDN" /I:T /G "$($SamAccountName):WP;cACertificate;"
    ```
4. Run the following command ```Get-AdUser -Identity $SamAccountName | Select SID```. Save this information for later. Below is some example output. 

    <img src="Images/W1.png" width=800>

5. Run the following command 
    ```
    $GPOName="Block teleport-svc Interactive Login"
    ```
6. Run the following command 
    ```
    New-GPO -Name $GPOName | New-GPLink -Target $((Get-ADDomain).DistinguishedName)
    ```
7. Open the Group Policy Management program

    <img src="Images/W2.png" width=800>

8. Navigate to the GPO created something like: ```($FOREST > Domains > $DOMAIN > Group Policy Objects > Block teleport-svc Interactive Login)```

    <img src="Images/W3.png" width=800>

9. Edit it. Right click it.

    <img src="Images/W4.png" width=800>

10. Edit ```Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > User Rights Assignment```

    <img src="Images/W5.png" width=800>

11. Double click Deny log on locally and in the popup, check Define these policy settings.

    <img src="Images/W6.png" width=800>

12. use the SAM (SID from earlier), check the name and agree to everything.

    <img src="Images/W7.png" width=800>
    * I may be wrong so I also added the sam account name

        <img src="Images/W8.png" width=800>

13. Repeat fpr ```Deny log on through Remote Desktop Services```. It is in the same menu.

    <img src="Images/W9.png" width=800>

14. Download the Windows Certificate 
    * Trusted
        ```curl -o user-ca.cer https://10.0.1.15:443/webapi/auth/export?type=windows```
    * Untrusted
      * I just accessed it on a wen browser and saved it.
      1. Set powershell to ignore invalid certificates        
        ```
        add-type @"
            using System.Net;
            using System.Security.Cryptography.X509Certificates;
            public class TrustAllCertsPolicy : ICertificatePolicy {
                public bool CheckValidationResult(
                    ServicePoint srvPoint, X509Certificate certificate,
                    WebRequest request, int certificateProblem) {
                    return true;
                }
            }
        "@
        ```
      2.  Then run 
        ```
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
        ```
      3. Run Curl command (Replace IP with your IP)
        ```
        curl -o user-ca.cer https://<IP>:443/webapi/auth/export?type=windows
        ```
15. Run the following commands to create an access policy for teleport
    ```
    $GPOName="Teleport Access Policy"
     New-GPO -Name $GPOName | New-GPLink -Target $((Get-ADDomain).DistinguishedName)
    ```
16. As previously open the Group Policy Management program and navigate to the policy 
    ```
    $FOREST > Domains > $DOMAIN > Group Policy Objects
    ```

    <img src="Images/W10.png" width=800>

17. Edit the policy (right click) goto **Trusted Root Certificate Authorities**
    ```
    Computer Configuration > Policies > Windows Settings > Security Settings > Public Key Policies
    ```

    <img src="Images/W11.png" width=800>

18. Access the **Trusted Root Certificate Authorities** and import the Teleport Certificate.
    * You will need to right click the empty window and follow the wizard

    <img src="Images/W12.png" width=800>

19. As a Domain administrator, publish the certificate to the domain.
    * Verify with the following command - look for Domain Admin
        ```
        net user administrator /domain 
        ```

        <img src="Images/W13.png" width=300>
    
    * Then run the following command
    ```
    certutil –dspublish –f <PathToCertFile.cer> RootCA
    ```

    <img src="Images/W14.png" width=300>

20. Publish the cert to the NTAuth server, this will be done automatically hereafter 
    ```
    certutil –dspublish –f <PathToCertFile.cer> NTAuthCA
    ```

    <img src="Images/W15.png" width=300>

21. Force the retrevial of the certificate 
    ```
    certutil -pulse
    ```
22. Teleport emulates a Smart Card. We need to enable Smart Card based authentication 
    * Still editing the Teleport Group Access Policy 
        ```
        Computer Configuration > Policies > Windows Settings > Security Settings > System Services
        ```
        <img src="Images/W16.png" width=800>
    * Click The System Services 

23. Find the **Smart Card** entry and fill it out as shown below

    <img src="Images/W17.png" width=800>

24. Enable RDP connection (Already in one so I assume something has been done...)
25. Navigate to connections still in the Group Policy Manager for Teleport Access
    ```
    Computer Configuration > Policies > Administrative Templates > Windows Components > Remote Desktop Services > Remote Desktop Session Host > Connections
    ```
26. Right Click the policy and select edit

    <img src="Images/W18.png" width=800>

27. Enable Remote RDP connections as shown below

    <img src="Images/W19.png" width=800>

28. Goto the Security section for RDP
    ```
    Computer Configuration > Policies > Administrative Templates > Windows Components > Remote Desktop Services > Remote Desktop Session Host > Security
    ```
29. Right click the "Require user authentication for..." as shown below

    <img src="Images/W20.png" width=800>

30. Edit this configuration so it is disabled as shown below

    <img src="Images/W21.png" width=800>

31. Right click "Always prompt..." as shown below 

    <img src="Images/W22.png" width=800>

32. Disable it as shown below

    <img src="Images/W23.png" width=800>

33. Navigate to Firewall Settings 
    ```
    Computer Configuration > Policies > Windows Settings > Security Settings > Windows Firewall with Advanced Security (x2)
    ```

    <img src="Images/W24.png" width=800>

34. Configure 
    1.  Right click the empty window of inbound rules 

        <img src="Images/W25.png" width=800>

    2.  Select RDP which is under predefined 

        <img src="Images/W26.png" width=800>

    3.  Only select the rule for User Mode (TCP-in) -- Uncheck the others 

        <img src="Images/W27.png" width=800>

    4.  Select Allow
35. Force update the GPO
    ```
    gpupdate.exe /force
    ```
36. Open the Microsoft Management Console (MMC) and Navigate to the following location
    ```
    Start > Control Panel > Administrative Tools > Certificate Authority
    ```

**Stopped at CA Steps**

try automatic one later.
### Add Windows RDP Web
[Reference!](https://goteleport.com/docs/desktop-access/active-directory/#compare-desktop-access-to-other-rdp-clients)

https://goteleport.com/docs/desktop-access/getting-started/ -- Non-Manual

1. Login to the Teleport web-interface 
2. Click Add Server as shown below

    <img src="Images/node-web1.png" width=800>

3. Remove the filter and select Active Directory as shown below
    <img src="Images/node-web-win1.png" width=800>


## Disable Session Recordings
We may want to dissable session recordings to preserve our limited disk space. This information is from the [Official Teleport Docs](https://goteleport.com/docs/desktop-access/reference/sessions/)

1. Open the ```teleport.yml``` configuration file
    ```
    nano /etc/teleport.yml
    ```

## User Management 
This is primarily going to be done through the CLI, and I assume often.
1. Open a terminal on the teleport machine
2. Run ```tctl users ls``` to list all the users 
3. Delete any non-critical or required users using ```tctl users rm <name>```
4. Add trusted users using ```tctl users add <name> <options>```
    * Account name
    * [--roles=](https://goteleport.com/docs/access-controls/reference/)
      * editor: Allows editing of cluster configuration settings.
      * auditor: Allows reading cluster events, audit logs, and playing back session records.
      * access: Allows access to cluster resources.
      * requestor: Enterprise
      * reviewer: Enterprise
   * --logins=
     * A comma separated list of usernames we can use to login to the system
   * --windows-logins=
     * List of allowed Windows logins for the new user
     * May be notable-- may not be!