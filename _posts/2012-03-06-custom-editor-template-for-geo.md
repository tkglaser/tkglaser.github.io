---
layout: post
title:  "Custom Editor Template for Geo Coordinates in MVC 3 using Google Maps"
date:   2012-03-06
permalink: /custom-editor-template-for-geo/
---
I was recently given the task to make stored geo 
location data editable. So ideally I would want 
to have an Edit view where I can just move a pin 
around on a map. Something similar has been done 
in the 
[nerddinner demo application](http://www.nerddinner.com/). 
The developers have of course used Microsoft's 
[Bing maps](http://www.microsoft.com/maps/developers/web.aspx).
Nothing wrong with that, but I personally prefer 
[Google Maps](http://code.google.com/apis/maps/index.html).

At the end of this tutorial, you will have an 
Edit / Create View that looks like this:

![Location Editor](/assets/blog/images/LocationEditor.png)

You can move the pin on the map which will update or create the location of the model, once you press the Create button.

Let's get started.

### 1. The Model

We want to create a very basic model called Place with a name and a pair of map coordinates.
```csharp
public class Place
{
    public Place()
    {
        Pos = new GeoCoords() { Latitude = 0, Longitude = 0 };
    }

    public string Name { get; set; }
    public GeoCoords Pos { get; set; }
}

public class GeoCoords
{
    public double Latitude { get; set; }
    public double Longitude { get; set; }
}
```
It is important, that the GeoCoords are in a separate class. I'll explain shortly.

### 2. The View

To create the View, use the standard MVC scaffolding. Unfortunately, the Pos attribute is just omitted because the scaffolder doesn't know what to do with custom classes. So you need to add the standard edit code for the Pos attribute:
```htlm
<div class="editor-label">
    @Html.LabelFor(model => model.Pos)
</div>
<div class="editor-field">
    @Html.EditorFor(model => model.Pos)
    @Html.ValidationMessageFor(model => model.Pos)
</div>
```
This is the same code, MVC would generate for a simple 
type attribute. This makes for very clean code within 
the View, as you wouldn't be able to tell that the Pos 
attribute needs any special treatment. You've probably 
guessed by now, that we will use a 
[Custom Editor Template](http://bradwilson.typepad.com/blog/2009/10/aspnet-mvc-2-templates-part-1-introduction.html). 
This tells MVC how to render an editor for an 
attribute of type GeoCoords.

For this, you need to create a new partial View 
called GeoCoords.cshtml 
in `Views\Shared\EditorTemplates`. 
Create the EditorTemplates folder if it doesn't exist.

![Location Editor Solution Tree](/assets/blog/images/LocationEditorSolutionTree.png)

Then edit the code in GeoCoords to look like this:
```javascript
@model GeoCoordsTest.Models.GeoCoords

@{
    string name = ViewData.TemplateInfo.HtmlFieldPrefix;
    string id = name.Replace(".", "_");
    string lat = id + "_Latitude";
    string lon = id + "_Longitude";
}

@Html.HiddenFor(model => model.Latitude)
@Html.HiddenFor(model => model.Longitude)

<script type="text/javascript" src="https://www.google.com/jsapi?autoload={'modules':[{name:'maps',version:3,other_params:'sensor=false'}]}"></script>

<script type="text/javascript">
    var marker;
    
    function init() {
        var mapDiv = document.getElementById('canvas');
        var map = new google.maps.Map(mapDiv, {
            center: new google.maps.LatLng(
                @Model.Latitude, @Model.Longitude),
            zoom: 8, 
            mapTypeId: google.maps.MapTypeId.ROADMAP
        });
        var pos = new google.maps.LatLng(
            @Model.Latitude, @Model.Longitude);
                
        marker = new google.maps.Marker({
            map: map,
            position: pos,
            title: "",
            draggable: true
        });
                
        google.maps.event.addListener(marker, 'drag', function() {
            var pos = marker.getPosition();
            $("#@lat").val(pos.lat());
            $("#@lon").val(pos.lng());
        });
    }

    google.maps.event.addDomListener(window, 'load', init);    
</script>

<div id="canvas" style="height:300px;width:300px;"></div>
```
Let's step through the code. First, two hidden fields are created.
```csharp
@Html.HiddenFor(model => model.Latitude)
@Html.HiddenFor(model => model.Longitude)
```
These fields will hold the values of Latitude and Longitude. We will use JavaScript to update the values as the user drags the map pin around. In order to manipulate these hidden fields, we will need to know their ID tag. This part 
```csharp
@{
    string name = ViewData.TemplateInfo.HtmlFieldPrefix;
    string id = name.Replace(".", "_");
    string lat = id + "_Latitude";
    string lon = id + "_Longitude";
}
```
creates to server-side variables, lat and lon which hold the ID tags of our hidden fields. MVC follows the convention of using the name of the calling model attribute, in our case "Pos" combined with the internal attribute names using an underscore. In our case, this yields "Pos_Latitude" and "Pos_Longitude". The name of the calling model attribute can be obtained by using ViewData.TemplateInfo.HtmlFieldPrefix. After the Google Maps script reference, the map is created. 
```javascript
<script type="text/javascript">
    var marker;
    
    function init() {
        var mapDiv = document.getElementById('canvas');
        var map = new google.maps.Map(mapDiv, {
            center: new google.maps.LatLng(
                @Model.Latitude, @Model.Longitude),
            zoom: 8, 
            mapTypeId: google.maps.MapTypeId.ROADMAP
        });
        var pos = new google.maps.LatLng(
            @Model.Latitude, @Model.Longitude);
                
        marker = new google.maps.Marker({
            map: map,
            position: pos,
            title: "",
            draggable: true
        });
```
The map is centered on the given map coordinates. Also, a draggable marker is created. The interesting bit is where the draggable marker is connected to the hidden fields: 
```javascript
google.maps.event.addListener(marker, 'drag', function() {
    var pos = marker.getPosition();
    $("#@lat").val(pos.lat());
    $("#@lon").val(pos.lng());
});
```
Whenever the marker fires the "drag" event, the hidden fields are identified using jQuery an the server-side variables we created earlier. Then their value is set to the current marker position. This means, that when the user clicks the submit button in the original form, the hidden fields will hold the last value of the draggable marker and will be posted back to the server. 

### 3. The Controller

There is nothing special here. Using the Custom Template will update the model fields allowing the Controller to save the Latitude and Longitude values to the database. 
```csharp
public ActionResult CreatePlace()
{
    return View(new Place());
}

[HttpPost]
public ActionResult CreatePlace(Place model)
{
    if (ModelState.IsValid)
    {
        // save the place
    }
    return View(model);
}
```

### 4. Result

You should now have a reusable editor template that displays an embedded Google Map whenever a GeoCoords object is edited in a View.
