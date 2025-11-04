# NeuronCore FPGA Complete Tool Chain Installation for Linux

<details>
<summary> Install on Windows using VirtualBox then CLICK HERE </summary>
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
<summary> Install on Linux then CLICK HERE </summary>
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
wget https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2024-08-14/oss-cad-suite-linux-x64-20240814.tgz
```
5.
```
tar -xvzf oss-cad-suite-linux-x64-20240814.tgz
```
6.
```
cd oss-cad-suite
```
7.
```
source environment
```
8.
```
source $HOME/oss-cad-suite/environment
```
9.
```
cd
```
10.
```
echo 'source $HOME/oss-cad-suite/environment' >> ~/.bashrc
```
11.
```
sudo apt install -y gedit
```
12.
```
git clone https://github.com/wiring-neurons/NeuronCore-FPGA-Pro.git
```
13.
```
cd NeuronCore-FPGA-Pro
```

</details>

