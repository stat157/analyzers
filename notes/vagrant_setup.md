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

To start the virtual environment with everything installed, run
```
cd analyzers/notebooks
workon 157
```
 You should see the prompt change from
`vagrant@precise64:~/analyzers$` to `(157)vagrant@precise64:~/analyzers$`
 which means that you're now in the virtual environment! Now type
```sh
alias ipy='ipython notebook --ip=0.0.0.0 --no-browser --pylab=inline --script'
```
so instead of typing all the extra arguments for IPython notebook, you can just type `ipy`. Inside the `notebooks` directory (which should be the current directory), type `ipy` and navigate to port 7777 on your local machine.  (That means in a web browser window, navigate to 127.0.0.1:7777).

Since you've already pulled the latest version of the [analyzers repo](https://github.com/stat157/analyzers), you'll see the most recent version of our ipython notebooks.  Check out the [aftershock arrival times notebook](https://github.com/stat157/analyzers/blob/master/notebooks/aftershock_arrival_plots.ipynb), edit it, and run it!  Have fun!



### Behind the Scenes: How we set up the packaged Virtual Machine
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
