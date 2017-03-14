The features of the upcoming [ASP MVC 4](http://www.asp.net/mvc/mvc4) are nothing short of amazing. 
I personally can't wait to use this. But I promised myself to wait for the final release.

Naturally, I cracked. According to [Scott Guthrie](http://weblogs.asp.net/scottgu/archive/2012/02/19/asp-net-mvc-4-beta.aspx), 
MVC 4 Beta can be installed side-by-side with MVC 3, so I installed it this morning and created some MVC 4 test projects.

After having a play I moved on to the day job, working on our MVC 3 application.

All was well until I deployed the MVC 3 application to the test server.

It crashed. The error message was complaining about `System.Web.WebPages.Razor 2.0.0.0` not being present.

After some research, it turned out, that even though I have made **no changes to my existing MVC 3 project**, the linker 
had used the `System.Web.WebPages.dll` from MVC 4.

This makes sense, I suppose, as without additional knowledge, the linker uses the binary with the highest version number.

In my case, this created the potentially deadly situation of an application working perfectly well in my dev environment, but having new missing dependencies on the server. Also, this created a project that was probably using half of MVC 3 and half of MVC 4.

Luckily, uninstalling MVC 4 Beta and rebuilding the MVC 3 app solved the issue. Of course I could have edited the MVC 3 project references to specifically use the dlls of MVC 3. But I needed a clean build and quickly.

So, please learn from my experience and be extra careful with installing MVC 4 Beta when you have MVC 3 production code on the same development box.

**Update:**
It seems, [I'm not the only one, having this problem](http://maxtoroq.blogspot.co.uk/2012/02/webpages-exception-in-aspnet-mvc-3.html). 
