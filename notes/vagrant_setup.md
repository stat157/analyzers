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
