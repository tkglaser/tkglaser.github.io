---
layout: post
title:  "Oh Twitter..."
date:   2013-07-02
permalink: /oh-twitter/
---
I just realised, that the code in my 
[previous posts](http://www.tkglaser.net/2012/12/a-simple-twitter-feed-in-mvc-4-using.html) 
about Twitter plugins is broken.
This is because Twitter has 
[switched off the API v1](https://dev.twitter.com/blog/api-v1-retirement-final-dates). 
This means, all applications using it (and using my example code) have stopped working.
<!--more-->

There is a relatively easy solution using the great 
[TweetSharp](https://github.com/danielcrenna/tweetsharp) package. 
It works very well (apart from a 
[very minor formatting issue](https://github.com/danielcrenna/tweetsharp/issues/125)) 
and is pretty easy to use, which you will see in this post.

### What you need
First of all you need a few keys from Twitter. Namely a ConsumerKey, a ConsumerSecret, an AccessToken and an AccessTokenSecret. You can get all this in your Twitter developer login area. I'm not sure, why it has to be quite so complicated, but that's how it is.

Next, you need the TweetSharp package which you can install via your NuGet package manager.

### Get some tweets
The complicated part is over, the rest is smooth sailing. This is the code to get some tweets:
var api = new TwitterService("myConsumerKey", "myConsumerSecret");
```csharp
api.AuthenticateWith("myAccessToken", "myAccessTokenSecret");

var tweets = api.ListTweetsOnUserTimeline(
  new ListTweetsOnUserTimelineOptions()
  {
    ScreenName = "tkglaser",
    Count = 3,
    IncludeRts = true
  });
```
This retrieves the last 3 Tweets (including Re-Tweets) from my timeline.
### Display them
All that is left to do is stick the Tweets into your MVC model and display them in a view. This is quite easy as well:
```html
<ul>
  @foreach (var tweet in Model.Tweets)
  {
    <li>@Html.Raw(tweet.TextAsHtml)</li>
  }
</ul>
```
### Done
That's it, hope it all works for you as easily as it worked for me. I'll put up a little example as well at some point, or at least repair the old examples.
