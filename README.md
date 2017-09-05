#PacketWeaver
Pick up a shell

Background:
------

Devices like the LAN turtle (https://lanturtle.com/wiki) have made penetration testing "drop" devices cheap and easy to access. Relatively simple configuration allows the deployment of a number of types of shells. Simple scripts allow the setup of OpenVPN, ICMP, SSH, and many other kinds of tunnels--making it easy to "drop a shell".

This project aims to make the process of picking up a shell just as simple. On a penetration test or red team it's common to have a number of shells all connecting back, which can get difficult to manage.
Acting as a concentrator of sorts, PacketWeaver creates a simple web interface which can deploy any number of tunnel listeners. 
It can then direct the tunnels to the host where PacketWeaver is running, forward the traffic to a remote system (like a Kali box), etc. It can even change the destination of the traffic later, saving having to redeploy your shells.

Prerequisites:
------

To do
  
  
Credits:
------
 
* Massive thanks to Muhammed Nagy for his help! https://github.com/muhammednagy
  
  
Roadmap:
------

* There are a number of improvements and future features to introduce. I'll put pen to paper at some point.