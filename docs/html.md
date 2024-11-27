---
title: HTML
date: 20220316
author: Lyz
---

[HTML](https://www.w3schools.com/html/default.asp) is the standard markup
language for Web pages. With HTML you can create your own Website.

# [Document structure](https://www.w3schools.com/html/html_basic.asp)

All HTML documents must start with a document type declaration: `<!DOCTYPE
html>`.

The HTML document itself begins with `<html>` and ends with `</html>`.

The visible part of the HTML document is between `<body>` and `</body>`.

```html
<!DOCTYPE html>
<html>
<body>

<h1>My First Heading</h1>
<p>My first paragraph.</p>

</body>
</html>
```

# HTML elements

* Headings: `<h1>` to `<h6>`
* Paragraphs: `<p>This is a paragraph.</p>`.
* [Links](#links): `<a href="https://www.w3schools.com">This is a link</a>`
* [Images](#images): `<img src="w3schools.jpg" alt="W3Schools.com" width="104" height="142">`
* Line breaks: `<br>`, `<hr>`
* Comments: `<!-- Write your comments here -->`
* Code: `<code> x = 5</code>`

## [Links](https://www.w3schools.com/html/html_links.asp)

HTML links are hyperlinks. You can click on a link and jump to another document.

The HTML `<a>` tag defines a hyperlink. It has the following syntax:

```html
<a href="url">link text</a>
```

The link text is the part that will be visible to the reader.

Link attributes:

* `href`: indicates the link's destination.
* `target`: specifies where to open the linked document. It can have one of the following values:
    * `_self`: (Default) Opens the document in the same window/tab as it was
        clicked.
    * `_blank`: Opens the document in a new window or tab.
    * `_parent`: Opens the document in the parent frame.
    * `_top`: Opens the document in the full body of the window.

## [Images](https://www.w3schools.com/html/html_images.asp)

The HTML `<img>` tag is used to embed an image in a web page.

Images are not technically inserted into a web page; images are linked to web
pages. The `<img>` tag creates a holding space for the referenced image.

The `<img>` tag is empty, it contains attributes only, and does not have a closing tag.

The `<img>` tag has two required attributes:

* `src`: Specifies the path to the image.
* `alt`: Specifies an alternate text for the image shown if the user for some
    reason cannot view it.

```html
<img src="url" alt="alternatetext">
```

Other `<img>` attributes are:

* `<style>`: specify the width and height of an image.

    ```html
    <img src="img_1.jpg" alt="img_1" style="width:500px;height:600px;">
    ```

    Even though you could use `width` and `height`, if you use the `style`
    attribute you prevent style sheets to change the size of images.

* `<float>`: let the image float to the right or to the left of a text.

    ```html
    <p><img src="smiley.gif" alt="Smiley face" style="float:right;width:42px;height:42px;">
    The image will float to the right of the text.</p>

    <p><img src="smiley.gif" alt="Smiley face" style="float:left;width:42px;height:42px;">
    The image will float to the left of the text.</p>
    ```


If you want to use an image as a link use:

```html
 <a href="default.asp">
  <img src="smiley.gif" alt="HTML tutorial" style="width:42px;height:42px;">
</a>
```

## [Lists](https://www.w3schools.com/html/html_lists.asp)

HTML lists allow web developers to group a set of related items in lists.

* Unordered lists: starts with the `<ul>` tag. Each list item starts with the
    `<li>` tag. The list items will be marked with bullets (small black circles)
    by default:

    ```html
    <ul>
      <li>Coffee</li>
      <li>Tea</li>
      <li>Milk</li>
    </ul>
    ```
* Ordered list: Starts with the `<ol>` tag. Each list item starts with the
    `<li>` tag. The list items will be marked with numbers by default:

    ```html
    <ol>
      <li>Coffee</li>
      <li>Tea</li>
      <li>Milk</li>
    </ol>
    ```

## [Tables](https://www.w3schools.com/html/html_tables.asp)

HTML tables allow web developers to arrange data into rows and columns.

```html
 <table>
  <tr>
    <th>Company</th>
    <th>Contact</th>
    <th>Country</th>
  </tr>
  <tr>
    <td>Alfreds Futterkiste</td>
    <td>Maria Anders</td>
    <td>Germany</td>
  </tr>
  <tr>
    <td>Centro comercial Moctezuma</td>
    <td>Francisco Chang</td>
    <td>Mexico</td>
  </tr>
</table>
```

Where:

* `<th>`: Defines the table headers
* `<tr>`: Defines the table rows
* `<td>`: Defines the table cells


## [Blocks](https://www.w3schools.com/html/html_blocks.asp)

A block-level element always starts on a new line, and the browsers
automatically add some space (a margin) before and after the element.

A block-level element always takes up the full width available (stretches out to
the left and right as far as it can).

An inline element does not start on a new line and only takes up as much width
as necessary.

* `<p>`: defines a paragraph in an HTML document.

* `<div>`: defines a division or a section in an HTML document. It has
    no required attributes, but style, class and id are common. When used together
    with CSS, the `<div>` element can be used to style blocks of content:

    ```html
    <div style="background-color:black;color:white;padding:20px;">
      <h2>London</h2>
      <p>London is the capital city of England. It is the most populous city in the United Kingdom, with a metropolitan area of over 13 million inhabitants.</p>
    </div>
    ```
* `<span>`: Is an inline container used to mark up a part of a text, or a part
    of a document.

    The `<span>` element has no required attributes, but style, class and id are
    common. When used together with CSS, the `<span>` element can be used to style
    parts of the text:

    ```html
    <p>My mother has <span style="color:blue;font-weight:bold">blue</span> eyes and my father has <span style="color:darkolivegreen;font-weight:bold">dark green</span> eyes.</p>
    ```

## [Classes](https://www.w3schools.com/html/html_classes.asp)

The `class` attribute is often used to point to a class name in a style sheet.
It can also be used by a JavaScript to access and manipulate elements with the
specific class name.

In the following example we have three `<div>` elements with a class attribute
with the value of "city". All of the three `<div>` elements will be styled
equally according to the `.city` style definition in the head section:

```html
 <!DOCTYPE html>
<html>
<head>
<style>
.city {
  background-color: tomato;
  color: white;
  border: 2px solid black;
  margin: 20px;
  padding: 20px;
}
</style>
</head>
<body>

<div class="city">
  <h2>London</h2>
  <p>London is the capital of England.</p>
</div>

<div class="city">
  <h2>Paris</h2>
  <p>Paris is the capital of France.</p>
</div>

<div class="city">
  <h2>Tokyo</h2>
  <p>Tokyo is the capital of Japan.</p>
</div>

</body>
</html>
```

HTML elements can belong to more than one class. To define multiple classes,
separate the class names with a space, e.g. `<div class="city main">`. The element
will be styled according to all the classes specified.

## [Javascript](https://www.w3schools.com/html/html_scripts.asp)

The HTML `<script>` tag is used to define a client-side script (JavaScript).

The `<script>` element either contains script statements, or it points to an
external script file through the src attribute.

Common uses for JavaScript are image manipulation, form validation, and dynamic
changes of content.

This JavaScript example writes "Hello JavaScript!" into an HTML element with
`id="demo"`:

```js
<script>
document.getElementById("demo").innerHTML = "Hello JavaScript!";
</script>
```

The HTML `<noscript>` tag defines an alternate content to be displayed to users
that have disabled scripts in their browser or have a browser that doesn't
support scripts:

```html
<script>
document.getElementById("demo").innerHTML = "Hello JavaScript!";
</script>
<noscript>Sorry, your browser does not support JavaScript!</noscript>
```

## [Head](https://www.w3schools.com/html/html_head.asp)

The `<head>` element is a container for metadata (data about data) and is placed
between the `<html>` tag and the `<body>` tag.

HTML metadata is data about the HTML document. Metadata is not displayed.

Metadata typically define the document title, character set, styles, scripts, and other meta information.

It contains the next sections:

* `<title>`: defines the title of the document. The title must be text-only, and
    it is used to:

    * define the title in the browser toolbar
    * provide a title for the page when it is added to favorites
    * display a title for the page in search engine-results

    ```html
    <title>A Meaningful Page Title</title>
    ```


* `<style>`: define style information for a single HTML page.

    ```html
    <style>
      body {background-color: powderblue;}
      h1 {color: red;}
      p {color: blue;}
    </style>
    ```

* `<link>`: defines the relationship between the current document and an external resource.

    ```html
     <link rel="stylesheet" href="mystyle.css">
    ```

* `<meta>`: specify the character set, page description, keywords, author of the
    document, and viewport settings. It won't be displayed on the page, but are
    used by browsers (how to display content or reload page), by search engines
    (keywords), and other web services. For example:

    * Define the character set used: `<meta charset="UTF-8">`.
    * Define keywords for search engines: `<meta name="keywords" content="HTML,
        CSS, JavaScript">`.
    * Define a description of your web page: `<meta name="description"
        content="Free Web tutorials">`.
    * Define the author of a page: `<meta name="author" content="John Doe">`.
    * Refresh document every 30 seconds: `<meta http-equiv="refresh" content="30">`.
    * [Setting the viewport](#setting-the-viewport).

* `<script>`: define client-side JavaScripts.

    ```html
    <script>
        function myFunction() {
          document.getElementById("demo").innerHTML = "Hello JavaScript!";
        }
    </script>
    ```

* `<base>`: specifies the base URL and/or target for all relative URLs in
    a page. The `<base>` tag must have either an href or a target attribute
    present, or both.

    ```html
    <base href="https://www.w3schools.com/" target="_blank">
    ```

## [Favicon](https://www.w3schools.com/html/html_favicon.asp)

A favicon image is displayed to the left of the page title in the browser tab.

To add a favicon to your website, either save your favicon image to the root
directory of your webserver, or create a folder in the root directory called
images, and save your favicon image in this folder. A common name for a favicon
image is "favicon.ico".

Next, add a `<link>` element to your "index.html" file, after the `<title>` element, like this:

```html
<!DOCTYPE html>
<html>
<head>
  <title>My Page Title</title>
  <link rel="icon" type="image/x-icon" href="/images/favicon.ico">
</head>
<body>
```

# [Styles](https://www.w3schools.com/html/html_styles.asp)

The HTML `style` attribute is used to add styles to an element, such as color, font, size, and more.

```html
<tagname style="property:value;">
```

The property is a [CSS](css.md) property. The value is a CSS value.

## [Formatting](https://www.w3schools.com/html/html_formatting.asp)

Formatting elements were designed to display special types of text:

* `<b>`: Bold text.
* `<strong>`: Important text.
* `<i>`: Italic text.
* `<em>`: Emphasized text.
* `<mark>`: Marked text.
* `<small>`: Smaller text.
* `<del>`: Deleted text.
* `<ins>`: Inserted text.
* `<sub>`: Subscript text.
* `<sup>`: Superscript text.

# [Layout](https://www.w3schools.com/html/html_layout.asp)

Websites often display content in multiple columns (like a magazine or
a newspaper).

HTML has several semantic elements that define the different parts of a web page:
HTML5 Semantic Elements

* `<header>`: Defines a header for a document or a section.
* `<nav>`: Defines a set of navigation links.
* `<section>`: Defines a section in a document.
* `<article>`: Defines an independent, self-contained content.
* `<aside>`: Defines content aside from the content (like a sidebar).
* `<footer>`: Defines a footer for a document or a section.
* `<details>`: Defines additional details that the user can open and close on
    demand.
* `<summary>`: Defines a heading for the <details> element.

## Layout elements

### Section

A section is a thematic grouping of content, typically with a heading.

Examples of where a `<section>` element can be used:

* Chapters
* Introduction
* News items
* Contact information

```html
 <section>
<h1>WWF</h1>
<p>The World Wide Fund for Nature (WWF) is an international organization working on issues regarding the conservation, research and restoration of the environment, formerly named the World Wildlife Fund. WWF was founded in 1961.</p>
</section>

<section>
<h1>WWF's Panda symbol</h1>
<p>The Panda has become the symbol of WWF. The well-known panda logo of WWF originated from a panda named Chi Chi that was transferred from the Beijing Zoo to the London Zoo in the same year of the establishment of WWF.</p>
</section>
```

### article

The `<article>` element specifies independent, self-contained content.

An article should make sense on its own, and it should be possible to distribute
it independently from the rest of the web site.

Examples of where the `<article>` element can be used:

* Forum posts
* Blog posts
* User comments
* Product cards
* Newspaper articles

```html
<article>
<h2>Google Chrome</h2>
<p>Google Chrome is a web browser developed by Google, released in 2008. Chrome is the world's most popular web browser today!</p>
</article>

<article>
<h2>Mozilla Firefox</h2>
<p>Mozilla Firefox is an open-source web browser developed by Mozilla. Firefox has been the second most popular web browser since January, 2018.</p>
</article>

<article>
<h2>Microsoft Edge</h2>
<p>Microsoft Edge is a web browser developed by Microsoft, released in 2015. Microsoft Edge replaced Internet Explorer.</p>
</article>
```

### header

The `<header>` element represents a container for introductory content or a set
of navigational links.

A `<header>` element typically contains:

* one or more heading elements (`<h1>` - `<h6>`)
* logo or icon
* authorship information

```html
 <article>
  <header>
    <h1>What Does WWF Do?</h1>
    <p>WWF's mission:</p>
  </header>
  <p>WWF's mission is to stop the degradation of our planet's natural environment,
  and build a future in which humans live in harmony with nature.</p>
</article>
```

### footer

The `<footer>` element defines a footer for a document or section.

A `<footer>` element typically contains:

* authorship information
* copyright information
* contact information
* sitemap
* back to top links
* related documents

```html
 <footer>
  <p>Author: Hege Refsnes</p>
  <p><a href="mailto:hege@example.com">hege@example.com</a></p>
</footer>
```

## Layout Techniques

There are four different techniques to create multicolumn layouts. Each
technique has its pros and cons:

* CSS framework
* CSS float property
* CSS flexbox
* CSS grid

### Frameworks

If you want to create your layout fast, you can use a CSS framework, like
[W3.CSS](https://www.w3schools.com/w3css/default.asp) or
[Bootstrap](https://www.w3schools.com/bootstrap/default.asp).

### Float layout

It is common to do entire web layouts using the CSS `float` property. Float is
easy to learn - you just need to remember how the `float` and `clear` properties
work.

Disadvantages: Floating elements are tied to the document flow, which may harm the flexibility.

### Flexbox layout

Use of flexbox ensures that elements behave predictably when the page layout must accommodate different screen sizes and different display devices.

### Grid layout

The CSS Grid Layout Module offers a grid-based layout system, with rows and
columns, making it easier to design web pages without having to use floats and
positioning.

# [Responsive](https://www.w3schools.com/html/html_responsive.asp)

Responsive web design is about creating web pages that look good on all
devices.

A responsive web design will automatically adjust for different screen sizes and
viewports.

## Setting the viewport

To create a responsive website, add the following `<meta>` tag to all your web pages:

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```
This gives the browser instructions on how to control the page's dimensions and
scaling.

The `width=device-width` part sets the width of the page to follow the
screen-width of the device (which will vary depending on the device).

The `initial-scale=1.0` part sets the initial zoom level when the page
is first loaded by the browser.

## Responsive images

Using the `max-width` property: If the CSS `max-width` property is set to
`100%`, the image will be responsive and scale up and down, but never scale up
to be larger than its original size:

```html
<img src="img_girl.jpg" style="max-width:100%;height:auto;">
```

## Responsive text size

The text size can be set with a "vw" unit, which means the "viewport width".

That way the text size will follow the size of the browser window:

```html
<h1 style="font-size:10vw">Hello World</h1>
```

Viewport is the browser window size. `1vw = 1%` of viewport width. If the viewport
is 50cm wide, 1vw is 0.5cm.


## Media queries

In addition to resize text and images, it is also common to use media queries in responsive web pages.

With media queries you can define completely different styles for different browser sizes.

The next example will make the three div elements display horizontally on large
screens and stacked vertically on small screens:

```html
 <style>
.left, .right {
  float: left;
  width: 20%; /* The width is 20%, by default */
}

.main {
  float: left;
  width: 60%; /* The width is 60%, by default */
}

/* Use a media query to add a breakpoint at 800px: */
@media screen and (max-width: 800px) {
  .left, .main, .right {
    width: 100%; /* The width is 100%, when the viewport is 800px or smaller */
  }
}
</style>
```

# [Code Style](https://www.w3schools.com/html/html5_syntax.asp)

* Always declare the document type as the first line in your document.
    ```html
    <!DOCTYPE html>
    ```
* Use lowercase element names:
    ```html
    <body>
    <p>This is a paragraph.</p>
    </body>
    ```
* Close all HTML elements.
* Use lowercase attribute names
* Always quote attribute values
* Always Specify alt, width, and height for Images.
* Don't add spaces between equal signs: `<link rel="stylesheet"
    href="styles.css">`
* Avoid Long Code Lines
* Do not add blank lines, spaces, or indentations without a reason.
* Use two spaces for indentation instead of tab
* Never Skip the `<title>` Element
* Always add the `<html>`, `<head>` and `<body>` tags.
* Always include the `lang` attribute inside the `<html>` tag

    ```html
    <!DOCTYPE html>
    <html lang="en-us">
    </html>
    ```
* Set the character encoding: `<meta charset="UTF-8">`
* [Set the viewport](#setting-the-viewport).

# Tips

## HTML beautifier

If you encounter html code that it's not well indented  you can use [html
beautify](https://htmlbeautify.com).

# References

* [W3 tutorial](https://www.w3schools.com/html/default.asp)
