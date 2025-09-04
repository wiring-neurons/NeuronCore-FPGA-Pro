neuroncore:
  wget https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2024-08-14/oss-cad-suite-linux-x64-20240814.tgz
  tar -xvzf oss-cad-suite-linux-x64-20240814.tgz
  cd oss-cad-suite
  source environment
  source $HOME/oss-cad-suite/environment
  source ~/.bashrc
  cd
  sudo apt install gedit
  cd NeuronCore-FPGA-Pro

clip:
  sudo apt install -y build-essential dkms linux-headers-$(uname -r)
  sudo mkdir -p /media/cdrom
  sudo mount /dev/cdrom /media/cdrom
  sudo /media/cdrom/VBoxLinuxAdditions.run
