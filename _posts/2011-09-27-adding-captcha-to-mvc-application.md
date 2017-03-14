---
layout: post
title:  "Adding a Captcha to an MVC application"
date:   2011-09-27
permalink: /adding-captcha-to-mvc-application/
---
It took me ages to find and integrate this, so maybe someone will find this useful.

The task is to add a captcha to the user registration screen of an MVC application. But I didn't want to include any 3rd party libraries, rather use an existing web service.

After some research, I found [OpenCaptcha.com](http://www.opencaptcha.com/) which seems to provide just this. So here is a guide on how to plug this into your MVC application.

The starting point is a MVC 3 app with forms based authentication.

Amend your AccountController.Register method:

```csharp
public ActionResult Register()
{
  ViewBag.CaptchaGuid = Guid.NewGuid().ToString("N");
  return View();
}
```

This provides a random string which is then used to request the captcha image from the site.

Next, amend your Register.cshtml with the following lines.

```html
@Html.ValidationMessageFor(m => m.ConfirmPassword)
</div>

<div class="editor-label">
  Captcha
</div>
<div class="editor-field">
  <img src=@Url.Content("http://www.opencaptcha.com/img/"
    + ViewBag.CaptchaGuid + ".jpgx") alt="Captcha" />
</div>

<div class="editor-label">
  Please enter the string above.
</div>
<div class="editor-field">
  @Html.TextBox("Captcha")
</div>

<p>
  <input type="submit" value="Register" />
</p>
```
Now, the Captcha should be visible along with an entry box for the user to submit the answer. Since we also need the Guid, let's transport it through a hidden field. Add this to Register.cshtml:

```csharp
@Html.Hidden("CaptchaGuid", ViewData["CaptchaGuid"])
```

Lastly, we need to verify, that the user's string matches the one in the picture. To do this, we simply construct a URL to OpenCaptcha which answers the question by returning "success" or "fail". Amend your AccountController.Register (the POST version) like this:

```csharp
//
// POST: /Account/Register
[HttpPost]
public ActionResult Register(RegisterModel model)
{
  string CaptchaGuid = Request.Form["CaptchaGuid"];
  string Captcha = Request.Form["Captcha"];

  WebClient wc = new WebClient();
  string CaptchaResponse = wc.DownloadString(
    "http://www.opencaptcha.com/validate.php?img="
      + CaptchaGuid + "&ans=" + Captcha);

  if (!"success".Equals(CaptchaResponse))
  {
    ModelState.AddModelError("",
      "Captchas didn't match, please try again!");
  }
  
  if (ModelState.IsValid)
  {
    // Attempt to register the user
```

That's it!

_Note: It is probably a good idea to wrap the OpenCaptcha requests into a 
try-catch in case, the service is down. I left that out for readability._
