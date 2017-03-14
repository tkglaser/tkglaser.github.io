---
layout: post
title:  "Star Rating Widget in MVC 3 Razor"
date:   2012-03-29
permalink: /star-rating-widget-in-mvc-3-razor/
---
I wanted to have a nice star rating widget on my MVC entry form. Something like this:

![Rating.png](/assets/blog/images/Rating.png)

[Orkan's jQuery UI widget](http://orkans-tmp.22web.net/star_rating/) seems to be a good choice. The problem is, it doesn't quite work on MVC forms, because the scripts insists on creating the hidden input field which holds the rating value as "disabled".
```html
<input type="hidden" name="Rating" value="3" disabled="disabled">
```
This is problematic because a disabled field is not posted back with the form which means we can't get hold of the value. There seems to be an option in the widget to fix this, but it doesn't quite seem to work in the current version.

However, there is a (slightly blunt) solution to this, which is attaching this piece of JavaScript to the submit button of your form:
```javascript
$('#mySubmitBtn').click(function () {
  $('input[name="Rating"]').removeAttr('disabled');
});
```
This removes the disabled attribute immediately before the form is posted. It's an inelegant dirty hack but it fixed the issue for me.

Maybe there is a better way of fixing Orkan's rating widget, if so, please let me know.
