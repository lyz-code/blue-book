---
title: Javascript
date: 20200402
author: Lyz
---

JavaScript is a multi-paradigm, dynamic language with types and operators,
standard built-in objects, and methods. Its syntax is based on the Java and
C languages — many structures from those languages apply to JavaScript as well.
JavaScript supports object-oriented programming with object prototypes, instead
of classes. JavaScript also supports functional programming — because they are
objects, functions may be stored in variables and passed around like any other
object.

# The basics

## Javascript types

JavaScript's types are:

* Number
* String
* Boolean
* Symbol (new in ES2015)
* Object
    * Function
    * Array
    * Date
    * RegExp
* null
* undefined

## Numbers

Numbers in JavaScript are *double-precision 64-bit format IEEE 754 values*.
There's no such thing as an integer in JavaScript, so you have to be a little
careful with your arithmetic.

The standard arithmetic operators are supported, including addition,
subtraction, modulus (or remainder) arithmetic, and so forth. Use the Math
object when in need of more advanced mathematical functions and constants.

It supports `NaN` for *Not a Number* which can be tested with `isNaN()` and
`Infinity` which can be tested with `isFinite()`.

JavaScript distinguishes between `null` and `undefined`, which indicates an
uninitialized variable.

### Convert a string to an integer

Use the built-in `parseInt()` function. It takes the base for the conversion
as an optional but recommended second argument.

```javascript
parseInt('123', 10); // 123
parseInt('010', 10); // 10
```

### Convert a string into a float

Use the built-in `parseFloat()` function. Unlike `parseInt()` , parseFloat()
always uses base 10.

## Strings

Strings in JavaScript are sequences of Unicode characters (UTF-16) which support
several
[methods](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String#Methods).

### Find the length of a string

```javascript
'hello'.length; // 5
```

## Booleans

JavaScript has a boolean type, with possible values `true` and `false`. Any
value will be converted when necessary to a boolean according to the following
rules:

* `false`, `0`, empty strings (`""`), `NaN`, `null`, and `undefined` all become
    `false`.
* All other values become `true`.

Boolean operations are also supported:

* and: `&&`
* or: `||`
* not: `!`

## Variables

New variables in JavaScript are declared using one of three keywords: `let`,
`const`, or `var`.

* `let` is used to declare block-level variables.

    ```javascript
    let a;
    let name = 'Simon';
    ```

    The declared variable is available from the block it is enclosed in.

    ```javascript
    // myLetVariable is *not* visible out here

    for (let myLetVariable = 0; myLetVariable < 5; myLetVariable++) {
      // myLetVariable is only visible in here
    }

    // myLetVariable is *not* visible out here
    ```

* `const` is used to declare variables whose values are never intended to
    change. The variable is available from the block it is declared in.

    ```javascript
    const Pi = 3.14; // variable Pi is set
    Pi = 1; // will throw an error because you cannot change a constant variable.
    ```
* `var` is the most common declarative keyword. It does not have the
    restrictions that the other two keywords have. If you declare a variable
    without assigning any value to it, its type is undefined.

    ```javascript
    // myVarVariable *is* visible out here

    for (var myVarVariable = 0; myVarVariable < 5; myVarVariable++) {
      // myVarVariable is visible to the whole function
    }

    // myVarVariable *is* visible out here
    ```

## Operators

Numeric operators:

* `+`, both for numbers and strings.
* `-`
* `*`
* `/`
* `%`, which is the remainder operator.
* `=`, to assign values.
* `+=`
* `-=`
* `++`
* `--`

Comparison operators:

* `<`
* `>`
* `<=`
* `>=`
* `==`, performs type coercion if you give it different types, with sometimes
    interesting results

    ```javascript
    123 == '123'; // true
    1 == true; // true
    ```

    To avoid type coercion, use the triple-equals operator:

    ```javascript
    123 === '123'; // false
    1 === true;    // false
    ```
* `!=` and `!==`.

## Control structures

### If conditionals

```javascript
var name = 'kittens';
if (name == 'puppies') {
  name += ' woof';
} else if (name == 'kittens') {
  name += ' meow';
} else {
  name += '!';
}
name == 'kittens meow';
```

You can use the [conditional ternary
operator](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Conditional_Operator)
instead.

It's defined by a condition followed by a question mark `?`, then an
expression to execute if the condition is truthy followed by a colon `:`, and
finally the expression to execute if the condition is falsy.

`condition ? exprIfTrue : exprIfFalse`

```javascript
function getFee(isMember) {
  return (isMember ? '$2.00' : '$10.00');
}

console.log(getFee(true));
// expected output: "$2.00"

console.log(getFee(false));
// expected output: "$10.00"

console.log(getFee(null));
// expected output: "$10.00"
```

### Switch cases

```javascript
switch (action) {
  case 'draw':
    drawIt();
    break;
  case 'eat':
    eatIt();
    break;
  default:
    doNothing();
}
```
If you don't add a `break` statement, execution will "fall through" to the next
level.  The default clause is optional

### While loops

```javascript
while (true) {
  // an infinite loop!
}

var input;
do {
  input = get_input();
} while (inputIsNotValid(input));
```

### For loops

It has several types of for loops:

* Classic `for`:

    ```javascript
    for (var i = 0; i < 5; i++) {
      // Will execute 5 times
    }
    ```

* `for`...`of`.
    ```javascript
    for (let value of array) {
      // do something with value
    }
    ```

* `for`...`in`.
    ```javascript
    for (let property in object) {
      // do something with object property
    }
    ```

## Objects

Objects can be thought of as simple collections of name-value pairs, such as
Python dictionaries.

```javascript
var obj2 = {};
var obj = {
  name: 'Carrot',
  for: 'Max', // 'for' is a reserved word, use '_for' instead.
  details: {
    color: 'orange',
    size: 12
  }
};
```

Attribute access can be chained together:

```javascript
obj.details.color; // orange
obj['details']['size']; // 12
```

The following example creates an object prototype(`Person`) and an instance of
that prototype(`you`).

```javascript
function Person(name, age) {
  this.name = name;
  this.age = age;
}

// Define an object
var you = new Person('You', 24);
// We are creating a new person named "You" aged 24.
```

### [The `this` keyword](https://www.w3schools.com/js/js_this.asp)

The `this` keyword refers to different objects depending on how it is used:

* In an object method, `this` refers to the object.
    ```javascript
    const person = {
      firstName: "John",
      lastName : "Doe",
      id       : 5566,
      fullName : function() {
        return this.firstName + " " + this.lastName;
      }
    };
    ```

* Alone, `this` refers to the global object. In a browser window the global
    object is `[object Window]`.

    ```javascript
    let x = this;
    ```

* In a function, `this` refers to the global object.
* In a function, in strict mode, `this` is undefined.
* In an event, `this` refers to the element that received the event.

    ```javascript
    <button onclick="this.style.display='none'">
      Click to Remove Me!
    </button>
    ```

* Methods like `call()`, `apply()`, and `bind()` can refer this to any object.

## Arrays

Arrays can be thought of as Python lists. They work very much like regular
objects but with [their own
properties and methods](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array),
such as `length`, which returns one more than the highest index in the array.

```javascript
var a = new Array();
a[0] = 'dog';
a[1] = 'cat';
a[2] = 'hen';
// or

var a = ['dog', 'cat', 'hen'];

a.length; // 3
```

### Iterate over the values of an array

```javascript
for (const currentValue of a) {
  // Do something with currentValue
}

// or

for (var i = 0; i < a.length; i++) {
  // Do something with a[i]
}
```

### Append an item to an array

If you want to alter the original array use `push()` although, it's better to
use `concat()` as it doesn't mutate the original array.

```javascript
a.concat(item);
```

### Apply a function to the elements of an array

```javascript
const numbers = [1, 2, 3];
const doubled = numbers.map(x => x * 2); // [2, 4, 6]
```

### [Filter the contents of an array](https://www.w3schools.com/jsref/jsref_filter.asp)

The `filter()` method creates a new array filled with elements that pass a test
provided by a function.

The `filter()` method does not execute the function for empty elements.

The `filter()` method does not change the original array.

For example:

```javascript
const ages = [32, 33, 16, 40];
const result = ages.filter(checkAdult);

function checkAdult(age) {
  return age >= 18;
}
```

### [Array useful methods](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array#instance_methods)

TBC

## Functions

```javascript
function add(x, y) {
  var total = x + y;
  return total;
}
```

Functions have an `arguments` array holding all of the values passed to the
function.

To save typing and avoid [the confusing behavior of
this](https://yehudakatz.com/2011/08/11/understanding-javascript-function-invocation-and-this/),it
is recommended to use the [arrow
function](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions)
syntax for event handlers.

So instead of

```javascript
<button className="square" onClick={function() { alert('click'); }}>
```

It's better to use

```javascript
<button className="square" onClick={() => alert('click')}>
```
Notice how with `onClick={() => alert('click')}`, the function is passed as the
`onClick` prop.

Another example, from this code:

```javascript
hello = function() {
  return "Hello World!";
}
```

You get:

```javascript
hello = () => "Hello World!";
```

If you have parameters, you pass them inside the parentheses:

```javascript
hello = (val) => "Hello " + val;
```

### Define variable number of arguments

```javascript
function avg(...args) {
  var sum = 0;
  for (let value of args) {
    sum += value;
  }
  return sum / args.length;
}

avg(2, 3, 4, 5); // 3.5
```

### [Function callbacks](https://www.w3schools.com/js/js_callback.asp)

A callback is a function passed as an argument to another function.

Using a callback, you could call the calculator function `myCalculator` with a callback, and let the calculator function run the callback after the calculation is finished:

```javascript
function myDisplayer(some) {
  document.getElementById("demo").innerHTML = some;
}

function myCalculator(num1, num2, myCallback) {
  let sum = num1 + num2;
  myCallback(sum);
}

myCalculator(5, 5, myDisplayer);
```

## Custom objects

JavaScript is a prototype-based language that contains no class statement.
Instead, JavaScript uses functions as classes.

```javascript
function makePerson(first, last) {
  return {
    first: first,
    last: last,
    fullName: function() {
      return this.first + ' ' + this.last;
    },
    fullNameReversed: function() {
      return this.last + ', ' + this.first;
    }
  };
}
var s = makePerson('Simon', 'Willison');
s.fullName(); // "Simon Willison"
s.fullNameReversed(); // "Willison, Simon"
```

Used inside a function, `this` refers to the current object. If you called it
using dot notation or bracket notation on an object, that object becomes `this`.
If dot notation wasn't used for the call, `this` refers to the global object.

Which makes `this` is a frequent cause of mistakes. For example:

```javascript
var s = makePerson('Simon', 'Willison');
var fullName = s.fullName;
fullName(); // undefined undefined
```

When calling `fullName()` alone, without using `s.fullName()`, this is bound to
the global object. Since there are no global variables called `first` or `last`
we get `undefined` for each one.

### Constructor functions

We can take advantage of the `this` keyword to improve the `makePerson` function:

```javascript
function Person(first, last) {
  this.first = first;
  this.last = last;
  this.fullName = function() {
    return this.first + ' ' + this.last;
  };
  this.fullNameReversed = function() {
    return this.last + ', ' + this.first;
  };
}
var s = new Person('Simon', 'Willison');
```

`new` is strongly related to `this`. It creates a brand new empty object, and
then calls the function specified, with `this` set to that new object. Notice
though that the function specified with this does not return a value but merely
modifies the `this` object. It's `new` that returns the `this` object to the
calling site. Functions that are designed to be called by `new` are called
constructor functions. Common practice is to capitalize these functions as
a reminder to call them with `new`.

Every time we create a person object we are creating two brand new function
objects within it, to avoid it, use shared functions.

```javascript
function Person(first, last) {
  this.first = first;
  this.last = last;
}
Person.prototype.fullName = function() {
  return this.first + ' ' + this.last;
};
Person.prototype.fullNameReversed = function() {
  return this.last + ', ' + this.first;
};
```
`Person.prototype` is an object shared by all instances of `Person`. any time
you attempt to access a property of `Person` that isn't set, JavaScript will
check `Person.prototype` to see if that property exists there instead. As
a result, anything assigned to `Person.prototype` becomes available to all
instances of that constructor via the `this` object. So it's easy to add extra
methods to existing objects at runtime:

```javascript
var s = new Person('Simon', 'Willison');
s.firstNameCaps(); // TypeError on line 1: s.firstNameCaps is not a function

Person.prototype.firstNameCaps = function() {
  return this.first.toUpperCase();
};
s.firstNameCaps(); // "SIMON"
```

## Split code for readability

To split a line into several, parentheses may be used to avoid the insertion of
semicolons.

```javascript
  renderSquare(i) {
    return (
      <Square
        value={this.state.squares[i]}
        onClick={() => this.handleClick(i)}
      />
    );
  }
```

## [Coalescent operator](https://www.joshwcomeau.com/operator-lookup?match=nullish-coalescing)

Is similar to the Logical `OR` operator (`||`), except instead of relying on
truthy/falsy values, it relies on "nullish" values (there are only 2 nullish
values, `null` and `undefined`).

This means it's safer to use when you treat falsy values like `0` as valid.

Similar to Logical `OR`, it functions as a control-flow operator; it evaluates to the first not-nullish value.

It was introduced in Chrome 80 / Firefox 72 / Safari 13.1. It has no IE support.

```js
console.log(4 ?? 5);
// 4, since neither value is nullish
console.log(null ?? 10);
// 10, since 'null' is nullish
console.log(undefined ?? 0);
// 0, since 'undefined' is nullish
// Here's a case where it differs from
// Logical OR (||):
console.log(0 ?? 5); // 0
console.log(0 || 5); // 5
```

# [Interacting with HTML](https://www.w3schools.com/js/default.asp)

You can find HTML elements with the next `document` properties:

| Property                       | Description                                                        |
| ---                            | ---                                                                |
| `document.anchors`             | Returns all `<a>` elements that have a name attribute              |
| `document.baseURI`             | Returns the absolute base URI of the document                      |
| `document.body`                | Returns the `<body>` element                                       |
| `document.cookie`              | Returns the document's cookie                                      |
| `document.doctype`             | Returns the document's doctype                                     |
| `document.documentElement`     | Returns the `<html>` element                                       |
| `document.documentMode`        | Returns the mode used by the browser                               |
| `document.documentURI`         | Returns the URI of the document                                    |
| `document.domain`              | Returns the domain name of the document server                     |
| `document.embeds`              | Returns all `<embed>` elements                                     |
| `document.forms`               | Returns all `<form>` elements                                      |
| `document.head`                | Returns the `<head>` element                                       |
| `document.images`              | Returns all `<img>` elements                                       |
| `document.implementation`      | Returns the DOM implementation                                     |
| `document.inputEncoding`       | Returns the document's encoding (character set)                    |
| `document.lastModified`        | Returns the date and time the document was updated                 |
| `document.links`               | Returns all `<area>` and `<a>` elements that have a href attribute |
| `document.readyState`          | Returns the (loading) status of the document                       |
| `document.referrer`            | Returns the URI of the referrer (the linking document)             |
| `document.scripts`             | Returns all `<script>` elements                                    |
| `document.strictErrorChecking` | Returns if error checking is enforced                              |
| `document.title`               | Returns the `<title>` element                                      |
| `document.URL`                 | Returns the complete URL of the document                           |


## [How to add JavaScript to HTML](https://www.w3schools.com/js/js_whereto.asp)

In HTML, JavaScript code is inserted between `<script>` and `</script>` tags.

```html
 <script>
document.getElementById("demo").innerHTML = "My First JavaScript";
</script>
```

That will be run as the page is loaded.

Scripts can be placed in the `<body>`, or in the `<head>` section of an HTML
page, or in both.

!!! note
        "Placing scripts at the bottom of the `<body>` element improves the display speed, because script interpretation slows down the display."

A JavaScript `function` is a block of JavaScript code, that can be executed when "called" for.

For example, a function can be called when an event occurs, like when the user clicks a button.

### External JavaScript

Scripts can also be placed in external files:

!!! note "File: myScript.js"
    ```javascript
    function myFunction() {
      document.getElementById("demo").innerHTML = "Paragraph changed.";
    }
    ```

External scripts are practical when the same code is used in many different web pages.

To use an external script, put the name of the script file in the `src` (source)
attribute of a `<script>` tag:

```html
<script src="myScript.js"></script>
```

Placing scripts in external files has some advantages:

* It separates HTML and code.
* It makes HTML and JavaScript easier to read and maintain.
* Cached JavaScript files can speed up page loads.

## HTML content

One of many JavaScript HTML methods is `getElementById()`.

The example below "finds" an HTML element (with `id="demo"`), and changes the
element content (`innerHTML`) to `"Hello JavaScript"`:

```js
document.getElementById("demo").innerHTML = "Hello JavaScript";
```

It will transform:

```html
<p id="demo">JavaScript can change HTML content.</p>
```

Into:

```html
<p id="demo">Hello JavaScript</p>
```

You can also use `getElementsByTagName` or `getElementsByClassName`. Or if
you want to find all HTML elements that match a specified CSS selector (id,
class names, types, attributes, values of attributes, etc), use the
`querySelectorAll()` method.

This example returns a list of all `<p>` elements with `class="intro"`.

```javascript
const x = document.querySelectorAll("p.intro");
```

## HTML attributes

JavaScript can also change HTML attribute values. In this example JavaScript
changes the value of the `src` (source) attribute of an `<img>` tag:

```html
<button onclick="document.getElementById('myImage').src='pic_bulbon.gif'">Turn on the light</button>

<img id="myImage" src="pic_bulboff.gif" style="width:100px">

<button onclick="document.getElementById('myImage').src='pic_bulboff.gif'">Turn off the light</button>
```

Other attribute methods are:

| Method                            | Description                       |
| ---                               | ---                               |
| `document.createElement(element)` | Create an HTML element            |
| `document.removeChild(element)`   | Remove an HTML element            |
| `document.appendChild(element)`   | Add an HTML element               |
| `document.replaceChild(new, old)` | Replace an HTML element           |

## CSS

Changing the style of an HTML element, is a variant of changing an HTML attribute:

```js
document.getElementById("demo").style.fontSize = "35px";
```

## Hiding or showing HTML elements

Hiding HTML elements can be done by changing the display style:

```js
document.getElementById("demo").style.display = "none";
```

Showing hidden HTML elements can also be done by changing the display style:

```js
document.getElementById("demo").style.display = "block";
```

## [Displaying data](https://www.w3schools.com/js/js_output.asp)


JavaScript can "display" data in different ways:

* Writing into an HTML element, using `innerHTML`.
* Writing into the HTML output using `document.write()`.
    ```html
    <h1>My First Web Page</h1>
    <p>My first paragraph.</p>

    <script>
    document.write(5 + 6);
    </script>
    ```

    Using `document.write()` after an HTML document is loaded, will delete all existing HTML.

* Writing into an alert box, using `window.alert()`.
* Writing into the browser console, using `console.log()`. Useful for debugging.

## [Events](https://www.w3schools.com/js/js_events.asp)

An HTML event can be something the browser does, or something a user does.

Here are some examples of HTML events:

* An HTML web page has finished loading
* An HTML input field was changed
* An HTML button was clicked

Often, when events happen, you may want to do something.

JavaScript lets you execute code when events are detected.

HTML allows event handler attributes, with JavaScript code, to be added to HTML
elements.

```html
<element event='some JavaScript'>
```

In the following example, an `onclick` attribute (with code), is added to
a `<button>` element:

```html
<button onclick="document.getElementById('demo').innerHTML = Date()">The time is?</button>
```

In the example above, the JavaScript code changes the content of the element
with `id="demo"`.

In the next example, the code changes the content of its own element (using
`this.innerHTML`):

```html
<button onclick="this.innerHTML = Date()">The time is?</button>
```

JavaScript code is often several lines long. It is more common to see event attributes calling functions:

```html
<button onclick="displayDate()">The time is?</button>
```

### Common HTML Events

Here is a list of some common HTML events:

| Event       | Description                                        |
| ---         | ---                                                |
| onchange    | An HTML element has been changed                   |
| onclick     | The user clicks an HTML element                    |
| onmouseover | The user moves the mouse over an HTML element      |
| onmouseout  | The user moves the mouse away from an HTML element |
| onmousedown | The user is pressing the click button              |
| onmouseup | The user is releasing the click button              |
| onkeydown   | The user pushes a keyboard key                     |
| onload      | The browser has finished loading the page          |

## Event handlers

Event handlers can be used to handle and verify user input, user actions, and
browser actions:

* Things that should be done every time a page loads
* Things that should be done when the page is closed
* Action that should be performed when a user clicks a button
* Content that should be verified when a user inputs data

Many different methods can be used to let JavaScript work with events:

* HTML event attributes can execute JavaScript code directly
* HTML event attributes can call JavaScript functions
* You can assign your own event handler functions to HTML elements
* You can prevent events from being sent or being handled

# [JSON support](https://www.w3schools.com/js/js_json.asp)

JSON is a format for storing and transporting data.

A common use of JSON is to read data from a web server, and display the data in
a web page.

For simplicity, this can be demonstrated using a string as input.

First, create a JavaScript string containing JSON syntax:

```javascript
let text = '{ "employees" : [' +
'{ "firstName":"John" , "lastName":"Doe" },' +
'{ "firstName":"Anna" , "lastName":"Smith" },' +
'{ "firstName":"Peter" , "lastName":"Jones" } ]}';
```

Then, use the JavaScript built-in function `JSON.parse()` to convert the string
into a JavaScript object:

```javascript
const obj = JSON.parse(text);
```

Finally, use the new JavaScript object in your page:

```html
<p id="demo"></p>

<script>
document.getElementById("demo").innerHTML =
obj.employees[1].firstName + " " + obj.employees[1].lastName;
</script>
```

# Async JavaScript
## [Timing events](https://www.w3schools.com/js/js_timing.asp)

The `window` object allows execution of code at specified time intervals.

These time intervals are called timing events.

The two key methods to use with JavaScript are:

* `setTimeout(function, milliseconds)`: Executes a function, after waiting
    a specified number of `milliseconds`.
* `setInterval(function, milliseconds)`: Same as `setTimeout()`, but repeats the
    execution of the function continuously.

For example to click a button. Wait 3 seconds, and the page will alert "Hello":

```html
 <button onclick="setTimeout(myFunction, 3000)">Try it</button>

<script>
function myFunction() {
  alert('Hello');
}
</script>
```

The `window.clearTimeout(timeoutVariable)` method stops the execution of the function specified in
`setTimeout()`.

```javascript
myVar = setTimeout(function, milliseconds);
clearTimeout(myVar);
```

To stop a `setInterval` use the `clearInterval` method.

## [Promises](https://www.w3schools.com/js/js_promise.asp)

A JavaScript Promise object contains both the producing code and calls to the
consuming code, where:

* "Producing code" is code that can take some time
* "Consuming code" is code that must wait for the result

The syntax of a Promise is kind of difficult to understand, but bear with me:

```javascript
let myPromise = new Promise(function(myResolve, myReject) {
// "Producing Code" (May take some time)

  myResolve(); // when successful
  myReject();  // when error
});

// "Consuming Code" (Must wait for a fulfilled Promise)
myPromise.then(
  function(value) { /* code if successful */ },
  function(error) { /* code if some error */ }
);
```

When the producing code obtains the result, it should call one of the two callbacks:

* *Success* then calls `myResolve(result value)`
* *Error* then calls `myReject(error object)`

For example:

```javascript
function myDisplayer(some) {
  document.getElementById("demo").innerHTML = some;
}

let myPromise = new Promise(function(myResolve, myReject) {
  let x = 0;

// The producing code (this may take some time)

  if (x == 0) {
    myResolve("OK");
  } else {
    myReject("Error");
  }
});

myPromise.then(
  function(value) {myDisplayer(value);},
  function(error) {myDisplayer(error);}
);
```

### Promise object properties

A JavaScript Promise object can be:

* Pending
* Fulfilled
* Rejected

The `Promise` object supports two properties: `state` and `result`, which can't
be accessed directly.

* While a `Promise` object is `pending` (working), the result is `undefined`.
* When a `Promise` object is `fulfilled`, the result is a `value`.
* When a `Promise` object is `rejected`, the result is an `error` object.

## Waiting for a timeout example

Example Using Callback:

```javascript
setTimeout(function() { myFunction("I love You !!!"); }, 3000);

function myFunction(value) {
  document.getElementById("demo").innerHTML = value;
}
```

Example Using Promise

```javascript
let myPromise = new Promise(function(myResolve, myReject) {
  setTimeout(function() { myResolve("I love You !!"); }, 3000);
});

myPromise.then(function(value) {
  document.getElementById("demo").innerHTML = value;
});
```

## [Async/Await](https://www.w3schools.com/js/js_async.asp)

`async` and `await` make promises easier to write.

`async` makes a function return a `Promise`, while `await` makes a function wait
for a `Promise`.

### Async syntax

For example

```javascript
async function myFunction() {
  return "Hello";
}
```

Is the same as:

```javascript
function myFunction() {
  return Promise.resolve("Hello");
}
```

Here is how to use the Promise:

```javascript
myFunction().then(
  function(value) {myDisplayer(value);},
  function(error) {myDisplayer(error);}
);
```

If you only expect a normal value, skip the `function(error)...` line.

### Await syntax

The keyword `await` before a function makes the function wait for a promise:

```javascript
let value = await promise;
```

The `await` keyword can only be used inside an async function.

For example the next code will update the content of `demo`  with `I love you
!!` instantly:

```javascript
async function myDisplay() {
  let myPromise = new Promise(function(resolve, reject) {
    resolve("I love You !!");
  });
  document.getElementById("demo").innerHTML = await myPromise;
}

myDisplay();
```

But it could have a timeout

```javascript
async function myDisplay() {
  let myPromise = new Promise(function(resolve) {
    setTimeout(function() {resolve("I love You !!");}, 3000);
  });
  document.getElementById("demo").innerHTML = await myPromise;
}

myDisplay();
```

# [Cookies](https://www.w3schools.com/js/js_cookies.asp)

Cookies are data, stored in small text files, on your computer. They hold a very
small amount of data at a maximum capacity of 4KB.

When a web server has sent a web page to a browser, the connection is shut down,
and the server forgets everything about the user.

Cookies were invented to solve the problem "how to remember information about the user":

* When a user visits a web page, his/her name can be stored in a cookie.
* Next time the user visits the page, the cookie "remembers" his/her name.

There are two types of cookies: persistent cookies and session cookies. Session
cookies do not contain an expiration date. Instead, they are stored only as long
as the browser or tab is open. As soon as the browser is closed, they are
permanently lost. Persistent cookies *do* have an expiration date. These cookies
are stored on the user’s disk until the expiration date and then permanently
deleted.

!!! note
        "Think if for your case ithe's better to use [Web storage](#web-storage) instead"

## Setting a cookie

Cookies are saved in name-value pairs like:

```javascript
username = John Doe
```

When a browser requests a web page from a server, cookies belonging to the page
are added to the request. This way the server gets the necessary data to
"remember" information about users.

JavaScript can create, read, and delete cookies with the `document.cookie` property.

With JavaScript, a cookie can be created like this:

```javascript
document.cookie = "username=John Doe";
```

You can also add an expiry date (in UTC time). By default, the cookie is deleted
when the browser is closed:

```javascript
document.cookie = "username=John Doe; expires=Thu, 18 Dec 2013 12:00:00 UTC";
```

With a path parameter, you can tell the browser what path the cookie belongs to.
By default, the cookie belongs to the current page.

```javascript
document.cookie = "username=John Doe; expires=Thu, 18 Dec 2013 12:00:00 UTC; path=/";
```

## Reading a Cookie

With JavaScript, cookies can be read like this:

```javascript
let x = document.cookie;
```

`document.cookie` will return all cookies in one string much like:
`cookie1=value; cookie2=value; cookie3=value;`. It looks like a normal text
string. But it is not.

If you want to find the value of one specified cookie, you must write
a JavaScript function that searches for the cookie value in the cookie string.

## Change a Cookie with JavaScript

With JavaScript, you can change a cookie the same way as you create it:

```javascript
document.cookie = "username=John Smith; expires=Thu, 18 Dec 2013 12:00:00 UTC; path=/";
```

The old cookie is overwritten.

## Delete a Cookie with JavaScript

Just set the expires parameter to a past date:

```javascript
document.cookie = "username=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
```

## Javascript cookie example

In the example to follow, we will create a cookie that stores the name of
a visitor.

The first time a visitor arrives to the web page, he/she will be asked to fill
in his/her name. The name is then stored in a cookie.

The next time the visitor arrives at the same page, he/she will get a welcome
message.

### Function to set a cookie value

```javascript
function setCookie(cname, cvalue, exdays) {
  const d = new Date();
  d.setTime(d.getTime() + (exdays*24*60*60*1000));
  let expires = "expires="+ d.toUTCString();
  document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}
```

## Function to get a cookie value

```javascript
function getCookie(cname) {
  let name = cname + "=";
  let decodedCookie = decodeURIComponent(document.cookie);
  let ca = decodedCookie.split(';');
  for(let i = 0; i <ca.length; i++) {
    let c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}
```

Where:

* The function take the cookiename as parameter `cname`.
* Creates a variable `name` with the text to search for `cname + "="`.
* Decodes the cookie string, to handle cookies with special characters like
    `$`.
* Split `document.cookie` on semicolons into an array called `ca`.
* Loop through the `ca` array and read out each value `c`.
* If the cookie is found `c.indexOf(name) == 0`, return the value of the cookie `c.substring(name.length, c.length`.
* If the cookie is not found, return `""`.

## Function to check a cookie value

If the cookie is set it will display a greeting.

If the cookie is not set, it will display a prompt box, asking for the name of
the user, and stores the username cookie for 365 days, by calling the
`setCookie` function:

```javascript
function checkCookie() {
  let username = getCookie("username");
  if (username != "") {
   alert("Welcome again " + username);
  } else {
    username = prompt("Please enter your name:", "");
    if (username != "" && username != null) {
      setCookie("username", username, 365);
    }
  }
}
```

The html code of the page would be:

```html
<body onload="checkCookie()"></body>
```

# [Web Storage](https://www.w3schools.com/js/js_api_web_storage.asp)

The Web Storage API is a simple syntax for storing and retrieving data in the
browser. There are two storage objects `localStorage` and `sessionStorage`.

```javascript
localStorage.setItem("name", "John Doe");
localStorage.getItem("name");
```

The storage object properties and methods are:

| Property/Method           | Description                                                   |
| ---                       | ---                                                           |
| `key(n)`                  | Returns the name of the nth key in the storage                |
| `length`                  | Returns the number of data items stored in the Storage object |
| `getItem(keyname)`        | Returns the value of the specified key name                   |
| `setItem(keyname, value)` | Adds or updates the key to the storage                        |
| `removeItem(keyname)`     | Removes that key from the storage                             |
| `clear()`                 | Empty all key out of the storage                              |

`sessionStorage` is identical to the `localStorage` but it only stores the data
for one session, so the data will be deleted when the browser is closed.

Introduced by HTML5, it has replaced many of the [cookies](#cookies)
uses. This is because `LocalStorage` has a lot of advantages over cookies. One of
the most important differences is that unlike with cookies, data does not have
to be sent back and forth with every HTTP request. This reduces the overall
traffic between the client and the server and the amount of wasted bandwidth.
This is because data is stored on the user’s local disk and is not destroyed or
cleared by the loss of an internet connection. Also, `LocalStorage` can hold up
to 5MB of information which is a whole lot more than the 4KB that cookies hold.

`LocalStorage` behaves more like persistent cookies in terms of expiration. Data
is not automatically destroyed unless it is cleared through Javascript code.
This can be good for larger bits of data that need to be stored for longer
periods of time. Also, with `LocalStorage` you can not only store strings but also
Javascript primitives and objects.

An example of a good use of `LocalStorage` might be in an application used in
regions without a persistent internet connection. In order for this to be a good
use of `LocalStorage`, the threat level of the data stored in this situation would
have to be very low. To protect client privacy, it would be good to upload the
data when connection is re-established and then delete the locally stored
version.

In conclusion, *Cookies are smaller and send server information back with every
HTTP request, while `LocalStorage` is larger and can hold information on the
client side.*

# [Web workers](https://www.w3schools.com/js/js_api_web_workers.asp)

When executing scripts in an HTML page, the page becomes unresponsive until the
script is finished.

A web worker is a JavaScript that runs in the background, independently of other
scripts, without affecting the performance of the page. You can continue to do
whatever you want: clicking, selecting things, etc., while the web worker runs
in the background.

Since web workers are in external files, they do not have access to the
following JavaScript objects:

* The window object
* The document object
* The parent object

Before creating a web worker check whether the user's browser supports it:

```javascript
if (typeof(Worker) !== "undefined") {
  // Yes! Web worker support!
  // Some code.....
} else {
  // Sorry! No Web Worker support..
}
```

Now, let's create our web worker in an external JavaScript.

Here, we create a script that counts. The script is stored in the `demo_workers.js` file:

```javascript
let i = 0;

function timedCount() {
  i ++;
  postMessage(i);
  setTimeout("timedCount()",500);
}

timedCount();
```

The important part of the code above is the `postMessage()` method, which is
used to post a message back to the HTML page.

## Create a Web Worker object

Now that we have the web worker file, we need to call it from an HTML page.

The following lines checks if the worker already exists, if not it creates a new web worker object and runs the code in `demo_workers.js`:

```javascript
if (typeof(w) == "undefined") {
  w = new Worker("demo_workers.js");
}
```

Then we can send and receive messages from the web worker.

Add an `onmessage` event listener to the web worker.

```javascript
w.onmessage = function(event){
  document.getElementById("result").innerHTML = event.data;
};
```

When the web worker posts a message, the code within the event listener is
executed. The data from the web worker is stored in `event.data`.

## Terminate a Web Worker

When a web worker object is created, it will continue to listen for messages
(even after the external script is finished) until it is terminated.

To terminate a web worker, and free browser/computer resources, use the
`terminate()` method:

```javascript
w.terminate();
```

## Reuse the Web Worker

If you set the worker variable to `undefined`, after it has been terminated, you can reuse the code:

```javascript
w = undefined;
```

## Full web worker example code

```html
 <!DOCTYPE html>
<html>
<body>

<p>Count numbers: <output id="result"></output></p>
<button onclick="startWorker()">Start Worker</button>
<button onclick="stopWorker()">Stop Worker</button>

<script>
let w;

function startWorker() {
  if (typeof(w) == "undefined") {
    w = new Worker("demo_workers.js");
  }
  w.onmessage = function(event) {
    document.getElementById("result").innerHTML = event.data;
  };
}

function stopWorker() {
  w.terminate();
  w = undefined;
}
</script>

</body>
</html>
```
# [Interacting with external APIs](https://www.w3schools.com/js/js_api_fetch.asp)

The Fetch API interface allows web browser to make HTTP requests to web servers.

The example below fetches a file and displays the content:

```html
<body>
<p id="demo">Fetch a file to change this text.</p>
<script>

let file = "fetch_info.txt"

fetch (file)
.then(x => x.text())
.then(y => document.getElementById("demo").innerHTML = y);

</script>
</body>
```

Where the content of `fetch_info.txt` is:

```html
<h1>Fetch API</h1>
<p>The Fetch API interface allows web browser to make HTTP requests to web servers.</p>
```

Since `Fetch` is based on `async` and `await`, the example above might be easier
to understand like this:

```javascript
async function getText(file) {
  let x = await fetch(file);
  let y = await x.text();
  myDisplay(y);
}
```

Or even better: Use understandable names instead of `x` and `y`:

```javascript
async function getText(file) {
  let myObject = await fetch(file);
  let myText = await myObject.text();
  myDisplay(myText);
}
```

The first `.then()` resolves the promise into a response object. To be able to
view the content of this object the response is then converted using a `.json()`
method. This `json()` also returns a promise so another `.then()` is necessary.

## Doing a POST

We can first include the settings such as header and request method in a object.

```javascript
var jsonObj = {};
jsonObj.firstParam = "first";
jsonObj.secondParam = 2;
jsonObj.thirdParam = true;

var options = {
    method: 'POST',
    header: new Headers({
        "Content-Type": "application/json",
    }),
    body: JSON.stringify(jsonObj)
}

var url = http://localhost:8080/postRequest;

fetch(url, options)
.then((response) => {
    console.log("Status Code",response.status);
    //return response type such as json, blob, text, formData and arrayBuffer
    return response.json()
})
.then((result) => {
    //here will return whatever information from the response.
    console.log("response message from backend", result);
})
.catch((error) => {
    console.log(error);
});
```

# [Error handling](https://www.w3schools.com/js/js_errors.asp)

* The `try` statement defines a code block to run (to try).
* The `catch` statement defines a code block to handle any error.
* The `finally` statement defines a code block to run regardless of the result.
* The `throw` statement defines a custom error.

    ```html
    throw "Too big";    // throw a text
    throw 500;          // throw a number
    ```

In this example we misspelled `alert` as `adddlert` to deliberately produce an error:

```html
<p id="demo"></p>

<script>
try {
  adddlert("Welcome guest!");
}
catch(err) {
  document.getElementById("demo").innerHTML = err.message;
}
</script>
```

When an error occurs, JavaScript will normally stop and generate an error message.

JavaScript will create an `Error` object with two properties: `name` and
`message`.

Six different values can be returned by the error `name` property:

| Error Name     | Description                                    |
| ---            | ---                                            |
| EvalError      | An error has occurred in the `eval()` function |
| RangeError     | A number "out of range" has occurred           |
| ReferenceError | An illegal reference has occurred              |
| SyntaxError    | A syntax error has occurred                    |
| TypeError      | A type error has occurred                      |
| URIError       | An error in `encodeURI()` has occurred         |
|

## Input validation example

This example examines input. If the value is wrong, an exception (`err`) is thrown.

The exception is caught by the `catch` statement and a custom error message is displayed:

```html
<p>Please input a number between 5 and 10:</p>

<input id="demo" type="text">
<button type="button" onclick="myFunction()">Test Input</button>
<p id="p01"></p>

<script>
function myFunction() {
  const message = document.getElementById("p01");
  message.innerHTML = "";
  let x = document.getElementById("demo").value;
  try {
    if(x == "") throw "empty";
    if(isNaN(x)) throw "not a number";
    x = Number(x);
    if(x < 5) throw "too low";
    if(x > 10) throw "too high";
  }
  catch(err) {
    message.innerHTML = "Input is " + err;
  }
}
</script>
```


# [Debugging](https://www.w3schools.com/js/js_debugging.asp)

You can use the `console.log` to display JavaScript values in the debugger window:

```javascript
a = 5;
b = 6;
c = a + b;
console.log(c);
```

Or you can use breakpoints

```javascript
let x = 15 * 5;
debugger;
document.getElementById("demo").innerHTML = x;
```

# [Style guide](https://www.w3schools.com/js/js_conventions.asp)

* Always put spaces around operators ( = + - * / ), and after commas.
* Always use 2 spaces for indentation of code blocks.
* Avoid lines longer than 80 characters.
* Always end a simple statement with a semicolon.

    ```javascript
    const cars = ["Volvo", "Saab", "Fiat"];

    const person = {
      firstName: "John",
      lastName: "Doe",
      age: 50,
      eyeColor: "blue"
    };
    ```

* General rules for complex (compound) statements:

    * Put the opening bracket at the end of the first line.
    * Use one space before the opening bracket.
    * Put the closing bracket on a new line, without leading spaces.
    * Do not end a complex statement with a semicolon.

    ```javascript

    function toCelsius(fahrenheit) {
      return (5 / 9) * (fahrenheit - 32);
    }

    for (let i = 0; i < 5; i++) {
      x += i;
    }

    if (time < 20) {
      greeting = "Good day";
    } else {
      greeting = "Good evening";
    }
    ```

* General rules for object definitions:

    * Place the opening bracket on the same line as the object name.
    * Use colon plus one space between each property and its value.
    * Use quotes around string values, not around numeric values.
    * Do not add a comma after the last property-value pair.
    * Place the closing bracket on a new line, without leading spaces.
    * Always end an object definition with a semicolon.

    ```javascript
    const person = {
      firstName: "John",
      lastName: "Doe",
      age: 50,
      eyeColor: "blue"
    };
    ```

# [Best practices](https://www.w3schools.com/js/js_best_practices.asp)

* Minimize the use of global variables.
* All variables used in a function should be declared as local variables.
* It is a good coding practice to put all declarations at the top of each script
    or function.

    This will:

    * Give cleaner code
    * Provide a single place to look for local variables
    * Make it easier to avoid unwanted (implied) global variables
    * Reduce the possibility of unwanted re-declarations

* Initialize variables when you declare them.

    This will:

    * Give cleaner code
    * Provide a single place to initialize variables
    * Avoid undefined values

* Declaring objects and arrays with `const` will prevent any accidental change of type.
* Don't use the `new Object()`

    * Use `""` instead of new `String()`.
    * Use `0` instead of new `Number()`.
    * Use `false` instead of new `Boolean()`.
    * Use `{}` instead of new `Object()`.
    * Use `[]` instead of new `Array()`.
    * Use `/()/` instead of new `RegExp()`.
    * Use `function (){}` instead of `new Function()`.
* Use `===` for comparison. The `==` comparison operator always converts (to
    matching types) before comparison.
* Use parameter defaults. If a function is called with a missing argument, the
    value of the missing argument is set to `undefined`.

    Undefined values can break your code. It is a good habit to assign default
    values to arguments.

    ```javascript
    function myFunction(x, y) {
      if (y === undefined) {
        y = 0;
      }
    }
    ```
* Avoid using `eval()`. It's used to run text as code which represents
    a security problem.

* Reduce DOM access. Accessing the HTML DOM is very slow, compared to other
    JavaScript statements.

    If you expect to access a DOM element several times, access it once, and use
    it as a local variable:

    ```javascript
    const obj = document.getElementById("demo");
    obj.innerHTML = "Hello";
    ```
* Keep the number of elements in the HTML DOM small. This will always improve
    page loading, and speed up rendering (page display), especially on smaller
    devices.

    Every attempt to search the DOM (like `getElementsByTagName`) will benefit
    from a smaller DOM.

* Delay JavaScript loading. Putting your scripts at the bottom of the page body
    lets the browser load the page first.

    While a script is downloading, the browser will not start any other
    downloads. In addition all parsing and rendering activity might be blocked.

* Avoid using the `with` keyword. It has a negative effect on speed. It also
    clutters up JavaScript scopes.

# References

* [W3 JavaScript tutorial](https://www.w3schools.com/js/default.asp)
* [John Comeau operator explainer](https://www.joshwcomeau.com/operator-lookup)
* [Re-introduction to JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript/A_re-introduction_to_JavaScript)
* [Chikwekwe's articles on cookies vs LocalStorage](https://medium.com/swlh/cookies-vs-localstorage-whats-the-difference-d99f0eb09b44)
* [Jeff's post on xmlhttprequest vs Fetch API](https://jeffdevslife.com/p/xmlhttprequest-vs-fetch-api/)
