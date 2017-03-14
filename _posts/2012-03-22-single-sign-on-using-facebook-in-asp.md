---
layout: post
title:  "Single Sign On using Facebook in ASP MVC 3"
date:   2012-03-22
permalink: /single-sign-on-using-facebook-in-asp/
---
As promised in [one of my last posts](http://www.tkglaser.net/2012/02/single-sign-on-using-google-in-asp-mvc.html), 
here is a quick how-to for Single Sign On in MVC 3 using [DotNetOpenAuth](http://www.dotnetopenauth.net/). Let's dive right in.

### 1. Install DotNetOpenAuth

First, you need DotNetOpenAuth. The easiest way to to install it via the NuGet package manager.

### 2. Create your Facebook App

Go to [developers.facebook.com](http://developers.facebook.com/) to create your very own Facebook Web App. 
This is a simple registration process and free for everybody. Ensure, you configure your Facebook App thusly:

![FacebookAuth01](/assets/images/FacebookAuth01.png)

This is the address, Facebook will accept authentication requests from. Make sure, the 
port number matches the port, the Visual Studio debug server runs on. Needless to say that you have to change this, when your application moves to its proper URL.

What you also get is an App ID and an App Secret. We will need this later.

### 3. Client Boiler Plate

Next, you need to create a authentication client. I lifted most of the code for this from the 
[DotNetOpenAuth example code](https://github.com/aarnott/dotnetopenid):
```csharp
public class TokenManager : IClientAuthorizationTracker
{
  public IAuthorizationState GetAuthorizationState(
    Uri callbackUrl, string clientState)
  {
    return new AuthorizationState
    {
      Callback = callbackUrl,
    };
  }
}

public class FacebookClient : WebServerClient
{
  private static readonly 
  AuthorizationServerDescription FacebookDescription 
    = new AuthorizationServerDescription
  {
    TokenEndpoint 
      = new Uri("https://graph.facebook.com/oauth/access_token"),
    AuthorizationEndpoint 
      = new Uri("https://graph.facebook.com/oauth/authorize"),
  };

  /// <summary>
  /// Initializes a new instance of 
  /// the <see cref="FacebookClient"/> class.
  /// </summary>
  public FacebookClient()
    : base(FacebookDescription)
  {
    this.AuthorizationTracker = new TokenManager();
  }
}

[DataContract]
public class FacebookGraph
{
  private static DataContractJsonSerializer jsonSerializer 
    = new DataContractJsonSerializer(typeof(FacebookGraph));

  [DataMember(Name = "id")]
  public long Id { get; set; }

  [DataMember(Name = "name")]
  public string Name { get; set; }

  [DataMember(Name = "first_name")]
  public string FirstName { get; set; }

  [DataMember(Name = "last_name")]
  public string LastName { get; set; }

  [DataMember(Name = "link")]
  public Uri Link { get; set; }

  [DataMember(Name = "birthday")]
  public string Birthday { get; set; }

  [DataMember(Name = "email")]
  public string Email { get; set; }

  public static FacebookGraph Deserialize(string json)
  {
    if (string.IsNullOrEmpty(json))
    {
      throw new ArgumentNullException("json");
    }
    return Deserialize(new MemoryStream(Encoding.UTF8.GetBytes(json)));
  }

  public static FacebookGraph Deserialize(Stream jsonStream)
  {
    if (jsonStream == null)
    {
      throw new ArgumentNullException("jsonStream");
    }
    return (FacebookGraph)jsonSerializer.ReadObject(jsonStream);
  }
}
```
The FacebookGraph class is probably the most interesting one, as it will hold the user's data after the successful authentication request. I've added an Email property to the example implementation. Getting the user's email address is something we need to specifically ask permission for in the authentication request.

### 4. The Authentication Request

First, we need an instance of the client class, we created earlier. This is best done within the scope of our MVC Account Controller:
```csharp
private static readonly FacebookClient client = new FacebookClient
{
  ClientIdentifier = "<--my client id-->",
  ClientCredentialApplicator = 
    ClientCredentialApplicator
      .PostParameter("<--my client secret-->")
};
```
You need to fill in the specific IDs of your Facebook Web App here.

The actual authentication request is done in a single MVC action:
```scharp
public ActionResult LogFace()
{
  IAuthorizationState authorization = client.ProcessUserAuthorization();
  if (authorization == null) 
  {
    // Kick off authorization request
    client.RequestUserAuthorization();
  } 
  else 
  {
    var request = WebRequest.Create(
      "https://graph.facebook.com/me?access_token=" 
      + Uri.EscapeDataString(authorization.AccessToken));
    using (var response = request.GetResponse()) 
    {
      using (var responseStream = response.GetResponseStream()) 
      {
        var graph = FacebookGraph.Deserialize(responseStream);

        string myUserName = graph.Name;
        string myEmail = graph.Email;
        // use the data in the graph object to authorise the user
      }
    }
  }
  return RedirectToAction("Index");
}
```
After the successful authentication Facebook calls back on the same URL it was called from, so our Action gets invoked again. This time, the authorization object will not be null, so the else-block is executed.

After we have the populated graph object (so called because of the Facebook Graph API), we have everything we need to store the user's details and authenticate the user against our site.

That's it, you should now have a working Single Sign On MVC Action to authenticate against Facebook. 

Please leave a comment if you find a mistake or have a question. Also, if you find this helpful, feel free to give it a "kick".
