---
title: CSS
date: 20220316
author: Lyz
---

[CSS](https://www.w3schools.com/html/html_css.asp) stands for Cascading Style
Sheets and is used to format the layout of a webpage.

With CSS, you can control the color, font, the size of text, the spacing between
elements, how elements are positioned and laid out, what background images or
background colors are to be used, different displays for different devices and
screen sizes, and much more!

# Using CSS in HTML

CSS can be added to HTML documents in 3 ways:

* *Inline*: by using the style attribute inside HTML elements.
* *Internal*: by using a <style> element in the <head> section.
* *External*: by using a <link> element to link to an external CSS file.

The most common way to add CSS, is to keep the styles in external CSS files.

## Inline CSS

An inline CSS is used to apply a unique style to a single HTML element.

An inline CSS uses the `style` attribute of an HTML element.

The following example sets the text color of the `<h1>` element to blue, and the
text color of the `<p>` element to red:

```html
<h1 style="color:blue;">A Blue Heading</h1>

<p style="color:red;">A red paragraph.</p>
```

## Internal CSS

An internal CSS is used to define a style for a single HTML page.

An internal CSS is defined in the `<head>` section of an HTML page, within
a `<style>` element.

The following example sets the text color of ALL the `<h1>` elements (on that
page) to blue, and the text color of ALL the `<p>` elements to red. In addition,
the page will be displayed with a "powderblue" background color:

```html
<!DOCTYPE html>
<html>
<head>
<style>
body {background-color: powderblue;}
h1   {color: blue;}
p    {color: red;}
</style>
</head>
<body>

<h1>This is a heading</h1>
<p>This is a paragraph.</p>

</body>
</html>
```

## External CSS

An external style sheet is used to define the style for many HTML pages.

To use an external style sheet, add a link to it in the `<head>` section of each HTML page:

```html
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="styles.css">
</head>
<body>

<h1>This is a heading</h1>
<p>This is a paragraph.</p>

</body>
</html>
```

```css
body {
  background-color: powderblue;
}
h1 {
  color: blue;
}
p {
  color: red;
}
```

External style sheets can be referenced with a full URL or with a path relative
to the current web page.

```html
<link rel="stylesheet" href="https://www.w3schools.com/html/styles.css">
```

# CSS Selectors

CSS selectors are used to "find" (or select) the HTML elements you want to style.

## Element selector

The element selector selects HTML elements based on the element name.

Here, all `<p>` elements on the page will be center-aligned, with a red text color:

```css
p {
  text-align: center;
  color: red;
}
```

## ID selector

The id selector uses the `id` attribute of an HTML element to select a specific element.

The `id` of an element is unique within a page, so the id selector is used to select one unique element.

To select an element with a specific id, write a hash (#) character, followed by the id of the element.

The CSS rule below will be applied to the HTML element with `id="para1"`:

```css
#para1 {
  text-align: center;
  color: red;
}
```

## Class selector

The class selector selects HTML elements with a specific `class` attribute.

To select elements with a specific class, write a period (.) character, followed by the class name.

In this example all HTML elements with `class="center"` will be red and center-aligned:

```css
.center {
  text-align: center;
  color: red;
}
```

You can also specify that only specific HTML elements should be affected by a class.

In this example only `<p>` elements with class="center" will be red and center-aligned:

```css
p.center {
  text-align: center;
  color: red;
}
```

## Universal selector

The universal selector (*) selects all HTML elements on the page.

```css
* {
  text-align: center;
  color: blue;
}
```

## Grouping selector

The grouping selector selects all the HTML elements with the same style definitions.

Look at the following CSS code (the h1, h2, and p elements have the same style definitions):

```css
h1, h2, p {
  text-align: center;
  color: red;
}
```

# CSS properties

## [Colors](https://www.w3schools.com/css/css_colors.asp)

Colors are specified using predefined color names, or RGB, HEX, HSL, RGBA, HSLA values.

CSS/HTML support [140 standard color names](https://www.w3schools.com/colors/colors_names.asp).

The different color properties are:

* `color`: set the color of text.

    ```css
    h1 {
      color: blue;
    }
    ```

* `background-color`: set the background color for HTML elements.
* border color:
    ```css
    <h1 style="border:2px solid Tomato;">Hello World</h1>
    ```

Colors can also be specified using RGB values, HEX values, HSL values, RGBA values, and HSLA values

Same as color name "Tomato"

```css
<h1 style="background-color:rgb(255, 99, 71);">...</h1>
<h1 style="background-color:#ff6347;">...</h1>
<h1 style="background-color:hsl(9, 100%, 64%);">...</h1>
```

Same as color name "Tomato", but 50% transparent:

```css
<h1 style="background-color:rgba(255, 99, 71, 0.5);">...</h1>
<h1 style="background-color:hsla(9, 100%, 64%, 0.5);">...</h1>
```

## [Backgrounds](https://www.w3schools.com/css/css_background.asp)

* [Background color](#colors): Use `background-color`.
* [Background image](https://www.w3schools.com/css/css_background_image.asp):
    Use `background-image`. By default, the image is repeated horizontally and
    vertically so it covers the entire element. If you want to repeat only in
    one axis use:

    * `background-repeat: repeat-x`: to repeat horizontally.
    * `background-repeat: repeat-y`: to repeat vertically.
    * `background-repeat: no-repeat`: won't repeat the image.

    ```css
    body {
      background-image: url("gradient_bg.png");
      background-repeat: repeat-x;
    }
    ```

    If you use `no-repeat` maybe you want to set the `background-position`.

    ```css
    body {
      background-image: url("img_tree.png");
      background-repeat: no-repeat;
      background-position: right top;
    }
    ```

    You can also specify if the image `scroll`s or if it's `fixed` with
    `background-attachment`:

    ```css
    body {
      background-image: url("img_tree.png");
      background-repeat: no-repeat;
      background-position: right top;
      background-attachment: scroll;
    }
    ```

    It's also possible to specify all the `background` properties in one single
    property:

    ```css
    body {
      background: #ffffff url("img_tree.png") no-repeat right top;
    }
    ```

## [Borders](https://www.w3schools.com/css/css_border.asp)

The `border-style` property specifies what kind of border to display.

The following values are allowed:

* `dotted`: Defines a dotted border.
* `dashed`: Defines a dashed border.
* `solid`: Defines a solid border.
* `double`: Defines a double border.
* `groove`: Defines a 3D grooved border. The effect depends on the border-color
    value.
* `ridge`: Defines a 3D ridged border. The effect depends on the border-color
    value.
* `inset`: Defines a 3D inset border. The effect depends on the border-color
    value.
* `outset`: Defines a 3D outset border. The effect depends on the border-color
    value.
* `none`: Defines no border.
* `hidden`: Defines a hidden border.

The `border-style` property can have from one to four values (for the top
border, right border, bottom border, and the left border).

The borders have the next attributes:

* `border-width`: Specifies the width of the four borders. Can be set as
    a specific size (in px, pt, cm, em, etc) or by using one of the three
    pre-defined values: `thin`, `medium`, or `thick`. It can have one to four
    values.
* `border-color`: Specifies the [color](#colors).
* `border-radius`: Adds rounded borders to an element.

    ```css
    p {
      border: 2px solid red;
      border-radius: 5px;
    }
    ```

It's also possible to specify all attributes but the radius with the individual
`border` property.

Use `border-left` or `border-bottom` to specify only one side of the border.

## [Margins](https://www.w3schools.com/css/css_margin.asp)

The CSS `margin` properties are used to create space around elements, outside of any defined borders.

You can also use margins for only one side with:

* `margin-top`
* `margin-right`
* `margin-bottom`
* `margin-left`

If you set four values to `margin` it's assumed to be `top`, `right`, `bottom`
and `left`.

All the margin properties can have the following values:

* `auto`: The browser calculates the margin to horizontally center the element
    within its container.
* `length`: Specifies a margin in px, pt, cm, etc..
* `%`: Specifies a margin in % of the width of the containing element.
* `inherit`: Specifies that the margin should be inherited from the parent
    element. This example lets the left margin of the `<p class="ex1">` element be
    inherited from the parent element `<div>`:

    ```css
    div {
      border: 1px solid red;
      margin-left: 100px;
    }

    p.ex1 {
      margin-left: inherit;
    }
    ```


!!! note
        "Negative values are allowed."

Remember that top and bottom margins of elements are sometimes collapsed into
a single margin that is equal to the largest of the two margins.

## [Padding](https://www.w3schools.com/css/css_padding.asp)

The CSS `padding` properties are used to generate space around an element's
content, inside of any defined borders. It behaves similar to
[`margins`](#margins) but it doesn't have an `auto` attribute.

```css
div {
  padding: 25px 50px 75px 100px;
}
```

The CSS `width` property specifies the width of the element's content area. The content area is the portion inside the padding, border, and margin of an element (the box model).

So, if an element has a specified width, the padding added to that element will
be added to the total width of the element. This is often an undesirable result.
To keep the width at 300px, no matter the amount of padding, you can use the
`box-sizing` property. This causes the element to maintain its actual width; if
you increase the padding, the available content space will decrease.

```css
div {
  width: 300px;
  padding: 25px;
  box-sizing: border-box;
}
```

## [Height and width](https://www.w3schools.com/css/css_dimension.asp)

The `height` and `width` properties are used to set the height and width of an
element.

The height and width properties do not include padding, borders, or margins. It
sets the height/width of the area inside the padding, border, and margin of the
element.


The height and width properties may have the following values:

* `auto`: this is default. The browser calculates the height and width.
* `length`: defines the height/width in px, cm etc..
* `%`: defines the height/width in percent of the containing block.
* `initial`: sets the height/width to its default value.
* `inherit`: the height/width will be inherited from its parent value.

```css
div {
  height: 100px;
  width: 500px;
  background-color: powderblue;
}
```

The `max-width` property is used to set the maximum width of an element.

The `max-width` can be specified in length values, like px, cm, etc., or in percent (%) of the containing block, or set to none (this is default. Means that there is no maximum width).

The problem with the `<div>` above occurs when the browser window is smaller than the width of the element (500px). The browser then adds a horizontal scrollbar to the page.

Using `max-width` instead, in this situation, will improve the browser's handling of small windows.

```css
div {
  max-width: 500px;
  height: 100px;
  background-color: powderblue;
}
```

## [Text](https://www.w3schools.com/css/css_text.asp)

CSS has a lot of properties for formatting text.

Styling properties like:

* `color` and `background-color`: Define the [colors](#colors) of the text and
    background.
* `font-family`: Specify the font of a text. It should hold several font names
    as a "fallback" system, to ensure maximum compatibility between
    browsers/operating systems. Start with the font you want, and end with
    a generic family.

    ```css
    .p1 {
      font-family: "Times New Roman", Times, serif;
    }
    ```
* `font-style`: mostly used to specify italic text, value `normal` or `italic`.
* `font-weight`: specifies the weight of a font, one of `normal` or `bold`.
* `font-size`: sets the size of the text. You should not use font size
    adjustments to make paragraphs look like headings, or headings look like
    paragraphs, use the correct html tags.

    Setting the text size with pixels gives you full control over the text size
    `font-size: 40px;`, using `vw` you'll get a responsive font.

* `text-decoration-line`: Add a decoration line to text one or many of
    `overline`, `line-through`, `underline`. Although it's not recommended to
    underline text that is not a link, as this often confuses the reader. The
    line can be enhanced with `text-decoration-color`, `text-decoration-style`
    and `text-decoration-thinkness`. All of which can be merged in the
    `text-decoration` property.

    ```css
    p {
      text-decoration: underline red double 5px;
    }
    ```

    To remove the underline of links use `text-decoration: none`.

* `text-indent`: Specify the indentation of the first line of a text
* `letter-spacing`: Specify the space between the characters in a text.
* `word-spacing`: Specify the space between the words in a text.
* `line-height`: Specify the space between lines.
* `white-space`: Specifies how white-space inside an element is handled. This
    example demonstrates how to disable text wrapping inside an element:

    ```css
    p {
      white-space: nowrap;
    }
    ```


Alignment properties:

* `text-align`: Sets the horizontal alignment of a text. A text can be `left` or
    `right` aligned, `centered`, or `justified`.
* `text-align-last`: Specifies how to align the last line of a text. With the
    same values as `text-align`.
* `vertical-align`: Sets the vertical alignment of an element. The [values can
    be](https://www.w3schools.com/css/tryit.asp?filename=trycss_vertical-align): `baseline`, `text-top`, `text-bottom`, `sub` and `super`.

Text can be transformed with the `text-transform` property with the values
`uppercase`, `lowercase` and `capitalize`.



# [Comments](https://www.w3schools.com/css/css_comments.asp)

Comments are used to explain the code, and may help when you edit the source code at a later date.

Comments are ignored by browsers.

A CSS comment is placed inside the `<style>` element, and starts with `/*` and
ends with `*/`:

```css
/* This is a single-line comment */
p {
  color: red;
}
```


# CSS Layouts

## [Flexbox layout](https://css-tricks.com/snippets/css/a-guide-to-flexbox/#flexbox-background)

The Flexbox Layout aims at providing a more efficient way to lay out, align and
distribute space among items in a container, even when their size is unknown
and/or dynamic.

The main idea behind the flex layout is to give the container the ability to
alter its items’ width/height (and order) to best fill the available space
(mostly to accommodate to all kind of display devices and screen sizes). A flex
container expands items to fill available free space or shrinks them to prevent
overflow.

Flexbox layout is most appropriate to the components of an application, and
small-scale layouts, while the Grid layout is intended for larger scale
layouts.

You can play around in the [Flexbox playground](https://flexbox.netlify.app/).
To see how to use it read the [Vuetify Flexbox section](vuetify.md#flex).

# References

* [W3 Tutorial](https://www.w3schools.com/css/default.asp)
* [W3 CSS templates](https://www.w3schools.com/css/css_rwd_templates.asp)
