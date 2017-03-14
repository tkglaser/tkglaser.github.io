Imagine, your boss comes in with this requirement:

*This web application you just finished, can you do another one that does (mostly) the same but has a completely different look and slightly modified flow?*

This happened to me. Needless to say, the last thing, you want to do is copy and paste the whole project. This would mean twice the work for any future changes.

Luckily, there is a way to minimise code duplication in such a situation. Without any change to the controller, you can have your application deliver different views based on a configuration key in web.config. In the rest of the article I will refer to the different look and feel as "brand".

Here is how to achieve this:

### 0. Planning
One way to organise the views in a folder structure.

The views under Brands/MyBrandA.com contain the views specific to BrandA.com, the views under Brands/MyBrandB.com are specific to BrandB.com and the View folder in the root contains the Views shared by both brands.

Importantly, every Views folder needs a Web.Config, otherwise the Razor engine throws errors. The easiest way is to copy the Web.configs from the original views folder.

### 1. Create a custom View Engine
The next step is to tell MVC, where to look for your Views. The way to do this is to create your own ViewEngine by overriding RazorViewEngine:
```csharp
public class BrandViewEngine : RazorViewEngine
{
  public BrandViewEngine(string s)
  {
    var specificViews = new string[]
    {
      "~/Brands/" + s + "/Views/{1}/{0}.cshtml",
      "~/Brands/" + s + "/Views/Shared/{1}/{0}.cshtml",
    };

    var specificAreaViews = new string[]
    {
      "~/Brands/" + s + "/Areas/{2}/Views/{1}/{0}.cshtml",
      "~/Brands/" + s + "/Areas/{2}/Shared/Views/{1}/{0}.cshtml"
    };

    AreaMasterLocationFormats =
      specificAreaViews.Union(AreaMasterLocationFormats).ToArray();
    AreaPartialViewLocationFormats =
      specificAreaViews.Union(AreaPartialViewLocationFormats).ToArray();
    AreaViewLocationFormats =
      specificAreaViews.Union(AreaViewLocationFormats).ToArray();
    MasterLocationFormats =
      specificViews.Union(MasterLocationFormats).ToArray();
    ViewLocationFormats =
      specificViews.Union(ViewLocationFormats).ToArray();
    PartialViewLocationFormats =
      specificViews.Union(PartialViewLocationFormats).ToArray();
  }
}
```
The *Formats variables are folder lists where MVC looks for Views. You simply need to put our branded paths in front of the default paths, so the ViewEngine will look in our branded folders first.

### 2. Activating the ViewEngine

In the Global.asax.cs file, the `Application_Start()` method needs to register our new ViewEngine.
```csharp
protected void Application_Start()
{
  ViewEngines.Engines.Clear();

  string myBrandString =
    ConfigurationManager.AppSettings["Brand"].ToString();

  ViewEngines.Engines.Add(new BrandViewEngine(myBrandString));

  AreaRegistration.RegisterAllAreas();
  RegisterGlobalFilters(GlobalFilters.Filters);
  RegisterRoutes(RouteTable.Routes);
}
```
Now to switch between brands all that is needed is a key in your Web.config:
```html
<add key="Brand" value="MyBrandA.com"/>
```
### 3. Using the branded layout file
If a particular View is not found in the brand folders, the engine will fall back on the Views in the default folder. However, you would probably want to display the branded layout file even for non-branded Views. To do this, the _ViewStart.cshtml (the one in the default folder, not in the branded folders) needs to work out, which layout file to use. This can be done like so:
```csharp
@{
  var brand = System.Configuration
    .ConfigurationManager.AppSettings["Brand"].ToString();
  Layout = "~/Brands/" + brand + "/Views/Shared/_Layout.cshtml";
}
```
That's it. You now have completely separate sets of HTML markups for your sites. You can switch between them using a configuration setting and no change to the controller logic is required.

*Please leave a comment if you find a mistake or have a suggestion.*

Thanks,
Thomas