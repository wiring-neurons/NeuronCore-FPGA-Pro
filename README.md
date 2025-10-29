# NeuronCore FPGA Complete Tool Chain Installation for Linux

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
3. This will clone the installation Makefile
```
git clone https://github.com/wiring-neurons/Ubuntu-Makefile.git
```
4. Bring that to the home folder, execute this commands in order
```
cd
```
```
cd Ubuntu-Makefile
```
```
mv Makefile /home/neuroncore/
```
4. This will start the installation process and will take a while
```
make neuroncore
```

