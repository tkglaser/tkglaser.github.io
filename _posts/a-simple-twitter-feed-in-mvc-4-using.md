If you want to include a Twitter feed into your web site, one option is to use the standard Twitter widget, which looks 
something like this:

![TwitterWidget.png](/assets/blog/images/TwitterWidget.png)

In many cases, this will be good enough. But you might want to embed your Twitter messages more organically into your page so it fits in with the overall look and feel. In that case, you would want to call the Twitter API and display the tweets yourself. This little tutorial shows, how to do exactly that in ASP MVC 4.    Here is a demo app that shows the finished result:

[playground.tkglaser.net/TwitterFeed](http://playground.tkglaser.net/TwitterFeed)

### 1. The Model
As always in MVC, it starts with the model. The model reflects the Twitter API model for a tweet, 
[which is not as straightforward as one might think](https://dev.twitter.com/docs/api/1/get/statuses/user_timeline).

_**Note**: I am using the Twitter 1.0 API although it is deprecated. This is because you don't need an API key and I was too lazy 
to get one for API 1.1._

Here is my C# model for a tweet. It only contains the fields I'm interested in for this particular demo.
```csharp
public class User
{
  public string profile_image_url { get; set; }
}

public class Url
{
  public string url { get; set; }
  public string expanded_url { get; set; }
  public string display_url { get; set; }
}

public class Entity
{
  public List<Url> urls { get; set; }
}

public class Tweet
{
  public string created_at { get; set; }
  public string text { get; set; }
  public User user { get; set; }
  public List<Entity> entities { get; set; }
}

public class LandingModel
{
  public List<Tweet> Tweets { get; set; }
}
```
### 2. The Controller
Next is the code to call the Twitter API. To do this, I've installed the [RestSharp nuget package](http://nuget.org/packages/RestSharp) into my project.
```csharp
RestClient client = new RestClient("http://api.twitter.com/1");
JsonDeserializer jsonDeserializer = new JsonDeserializer();
var model = new LandingModel();

var request = new RestRequest(Method.GET);

request.Resource = "statuses/user_timeline.json";

request.Parameters.Add(new Parameter() { 
  Name = "screen_name", 
  Value = "tkglaser", 
  Type = ParameterType.GetOrPost });

request.Parameters.Add(new Parameter() { 
  Name = "count", 
  Value = 10, 
  Type = ParameterType.GetOrPost });

request.Parameters.Add(new Parameter() { 
  Name = "include_rts", 
  Value = true, 
  Type = ParameterType.GetOrPost });

request.Parameters.Add(new Parameter() { 
  Name = "include_entities", 
  Value = true, 
  Type = ParameterType.GetOrPost });

var response = client.Execute(request);

model.Tweets =
  jsonDeserializer.Deserialize<List<Tweet>>(response);
```
Most parameters are probably self-explanatory. The include_entities one is important for expanding shortened links in tweets, but I'll get to that.
### 3. The View
Now that you have the data, you can render and format it any way you like. For instance like this:
```html
<h1>My Latest Tweets</h1>
<ul>
  @foreach (var tweet in Model.Tweets)
  {
    <li>
      <img src="@tweet.user.profile_image_url" />
      @tweet.text
    </li>
  }
</ul>
```
This should compile and work. There is just one little thing, links in the text are not links:
- Microsoft expands social network http://t.co/AhMIaE6D

### 4. Repairing the links
This is where the url entities come in. If you expand the tweet model like this:
```csharp
public class Tweet
{
  public string created_at { get; set; }
  public string text { get; set; }
  public string GetTextWithLinks()
  {
    var result = text;

    foreach (var entity in entities)
    {
      foreach (var url in entity.urls)
      {
        result = result.Replace(
          url.url,
          string.Format("<a href='{0}'>{1}</a>",
            url.expanded_url,
            url.display_url));
      }
    }

    return result;
  }
  public User user { get; set; }
  public List<Entity> entities { get; set; }
}
```
Then, slightly adapt the view:
```html
<li>
  <img src="@tweet.user.profile_image_url" />
  @Html.Raw(tweet.GetTextWithLinks())
</li>
```
The tweet should now look like this:
- Microsoft expands social network bbc.co.uk/news/technolog…

That's it, you can now style and embed your Twitter feed in any way you like. It should look something like this:

[playground.tkglaser.net/TwitterFeed](http://playground.tkglaser.net/TwitterFeed)

As always, please leave a comment if you found this useful or have improvement suggestions.
