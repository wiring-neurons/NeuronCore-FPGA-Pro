# NeuronCore FPGA Complete Tool Chain Installation for Linux

<details>
<summary> Install on Windows using VirtualBox CLICK HERE </summary>
<br>

Step 1:
Install Microsoft C++ redistributable

CLICK below to start downloading
https://aka.ms/vs/17/release/vc_redist.x64.exe

Step 2:
Install Oracle Virtual Box Version 7.1.2
https://download.virtualbox.org/virtualbox/7.1.2/VirtualBox-7.1.2-164945-Win.exe

Step 3:
Install the Virtual Box VDI File
 
</details>



<details>
<summary> Install on Linux CLICK HERE </summary>
<br>

Make sure your user is added to Sudoers file

<details>
<summary> If not added and you are facing error CLICK HERE </summary>
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

We Start the installation with these commands


YOU HAVE TO ENTER PASSWORD AFTER EACH COMMAND

<details>
<summary> if you want to remove the password then CLICK HERE </summary>
<br>
 
```
sudo passwd -d username
```
Replace username with the actual username
After executing your command enter the password for one last time
</details>

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

</detials>


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
git clone https://github.com/wiring-neurons/NeuronCore-FPGA-Pro.git
```
20.
```
cd NeuronCore-FPGA-Pro
```

</details>

