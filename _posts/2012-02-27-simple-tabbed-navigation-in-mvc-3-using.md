---
layout: post
title:  "Simple Tabbed Navigation in MVC 3 using HTML Only"
date:   2012-02-27
permalink: /simple-tabbed-navigation-in-mvc-3-using/
---
Grouping multiple sites together with a sort of tab folder navigation is a common requirement. Unlike the navigation in the MVC default project template, you want to highlight the current tab to show users where they are.

It would also be nice from a coding perspective if the Views within the tabs are ignorant to the fact that they belong to a tab folder.

It can be done to some extent with [jQuery UI Tabs](http://jqueryui.com/demos/tabs/). The disadvantage if this is that you need to load your entire content into a single View page. While this may be fine for a few small pages, a complex tab folder could load for a long time to display things in a tab that the user is not even interested in. Also you need a single Action method that might be long and complicated.

Another way is to have individual Actions and Views and include the tab links within the individual View pages. You could then emphasize the current tab just by hardcoding some CSS class into it.

This is of course very ugly as the whole tab folder code is repeated in every View and introducing a new tab at a later point would mean adding a tab link to every previous View.

Therefore, the tab folder code must go into the layout. If you want to modify your main template or create a specific tab folder layout depends on the individual project.

For this demo, I'll modify the navigation in the main layout of the standard MVC project template to highlight the current tab. This change needs no modification of an Action or even a View, it's only in the layout.

This is what you'll have at the end of this demo:

![Tab01](/assets/images/Tab01.png)

![Tab02](/assets/images/Tab02.png)

It may not be very visually appealing but you can of course tweak this with CSS to your hearts content. Let's go.

The full code

In your _Layout.cshtml change the nav element to this:
```html
<nav>
    <ul id="menu">
    @{ string action = ViewContext.Controller.ValueProvider
           .GetValue("action").RawValue.ToString(); }
        <li class="@("Index".Equals(action) ? "selected" : "" )">
            @Html.ActionLink("Home", "Index", "Home")
        </li>
        <li class="@("About".Equals(action) ? "selected" : "")">
            @Html.ActionLink("About", "About", "Home")
        </li>
        <li class="@("Third".Equals(action) ? "selected" : "")">
            @Html.ActionLink("A third page", "Third", "Home")
        </li>
    </ul>
</nav>
```
The first interesting section of this is
```csharp
@{ string action = ViewContext.Controller.ValueProvider
       .GetValue("action").RawValue.ToString(); }
```
Here, MVC is queried for the name of the current Action (source). For the standard landing page, it will be "Index", if the About button is clicked, it will be "About" and so on. You can also query the current controller by passing "controller" instead of "action".

The second section of interest
```html
<li class="@("About".Equals(action) ? "selected" : "")">
```
assigns the "selected" CSS class to the currently selected tab. Conveniently, the MVC default project template's CSS already contains a definition for the "selected" class, so for the purpose of this little demo, no CSS needs to be written.

And that's all it is. There is a full tabbed navigation, highlighting the current tab and all Views and Actions are unaware that they are in a tab folder.
