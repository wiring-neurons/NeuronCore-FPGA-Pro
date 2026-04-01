# NeuronCore FPGA Complete Tool Chain Installation for Linux

### ToolChain in Windows using Linux VM (NEW)

<details>
<summary> Install on Linux New Version CLICK HERE </summary>
<br>

### Step 1:

#### Install Microsoft C++ redistributable

#### CLICK on the link below to start downloading

https://aka.ms/vs/17/release/vc_redist.x64.exe

#### After downloading click on the file and then approve the terms and conditions and authenticate everything it asks

#### Then Please wait for sometime for it Install

#### Then Please Restart you computer

### Step 2:

#### Install Oracle Virtual Box Version 7.1.2

#### CLICK below to start downloading

https://download.virtualbox.org/virtualbox/7.1.2/VirtualBox-7.1.2-164945-Win.exe

#### After downloading click on the file and then approve the terms and conditions and authenticate everything it asks

### Step 3:
#### Make sure you have at least 50 GB space in your machine to install, then click on the below link to start installing the vdi file
Click Below to Download
https://drive.google.com/file/d/1iLUvSEuiu7TVTzyMzi-fywi6FH5MkkZt/view

Alternate Link
https://drive.usercontent.google.com/download?id=1iLUvSEuiu7TVTzyMzi-fywi6FH5MkkZt&export=download&authuser=0

#### After the file is downloaded locate the file by searching NeuronCore.zip, and then right click on it then extract and select appropriate folder which has alteast 50 GB space

<img width="290" height="269" alt="1n" src="https://github.com/wiring-neurons/images/blob/main/1n.png" />

#### After the file is extracted Open Oracle VirtualBox and click on New

<img width="293" height="215" alt="o1" src="https://github.com/wiring-neurons/images/blob/main/o1.png" />

#### Enter the Name as NeuronCore in the text box

<img width="462" height="245" alt="o2" src="https://github.com/wiring-neurons/images/blob/main/o2.png" />

#### Then make sure which drive in your computer has atleast 50 GB of storage and make sure to select that drive


</details>

### ---------------------------------------------------------------

### ToolChain in Windows using Linux VM (OLD) Not recommended

<details>
<summary> Install on Windows using VirtualBox CLICK HERE </summary>
<br>
 
### Step 1:

#### Install Microsoft C++ redistributable

#### CLICK on the link below to start downloading

https://aka.ms/vs/17/release/vc_redist.x64.exe

#### After downloading click on the file and then approve the terms and conditions and authenticate everything it asks

#### Then Please wait for sometime for it Install

#### Then Please Restart you computer

### Step 2:

#### Install Oracle Virtual Box Version 7.1.2

#### CLICK below to start downloading

https://download.virtualbox.org/virtualbox/7.1.2/VirtualBox-7.1.2-164945-Win.exe

#### After downloading click on the file and then approve the terms and conditions and authenticate everything it asks

### Step 3:
#### Make sure you have at least 50 GB space in your machine to install, then click on the below link to start installing the VM

https://vsd-labs.sgp1.cdn.digitaloceanspaces.com/vsd-labs/vsdsquadron_fpga_mini.zip

#### After the file is downloaded locate the file by searching vsdsquadron_fpga_mini.zip, and then right click on it then extract and select appropriate folder which has alteast 50 GB space

<img width="323" height="291" alt="1o" src="https://github.com/wiring-neurons/images/blob/main/1o.png" />

#### After the file is extracted Open Oracle VirtualBox and click on New

<img width="293" height="215" alt="o1" src="https://github.com/wiring-neurons/images/blob/main/o1.png" />

#### Enter the Name as NeuronCore in the text box

<img width="462" height="245" alt="o2" src="https://github.com/wiring-neurons/images/blob/main/o2.png" />

#### Click on the Subtype then select Ubuntu

<img width="464" height="350" alt="o3" src="https://github.com/wiring-neurons/images/blob/main/o3.png" />

#### Click on version Scroll down till you find "Xubuntu x64" select it

<img width="433" height="350" alt="o4" src="https://github.com/wiring-neurons/images/blob/main/o4.png" />

#### Click on next or Hardware to proceed to the next screen

#### Here enter the RAM as 2048 and the CPU's as 2

<img width="476" height="235" alt="o5" src="https://github.com/wiring-neurons/images/blob/main/o5.png" />

#### Click on next or Hard Disk to proceed to the next screen
#### Then check the Use an Existing Virtual Hard Disk File

<img width="475" height="295" alt="o6" src="https://github.com/wiring-neurons/images/blob/main/o6.png" />

#### Then click on the file icon

<img width="475" height="295" alt="o7" src="https://github.com/wiring-neurons/images/blob/main/o7.png" />

#### Then click on Add

<img width="356" height="282" alt="o8" src="https://github.com/wiring-neurons/images/blob/main/o8.png" />

#### Then navigate in your system and select the vsdsquadron_fpga_mini.vdi file

<img width="470" height="350" alt="o9" src="https://github.com/wiring-neurons/images/blob/main/o9.png" />

#### Then click on Open
#### Then Finally click on "Finish" to creating the VM
#### Then Click on Start to launch you Linux Ubuntu VM

<img width="272" height="217" alt="o10" src="https://github.com/wiring-neurons/images/blob/main/o10.png" />

</details>

### ---------------------------------------------------------------
### ToolChain in Linux Ubuntu 20.04

<details>
<summary> Install on Linux Using Commands </summary>
<br>
  
#### This has been tried and tested for Linux Ubuntu 20.04 LTS Focal Fossa, if you are installing in any other version it may not work you can give it a try and troubleshoot
#### You can also install this on a VM if you create the VM using an ISO file

### __________________________________________________________
#### PREREQUISITE - 1
#### Make sure your user is added to Sudoers file

<details> <summary> If not added and you are facing error CLICK HERE </summary>
<br>

Execute the following commands in order
                                                            
1.
```
su -
```
                                                            
2.
Replace username with the actual username
                                                            
```
sudo usermod -aG sudo username
```
 
 Now reboot your system

                                                             
</details>

### __________________________________________________________
#### PREREQUISITE - 2 (Optional but very convenient)

#### When installing we have to enter a lot of commands an
#### YOU HAVE TO ENTER PASSWORD AFTER EACH COMMAND

 <details> <summary> if you want to remove the password then CLICK HERE </summary>
<br>


 
```
sudo passwd -d username
```
Replace username with the actual username
After executing your command enter the password for one last time



</details>

### __________________________________________________________
#### PREREQUISITE - 3 (Optional but very convenient)

<details>
<summary> If you are installing in VM and your clipboard is not working between windows and VM then CLICK HERE</summary>
<br>

1. Click on Devices > Insert Guest Additions CD Image

2.
```
sudo apt install -y build-essential dkms linux-headers-$(uname -r)
```

3.
```
sudo mkdir -p /media/cdrom
```

4.
```
sudo mount /dev/cdrom /media/cdrom
```

5.
```
sudo /media/cdrom/VBoxLinuxAdditions.run
```

Then click on Devices > Shared Clipboard > Bidirectional
Reboot your VM once if it's not working

</details>

### __________________________________________________________
#### From here we start the installation of the tool chain

Execute the commands in the proper order

1. This will install git
```
sudo apt install -y git
```

2. This will install make
```
sudo apt install -y make
```
3. Execute this commands in order
```
cd
```

4.
```
sudo apt install -y libftdi-dev libftdi1 libusb-1.0-0-dev
```

5.
```
sudo apt install build-essential clang bison flex libreadline-dev \
                 gawk tcl-dev libffi-dev git mercurial graphviz xdot \
                 pkg-config python3 libboost-system-dev libboost-python-dev \
                 libboost-filesystem-dev zlib1g-dev
```

6.
```
git clone https://github.com/cliffordwolf/icestorm.git
```

7.
```
cd icestorm
```

8.
```
make -j$(nproc)
```

9.
```
sudo make install
```

10.
```
cd
```

11.
```
wget https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2024-08-14/oss-cad-suite-linux-x64-20240814.tgz
```
12.
```
tar -xvzf oss-cad-suite-linux-x64-20240814.tgz
```
13.
```
cd oss-cad-suite
```
14.
```
source environment
```
15.
```
source $HOME/oss-cad-suite/environment
```
16.
```
cd
```
17.
```
echo 'source $HOME/oss-cad-suite/environment' >> ~/.bashrc
```
18.
```
sudo apt install -y gedit
```
19.
```
sudo apt install -y python3
```
20.
```
sudo apt install -y python3-serial
```
21.
```
sudo apt install -y python3-pyqt5
```
22.
```
sudo apt install -y python3-matplotlib
```
23.
```
git clone https://github.com/wiring-neurons/NeuronCore-FPGA-Pro.git
```
24.
```
cd NeuronCore-FPGA-Pro
```


</details>

### ---------------------------------------------------------------
### Trouble Shooting with VirtualBox

<details>
<summary> Trouble Shooting on Windows in VirtualBox CLICK HERE </summary>
<br>

#### Right Click on VM to open this Menu

<img width="353" height="385" alt="image" src="https://github.com/user-attachments/assets/a7be9e9b-73ed-4f83-a532-e3c9347d997a" />

#### Now Click on the Settings Option

<img width="363" height="370" alt="image" src="https://github.com/user-attachments/assets/0b796ab9-908c-4d65-bafe-6063f18c664d" />

#### Now Click on the Storage Option

<img width="580" height="356" alt="image" src="https://github.com/user-attachments/assets/0de549bc-d0ce-418b-ad75-38261d727c7b" />

#### Now right click on the "vsdsquadron_fpga_mini.vdi"

<img width="319" height="241" alt="image" src="https://github.com/user-attachments/assets/b4b3d022-9ea9-4302-9214-ed6f6afc050c" />

#### Now click on the Remove Attachment option

<img width="319" height="241" alt="image" src="https://github.com/user-attachments/assets/37cde333-b6e7-493c-bd6d-b2fc6ca3462a" />

#### Open File Explorer and find the vsd_squadron_fpga_mini.vdi file please make sure it is a vdi file and please enter the correct spelling

<img width="735" height="155" alt="image" src="https://github.com/user-attachments/assets/07238849-de14-4ba7-b5b7-111505fba8b4" />

#### Now select the file and click on the delete option

<img width="705" height="202" alt="image" src="https://github.com/user-attachments/assets/49885a29-13ba-45c3-a427-28e85d7000c4" />

#### Open File Explorer and find the vsd_squadron_fpga_mini.zip file please make sure it is a zip file and please enter the correct spelling

<img width="1486" height="369" alt="image" src="https://github.com/user-attachments/assets/e20def01-a1a2-49bf-b304-8ce2665f4223" />

#### If the file is not found Please Install it from here 
https://vsd-labs.sgp1.cdn.digitaloceanspaces.com/vsd-labs/vsdsquadron_fpga_mini.zip

#### After Finding or Downloading the file right click on it and then click extract all option

<img width="385" height="406" alt="image" src="https://github.com/user-attachments/assets/0e3786bc-8798-403c-9d8b-bf8d09c8c179" />

#### In this click on the Browse option and select an appropriate drive which has enough space

<img width="442" height="365" alt="image" src="https://github.com/user-attachments/assets/081353b9-c7ce-4616-9e80-985b2eabc9f7" />

#### Make sure you have at least 50 GB space in your machine to install

<img width="490" height="390" alt="image" src="https://github.com/user-attachments/assets/2b36c560-3250-4434-ba55-d48b1f71882f" />

#### After selecting appropriate drive click on the extract option

<img width="442" height="365" alt="image" src="https://github.com/user-attachments/assets/f10131d7-b4ba-458d-9c58-55daa70c6657" />

#### Now wait for some time until the extraction is complete

<img width="338" height="125" alt="image" src="https://github.com/user-attachments/assets/f8d43162-4a3a-4074-9766-fa2e5ceaa213" />

#### Now come back to the storage setting option in the Virtual Box and right click on the "Controller: SATA" option

<img width="432" height="278" alt="image" src="https://github.com/user-attachments/assets/f1ccf9b0-25d2-48e5-ab3b-208f22bf2472" />

#### Now click on the Hard Disk option

<img width="432" height="278" alt="image" src="https://github.com/user-attachments/assets/44106101-224c-48d4-80d4-e6983efee5c4" />

#### Click on the Add Option

<img width="307" height="125" alt="image" src="https://github.com/user-attachments/assets/b99f49a8-3747-491f-a8e6-f44b88445fbe" />

#### Here navigate and locate the extracted vdi file and select it

<img width="465" height="359" alt="image" src="https://github.com/user-attachments/assets/f5d0e5d2-63f0-4163-8874-20b4aea6ea8d" />

#### Now click on the Open option

<img width="465" height="359" alt="image" src="https://github.com/user-attachments/assets/c8f96d7b-b43e-43e0-aa79-7225481e519b" />

#### Now click on the Choose option

<img width="474" height="247" alt="image" src="https://github.com/user-attachments/assets/38f0b25a-863a-4f64-96b7-b3ec2897e3fd" />

#### Now click on the Ok option

<img width="431" height="341" alt="image" src="https://github.com/user-attachments/assets/bffa3fa9-9346-4273-a2b8-86c59c52777e" />

#### Now the Crashed VM should be fixed and it should launch and run correctly, in order to avoid this problem please don't move or delete the vdi file and while closing the Virtual Machine first close the Ubuntu Window and then the Virtual Box window, Directly closing the Vritual Box window might crash the Vritual Machine


</details>
