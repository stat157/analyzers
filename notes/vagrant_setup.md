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

-----------------------------
##### virtualenv dependencies

######Update your Ubuntu VM with python-dev first. Make sure to have the C/C++ compilers installed/updated.
Also install the necessary packages for scipy/matplotlib (see http://stackoverflow.com/questions/9829175/pip-install-matplotlib-error-with-virtualenv 
for more details)
```
sudo apt-get update
sudo apt-get install python-dev
sudo apt-get install libfreetype6-dev
sudo apt-get install --upgrade gcc
sudo apt-get install --upgrade g++
sudo apt-get build-dep python-matplotlib
sudo apt-get build-dep python-scipy
```

######Install virtualenv (and perhaps the wrapper for easier use)
```
pip install virtualenv
pip install virtualenvwrapper
```

Using `virtualenv`:
* Create a new virtual environment:
```
virtualenv stat157
```
* Activate it
```
source stat157/bin/activate
```

Using `virtualenvwrapper` (which is much easier, IMO)
```
mkvirtualenv stat157
```

Install the necessary dependencies with pip. Use `[all]` to install everything needed in one go!
```
pip install ipython[all]
pip install pandas[all]
pip install matplotlib[all]
pip install ggplot[all]
pip install scipy
pip install patsy
pip install statsmodels
```
