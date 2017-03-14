[Appharbor.com](http://appharbor.com/) is a great service. It allows you to create an ASP.NET web app using MVC 4 or other versions of ASP and configure it, so that a simple commit to a github(*) repository automatically compiles and deploys your app to appharbor. I might write up an article on how to do this at some point.

One thing I noticed is that after 20 minutes of inactivity, your application is being stopped on 
the server and the next access can take a bit longer as it needs to be restarted. With my demo app 
[tkglaser.apphb.com](http://tkglaser.apphb.com/) the initial load time could be up to 20s. 
[This is normal IIS behaviour](http://stackoverflow.com/questions/9242676/how-do-i-improve-app-performance-on-appharbor).

One possible solution is to continuously ping your app to simulate activity. As the 
[linked article](http://stackoverflow.com/questions/9242676/how-do-i-improve-app-performance-on-appharbor) suggests, this
can be done by using paid services such as [Pingdom](https://www.pingdom.com/) or [StillAlive](https://stillalive.com/).

If you have (like me) a little Linux box at home, which is running all the time, there is a much simpler and cheaper solution. You can set up a cron job and use curl to retrieve a page from your app every minute. 
Here is how to do it:

1. Become root: `sudo su -`
2. Edit your crontab: `crontab -e`
3. Add this line: `* * * * * curl mywebsite.apphb.com`
4. Save and close

You can check that it's working by watching the syslog:
```
tail -f /var/log/syslog
```
Disclaimer: Some commands might be subtly different depending on your flavour of Linux. I'm using Ubuntu.

Pinging the app every minute might be a bit of a brute force solution but it worked perfectly for me, no more waiting times after some inactivity.

(*) Appharbor supports other services as well, not just github. Go to [appharbor.com](http://appharbor.com/) to learn more.
