### Setting up Vagrant

#####Prior to starting, make sure your [version of Vagrant](http://downloads.vagrantup.com/) is at least 1.1.0. 

Download the Vagrant box here: https://www.dropbox.com/s/5rgfq8nedjxgm0c/package.box (1.6 Gb)

After you download it, run the following commands in the same directory that you downloaded the Vagrant box
```
$ vagrant box add 157box package.box
$ vagrant init 157box
$ vagrant up
$ vagrant ssh
```

Using a text editor (such as emacs or vi), edit the Vagrantfile to add these two lines below line 22
```
config.vm.network :forwarded_port, guest: 80, host: 8080
config.vm.network :forwarded_port, guest: 8888, host: 7777
```

The analyzers directory will not be the current version. You'll need to pull the current version from the repository using git. Set up git in the VM by following git set-up instructions [here](https://help.github.com/articles/set-up-git#platform-linux). Then, execute the following commands:
```sh
git remote rm origin
git remote add https://github.com/stat157/analyzers.git
git pull origin master
```

To start up the analyzers repo, run
```
cd analyzers/notebooks

workon 157  # this is to start the virtual environment with everything installed. 
# You should see the change from
# vagrant@precise64:~/analyzers$
# to
# (157)vagrant@precise64:~/analyzers$
#, which means that you're now in the virtual environment

ipython notebook --ip=0.0.0.0 --no-browser --pylab=inline
```

To make your life easier
```
alias ipy='ipython notebook --ip=0.0.0.0 --no-browser --pylab=inline --script'
```
then you can just type ```ipy``` to start the ipython notebook.


### Setting up the Virtual Machine
--------------------------------------------------------------------------------------------------------------

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

Set up Git
https://help.github.com/articles/set-up-git

If you can't pull because of ssh public key problem, do

```
git remote rm origin
git remote add origin https://github.com/stat157/analyzers.git
git pull origin master
```

to change between SSH and HTTPS

Make your life easier, `alias ipy='ipython notebook --ip=0.0.0.0 --no-browser --pylab=inline --script'`. 
This will alias all the extra arguments for IPython notebook under `ipy`. Then inside the `notebooks` 
directory, run `ipy` and navigate to port 8888 on your local machine.
