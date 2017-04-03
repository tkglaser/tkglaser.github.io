---
layout: post
title:  "Custom Twitter Feed on your MVC 4 Layout Page"
date:   2012-12-16
permalink: /custom-twitter-feed-on-your-mvc-4/
redirect_from: /2012/12/custom-twitter-feed-on-your-mvc-4.html
---
As a follow-up to [this post](http://www.tkglaser.net/2012/12/a-simple-twitter-feed-in-mvc-4-using.html), 
I needed to get the home-made Twitter feed onto the layout page of our MVC 4 app. Like this:

[playground.tkglaser.net/TwitterLayout](playground.tkglaser.net/TwitterLayout)
<!--more-->

The problem is that the layout page has no model and no code-behind. Since the Twitter feed is populated in code-behind on the server, this is a problem.

The answer is a PartialView populated by a ChildAction.
### 1. The Model
The Model remains unchanged from the original implementation.
### 2. The Controller
Change the Action that retrieves the tweets and populates the model to be a ChildAction returning a PartialView.
```csharp
[ChildActionOnly]
public PartialViewResult Tweets()
{
  RestClient client = new RestClient("http://api.twitter.com/1");
  
  // [...] see original post for full implementation
  
  model.Tweets =
    jsonDeserializer.Deserialize<List<Tweet>>(response);

  return PartialView(model);
}
```
### 3. The View
For the View, create a new partial view displaying the tweets.
```html
@model net.tkglaser.demos.Models.TwitterFeed.LandingModel

<ul>
  @foreach (var tweet in Model.Tweets)
  {
    <li>
      <img src="@tweet.user.profile_image_url" />
      @Html.Raw(tweet.GetTextWithLinks())
    </li>
  }
</ul>
```
Now, you can simply insert the tweets into the layout, or anywhere else using this line:
```html
@Html.Action("Tweets")
```
This enables you to put your Twitter feed into the layout so every page will display it.

As always, please feel free to leave a comment if you find this useful or have a suggestion.
