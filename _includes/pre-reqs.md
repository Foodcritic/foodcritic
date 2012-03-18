## Prerequisites
Foodcritic runs on Ruby (MRI) 1.9.2+ which depending on your workstation setup may be a more recent version of Ruby than you have installed. The [Ruby Version Manager (RVM)](http://beginrescueend.com/) is a popular choice for running multiple versions of ruby on the same workstation, so you can try foodcritic out without running the risk of damaging your main install.

## Installing RVM
RVM can be installed from the current development code on the projects GitHub - however if you are just getting started with RVM I would recommend installing the latest stable version with the `stable` argument. The full instructions for installing RVM can be found here:

* [http://beginrescueend.com/rvm/install/](http://beginrescueend.com/rvm/install/)

See also this blog post from Michal Papis for more information:

* [http://www.engineyard.com/blog/2012/rvm-stable-and-more/](http://www.engineyard.com/blog/2012/rvm-stable-and-more/)

## Installing Ruby 1.9.3
With RVM installed successfully you can now use it to install MRI 1.9.3:

    $ rvm install ruby-1.9.3
