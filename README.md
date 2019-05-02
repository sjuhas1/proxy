
#### Requirements
Virtualbox
Vagrant

#### How to use
Start the containers
```
vagrant up
```
Stop the containers
```
vagrant destroy -f
```
Access the containers
```
vagrant ssh puppet
#or
vagrant ssh proxy
```

#### What is inside
A vagrant setup to run a puppet master (`puppet`) and a domain proxy (`proxy`).
The provisioning of the instances is done via vagrant, with a bit of puppet aid.
The excercise is to setup a domain proxy with proper reverse and forward 
proxy settings.

