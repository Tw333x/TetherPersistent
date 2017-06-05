# TetherPersistent

 
Using local ip tethering and autoconnect, I am trying to publish a simple memo's text under the unique manager id for each app to demonstrate a problem I have.

From what I've read, I expect published persistent resources to (re)send their values only when they change, or when a new subscription to that resource connects. However, I am getting a behavior where either the sender is continuously resending, or the receiver is falsly receiving the persistent resource every second or more.

The unexpected behavior happens when 3 or more instances are running, as soon as a second app calls autoconnect. The second and third app find each other, but then their original subscription to the first paired device refreshes continuously.

To rule out blaming the problem on the unexpected choice of running multiple apps from one box, I verified that this happens on any combination of two or three devices I have easy access to (android and windows).

* samsung s6 and 10" tablet
* windows 10
* delphi tokyo

asked on https://stackoverflow.com/questions/44378576/delphi-peer-to-peer-tethering-persistent-resources-continuously-updating-when
