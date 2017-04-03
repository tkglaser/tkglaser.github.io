---
layout: post
title:  "Google reCAPTCHA in ASP.NET MVC 3 using the Razor engine"
date:   2012-02-01
permalink: /google-recaptcha-in-aspnet-mvc-3-using/
redirect_from: /2012/02/google-recaptcha-in-aspnet-mvc-3-using.html
---
After my last post I found that OpenCaptcha.com can be unreliable which leads to the captcha image not being displayed. 

So I started looking at Google's reCAPTCHA. Unlike OpenCaptcha, it needs a local library but in exchange for that you get a really slick looking captcha. 

Every guide I found on getting this to work with MVC was outdated or needlessly complicated. So here is the simplest way I could find to add a captcha to the account registration page of your MVC 3 Razor application. 

First, go to [the reCAPTCHA site](http://www.google.com/recaptcha) and get your own personal public and private key pair. 

In your MVC3 application, use the NuGet package manager to install the "reCAPTCHA plugin for .NET" package (Tools->Library Package Manager->Manage NuGet Packages). 

Then merge the following settings into your Web.config: 
```html
<namespaces>
  <add namespace="Recaptcha" />
</namespaces>

<appsettings>
  <add key="RecaptchaPrivateKey" value="...your private key..." />
  <add key="RecaptchaPublicKey" value="...your public key..." />
</appsettings>
```
Next, go to your Register.cshtml. Add a reference to the Recaptcha assembly 
```
@using Recaptcha;
```
and then place the actual reCAPTCHA input field somewhere on your Register view 
```html
<div class="editor-label">
  Are you a human?
</div>
<div class="editor-field">
  @Html.Raw(Html.GenerateCaptcha("captcha", "clean"))
  @Html.ValidationMessage("captcha")
</div>
```
The `Html.Raw` wrapper is neccessary because otherwise, Razor would escape the HTML tags, which dumps the JavaScript onto your page as text rather than executing it. The "clean" parameter is the theme of the captcha, [here are some other themes and customisation options](http://code.google.com/apis/recaptcha/docs/customization.html). 

Now, your account controller needs code to perform the validation. Add a reference to the Recaptcha assembly in AccountController.cs: 
```csharp
using Recaptcha;
```
Modify the AccountController.Register method (the [Post] version) as follows: 
```csharp
//
// POST: /Account/Register
[HttpPost, RecaptchaControlMvc.CaptchaValidator]
public ActionResult Register(RegisterModel model, 
  bool captchaValid, string captchaErrorMessage)
{
  if (!captchaValid)
    ModelState.AddModelError("captcha", captchaErrorMessage);

  if (ModelState.IsValid)
  {
```
It should work now, the Register Method should only succeed when the captcha has been entered correctly. Hope, it helps someone!
