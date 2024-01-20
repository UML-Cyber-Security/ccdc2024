# Automatic Certificate generation with Active directory

Currently on the Domain Controller

Access Group Policy management console on Domain Controller

Navigate to Forest: “Domain name” >Domains>”Domain name” >

Right click Domain name > 

create a GPO in this domain

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled.png)

Give it a name

A GPO contract icon should appear in the left hand side.

Right click > “Edit”

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%201.png)

The “Group Policy Management Editor” should pop up.

Navigate through the hierarchy & double click “Certificate Services Client - Auto Enrollment”

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%202.png)

After double clikcing update the setttings

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%203.png)

Public Key Policies > Automatic Certificate… > New > Automatic Cert…

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%204.png)

Select Computer cert in the cert wizard.

Hit Next 

You are done with this part.

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%205.png)

The certificate template should show here

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%206.png)

Close out everything 

Open a terminal & run ```gpupdate /force``` on Domain controller

On client/member computers

Run mmc 

click the program

Press ctrl+m to access the “add or remove snap-ins”

Select Certificates > Add

Computer account - option > Next

Local Computer  > finish

End Result

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%207.png)

Open a terminal & run ```gpupdate /force```

You should be able to see only the machines personal certificate, since this a worker machine.

- Note: you may have to close the mmc console and open it again if you dont see it

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%208.png)

---

-

Making the certificate trusted

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%209.png)

- Computer
    
    Right click > Duplicate template
    

Prop. of a New template

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%2010.png)

recall  you template dislday name “BlueTeam-RDPAuthentication”

Extensions > Application policies > Edit

remove  Client Authentication

Now we need to add our remote desktop application policy, which is not enabled by default.

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%2011.png)

Click Add (under Edit App.. Policies Extension)

Click New  & Create a new application policy

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%2012.png)

Object ID for Remote Desktop Authentication is 1.3.6.1.4.1.311.54.1.2

Click Ok & make add the new Application policy

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%2013.png)

Click Security tab under Properties of a new template

Select Domain Computers[BlueTeam\Domain Computers]

Computers[DomainName\Domain Computers]

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%2014.png)

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%2015.png)

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%2016.png)

Hit Ok

## Issue template to local CA to assign to computers

Go to the mcc console “certsrv”

Right click “Certificate templates” > New > Certicate template to issue

Select our new Cert template

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%2017.png)

## Configure group policy object to  deploy RDP certificate

Navigate to Domain Controller

Access Group Policy management console

Group Policy Objects > Right click “New” >Name it  “ Blue Team RDP Cert Deployment GPO

leave other settings as is

Right click on Blue Team RDP Cert Deployment GPO on the left side

BlueTeam RDP Cert Deployment GPO > Computer configurate > Policies > Administrative templates > Windows Components > Remote Desktop Services > Remote Desktop Session Host > Security

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%2018.png)

Click “Server Authentication certificate template”

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%2019.png)

We are using this name BlueTeam-RDPAuthentication exactly for our template name above

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%2020.png)

### IOT to use SSL to connect to a service we need to configure another policy setting which is a required used of the specific security layer for remote connections

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%2021.png)

Naviagate back to the Group Policy managment
Right click BlueTeam.com

This is our highest group, so all computers in this directory(AD), will be affected by any policy directly below it

You can create sub-groups and be even more selective about which computers go there.

We don’t need this in our case.

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%2022.png)

UPdate group policy manually

gpupdate /force 
& restart computer

## Confirmation

![Untitled](Automatic%20Certificate%20generation%20with%20Active%20direc%20df597ae7b6324167a60a41f471e6e0f5/Untitled%2023.png)