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


```
sudo apt install git
```

```
sudo apt install make
```

```
git clone https://github.com/wiring-neurons/Ubuntu-Makefile.git
```

```
make neuroncore
```

