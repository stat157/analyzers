### Setting up the Virtual Machine
--------------------------------------------------------------------------------------------------------------

#### TODO: add initial details, e.g. VirtualBox setup, Vagrant, using raring.. (ubuntu 13.something), and setting up port forwarding

```sh
sudo apt-get update
sudo apt-get install ipython-notebook 
sudo apt-get install python-pip
sudo pip install virtualenv
```

#####ggplot Dependencies
```
sudo pip install ggplot
```

```
sudo pip install matplotlib
sudo pip install pandas
sudo apt-get install numpy
sudo apt-get install scipy
sudo pip install statsmodels
sudo pip install patsy
```

##### virtualenv dependencies
######Install virtualenv
```
pip install virtualenv
pip install virtualenvwrapper
sudo apt-get update
sudo apt-get install python-dev
```
Try to be OS dependent and use ```pip```
```
pip install numpy
pip install scipy
pip install matplotlib
pip install pandas
pip install sympy
```
```
sudo apt-get install --upgrade g++
pip install ipython[all]
```
Check to see if a C++ compiler is installed (may be required for your ```ipython``` installation), as it is a dependency for ```pyzmq```; all the dependencies of ```ipython``` will be installed by including ```[all]```
