---
layout: post
title:  "Phone number validation in MVC 3"
date:   2012-02-14
permalink: /phone-number-validation-in-mvc-3/
redirect_from: /2012/02/phone-number-validation-in-mvc-3.html
---
If your web application relies on properly entered phone numbers, this might be interesting. 
This post shows step by step how to use Google's [libphonenumber](http://code.google.com/p/libphonenumber/) to validate 
phone numbers in your MVC 3 application.

Google's [libphonenumber](http://code.google.com/p/libphonenumber/) is an open 
source Java library which is used on [Android 4.0 (ICS)](http://www.android.com/about/ice-cream-sandwich/) mobile phones. There is a C# port of this library which can be made to work with MVC.

This is what you will have at the end of this tutorial: http://tkglaser.apphb.com/PhoneValidation

Here are the steps:

### 1. Install the NuGet package

In your MVC 3 project in VS2010, just right-click on the projects references folder and choose "Add Library Package Reference...". Select "Online" and search for the libphonenumber-csharp package and install it.

![Nuget](/assets/images/nuget.png)

### 2. Create a Model, a View and a Controller

You know the drill. Let's start by creating a rudimentary model:
```csharp
public class DetailsModel
{
  public string Phone { get; set; }
  public string PhoneNumberFormatted { get; set; }
}
```
We also need a View. Mine is derived from the Create-Template and looks like this:
```html
@model PhoneTest.Models.DetailsModel
@{
  ViewBag.Title = "EnterDetails";
}

<h2>EnterDetails/h2
@using (Html.BeginForm()) {
  @Html.ValidationSummary(true)
  
  <fieldset>
    <legend>DetailsModel</legend> 
    <div class="editor-label">
      @Html.LabelFor(model => model.Phone)
    </div>
    <div class="editor-field">
      @Html.EditorFor(model => model.Phone)
      @Html.ValidationMessageFor(model => model.Phone)
    </div>
    <h2>
      @Html.DisplayFor(model => model.PhoneNumberFormatted)
    </h2>

    <p>
      <input type="submit" value="Create" />
    </p>
  </fieldset>
}

<div>
@Html.ActionLink("Back to List", "Index")
</div>
```
Notice, that we've changed the code around the PhoneNumberFormatted field to be display only. This field is only used for returning the formatted phone number.

Finally, the controller logic:
```csharp
using PhoneNumbers;

public ActionResult EnterDetails()
{
  return View(new DetailsModel());
}

[HttpPost]
public ActionResult EnterDetails(DetailsModel model)
{
  try
  {
    PhoneNumberUtil phoneUtil = PhoneNumberUtil.GetInstance();
    PhoneNumber n = phoneUtil.Parse(model.Phone, "GB");

    model.PhoneNumberFormatted =
      phoneUtil.Format(n, PhoneNumberFormat.INTERNATIONAL);
  }
  catch (Exception e)
  {
    ModelState.AddModelError("Phone", e.Message);
  }
  return View(model);
}
```
The interesting part here is the Post method. It uses libphonenumber to parse the entered string assuming a UK country code as default if none is given. Then the number is formatted into the international standard format and returned as string.
Any parsing error will throw an exception with a relevant error message which is added to the ModelState dictionary.

### 3. The fun part

This gives us a nice little toy, we can test the validation with.

I've uploaded a little test app to appharbor, so feel free to go there to have a play: http://tkglaser.apphb.com/PhoneValidation

For an invalid phone number, it should look something like this:

![Phonefail](/assets/images/phonefail.png)

A valid phone number should create this output:

![Phonesuccess](/assets/images/phonesuccess.png)

Notice, how the default country has been added.

That's it. You can now ensure, that the user is entering a (syntactically) correct phone number.

*As always, please leave a comment if you find a mistake or have a suggestion.*

Related links:

- [Have a play with the little test app I've done](http://tkglaser.apphb.com/PhoneValidation)
- [Adding libphonenumber validation using a ValidationAttribute (appharbor blog)](http://blog.appharbor.com/2012/02/03/net-phone-number-validation-with-google-libphonenumber)
