---
layout: post
title:  "Twitter Bootstrap MVC 4 remove body padding in mobile view"
date:   2012-12-04
permalink: /twitter-bootstrap-mvc-4-remove-body/
redirect_from: /2012/12/twitter-bootstrap-mvc-4-remove-body.html
---
Just a little pitfall I came across today. If you are using 
[Twitter Bootstrap](http://twitter.github.com/bootstrap/) in ASP MVC 4, you might have the same problem.
### The Problem
If viewed in desktop mode, my page looks something like this:

![BootStrap1.png](/assets/images/BootStrap1.png)

Nothing unusual, there is a top nav bar and it is where is should be. Now, if I resize the browser, the page goes 
into mobile mode and looks like this:

![BootStrap2.png](/assets/images/BootStrap2.png)

Suddenly, there is a 60px high white space above the nav bar, which looks very much broken.

To complete the picture, here is the code in the layout:
```css
@Styles.Render("~/Content/bootstrap")
<style>
  body {
    padding-top: 60px;
  }
</style>
```
The body padding is required because otherwise the top nav bar covers a portion of the body in desktop view.

As you might have guessed by now, the body padding is also the culprit for the ugly white gap in mobile mode.

Bootstrap has a solution for this by providing a separate responsive css file which overrides the body padding in mobile mode. You need to reference the responsive css after your body padding. Unfortunately, the nuget package bundles the two css files together:
```csharp
BundleTable.Bundles
  .Add(new StyleBundle("~/Content/bootstrap")
  .Include("~/Content/bootstrap.css", 
           "~/Content/bootstrap-responsive.css"));
```
This means, you can't call the css files separately using the MVC 4 @Styles.Render() command.
### The Solution
This is only one possible solution. If there is a simpler one, please drop me a comment below.

First, rip the bundle apart in BootstrapBundleConfig.cs:
```csharp
BundleTable.Bundles
  .Add(new StyleBundle("~/Content/bootstrap")
  .Include("~/Content/bootstrap.css"));
BundleTable.Bundles
  .Add(new StyleBundle("~/Content/bootstrap-responsive")
  .Include("~/Content/bootstrap-responsive.css"));
```
Then change your layout to reference the css files in the correct order:
```css
@Styles.Render("~/Content/bootstrap")
<style>
  body {
    padding-top: 60px;
  }
</style>
@Styles.Render("~/Content/bootstrap-responsive")
```
That should do the trick, the white padding in mobile mode is gone and the nav bar does not cover a part of the body in desktop mode.

As always, please feel free to leave a comment if you find this useful or have an improved solution.
