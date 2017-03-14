---
layout: post
title:  "Waiting spinner for long-running form submits in ASP MVC 3 Razor using jQuery"
date:   2012-02-21
permalink: /waiting-spinner-for-long-running-form/
---
In the application I'm currently working on, I have a search form, where you can specify a number of parameters, press the search button, and then a few hundred thousand rows in the database are accumulated based on the search request. This takes up to 10s if the cache is not initialised.

Studies have shown [[1]](http://www.useit.com/papers/responsetime.html), that this amount of time can be too long. Users might press the search button again because they're not sure, anything is happening.

A possible solution (other than optimising my db query) is a waiting animation, like an hour glass or, more modern, a spinner.

First, I tried implementing something using an animated gif as described here [[2]](http://stackoverflow.com/questions/41162/javascript-spinning-wait-hourglass-type-thing). 
However, I hit a wall with this, because Internet Exporer stops animating gifs after a form has been 
submitted [[3]](http://forums.asp.net/t/1475031.aspx/1).

I found the final missing piece in one of the answers here [[4]](http://stackoverflow.com/questions/780560/animated-gif-in-ie-stopping), 
which completes it to a workable solution in IE 9 and all other browsers.

Here is a little demo app that shows what we will have at the end of the tutorial:

- [http://playground.tkglaser.net/Spinner [7]](http://playground.tkglaser.net/Spinner)

Let's look at the code.

### 1. Create the testing environment
For our testing purposes, a very minimal form will do:
```html
@using (Html.BeginForm())
{
    <div class="editor-label">Search for things</div>
    <div class="editor-field">
        @Html.TextBox("search")
    </div>
    <p>
        <input id="submitbtn" type="submit" value="Search" />
    </p>
}
```

It should look like this:

![Spinner Form](/assets/images/spinner_form.png)

The post action has a 5 second wait to simulate some sort of long running action:
```csharp
[HttpPost]
public ActionResult Index(string search)
{
  Thread.Sleep(5000);
  return View();
}
```
If you run this now, your browser should we waiting for five seconds after you've pressed the search button.

### 2. The overlay
The waiting spinner is an overlay div, which is css-styled to overlay the entire browser client area. The div is initially invisible and will be switched on using JavaScript later.
Here is the CSS for the overlay elements:
```css
<style type="text/css">
    #loading
    {
        display:none;
        position:fixed;
        left:0;
        top:0;
        width:100%;
        height:100%;
        background:rgba(255,255,255,0.8);
        z-index:1000;
    }
  
    #loadingcontent
    {
        display:table;
        position:fixed;
        left:0;
        top:0;
        width:100%;
        height:100%;
    }
  
    #loadingspinner
    {
        display: table-cell;
        vertical-align:middle;
        width: 100%;
        text-align: center;
        font-size:larger;
        padding-top:80px;
    }
</style>
```
Notice, that the outermost div has an 80% white-transparent background. This will give a nice effect of the side going into a shaded busy-mode.

And the overlay itself (it can be at any place in the view):
```html
<div id="loading">
    <div id="loadingcontent">
        <p id="loadingspinner">
            Searching things...
        </p>
    </div>
</div>
```
### 3. Switching to wait mode
The next step is make the div visible when the search button is pressed. This is best done with jQuery like so:
```javascript
<script type="text/javascript">
    $(function () {
        $("#submitbtn").click(function () {
            $("#loading").fadeIn();
        });
    });
</script>
```
The fadeIn() function does what it says on the tin and provides a nice transitional effect.

### 4. Adding an animation
In theory, we're done. The code so far will white-out the search form and display a message in the middle of the browser window.

But an animation makes the whole thing much nicer, so let's add one.

A I mentioned in the introduction, an animated gif won't work, because IE stops all gif animation, once a form is submitted.

Luckily, there is a solution. Download the spin.js script from [http://fgnass.github.com/spin.js [6]](http://fgnass.github.com/spin.js) 
and add it to your project in the scripts folder. This script displays a waiting spinner using pure JavaScript, no gif animation.

Then, extend out loading script like this:
```javascript
<script type="text/javascript" 
        src="@Url.Content("~/Scripts/spin.min.js")"></script>
<script type="text/javascript">
    $(function () {
        $("#submitbtn").click(function () {
            $("#loading").fadeIn();
            var opts = {
                lines: 12, // The number of lines to draw
                length: 7, // The length of each line
                width: 4, // The line thickness
                radius: 10, // The radius of the inner circle
                color: '#000', // #rgb or #rrggbb
                speed: 1, // Rounds per second
                trail: 60, // Afterglow percentage
                shadow: false, // Whether to render a shadow
                hwaccel: false // Whether to use hardware acceleration
            };
            var target = document.getElementById('loading');
            var spinner = new Spinner(opts).spin(target);
        });
    });
</script>
```
This configures the spinner and adds it to our loading div.

### 5. Result
After pressing the search button, it should look something like this:

![Spinner Running](/assets/images/spinner_running.png)

Also, here is a little demo app that shows the finished result:

[http://playground.tkglaser.net/Spinner [7]](http://playground.tkglaser.net/Spinner)

All done. When you press the submit button on your form, the whole browser client window should fade to white and the spinner should appear. When the long running operation has finished, a new page will be loaded so the spinner will disappear.

Please leave a comment if find this useful or you have a suggestion.

References:

1. http://www.useit.com/papers/responsetime.html
2. http://stackoverflow.com/questions/41162/javascript-spinning-wait-hourglass-type-thing
3. http://forums.asp.net/t/1475031.aspx/1
4. http://stackoverflow.com/questions/780560/animated-gif-in-ie-stopping
5. http://jquery.com/
6. http://fgnass.github.com/spin.js/
7. http://playground.tkglaser.net/Spinner

