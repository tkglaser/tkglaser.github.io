---
layout: post
title:  "Syntax highlighting in blogger"
date:   2012-03-13
permalink: /syntax-highlighting-in-blogger/
---
Upon special request, a quick post about syntax highlighting in [blogger](http://www.blogger.com/).

I use the [google-code-prettify](http://code.google.com/p/google-code-prettify/) package for this. 
According to the project page, this library is powering `code.google.com` and `stackoverflow.com`. This means, it's 
probably good enough for my blog as well.

In order to format the code, you need to take three steps:

### 1. Mark the code in your post

This is easily done by wrapping your code snippets in:
```html
<pre class="prettyprint">...</pre>
```
You can also hint the formatter towards the language, the code is in by using
```html
<pre class="prettyprint lang-html">...</pre>
```
A full list of supported languages can be found here.

### 2. Run the prettification JavaScript

That part is slightly more complicated. 
According to [Alex Conrad's blog](http://www.alexconrad.org/2011/12/highlight-code-with-bloggers-dynamic.html), the 
code to invoke google-code-prettify is:
```javascript
(function() {
    try {
        prettyPrint();
    } catch(e) {
        var scriptId = 'prettyPrinter';
        if (document.getElementById(scriptId) === null) {
            var elem = document.createElement('SCRIPT');
            elem.id = scriptId;
            elem.onload = function() {
                prettyPrint();
            }
            elem.src = "https://google-code-prettify.googlecode.com/svn/trunk/src/prettify.js";
            var theBody = document.getElementsByTagName('body')[0];
            theBody.appendChild(elem);
        }
    }
})();
```
This script tries to invoke the prettyPrint() method. Initially it will fail as the script google-code-prettify is not yet referenced. In that case, the script adds a dynamic script reference and tries again.

This code needs to be executed on every blog post as the user might come in from a direct post link. So in theory, the script needs to be added to every post. Luckily, Alex has bundled the code, so all you need to do is add this to the bottom of every post:
```javascript
<script src="https://raw.github.com/gist/1522901/" 
        type="text/javascript">
</script>
```
Another way is to edit the HTML template of your blog. To do this go to your blog dashboard > Template > Edit HTML > Proceed > [check] Expand Widget Templates and add the code under the <data:post.body/> tag.

### 3. CSS
The google-code-prettify library comes with three different themes. Choose one of the themes, copy the CSS content and add it to your blog by going to Template > Customise > Advanced > Add CSS.

Feel free to modify the CSS in any way you like to fit the colours to your blog.

### 4. Result
It's a bit more complicated than it should be, but it works. The code in this posting is formatted in the described way, so this is pretty much what you will get. I hope, someone finds this helpful, please let me know what you think.
