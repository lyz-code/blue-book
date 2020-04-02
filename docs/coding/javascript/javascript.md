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

```js
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

```js
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

    ```js
    let a;
    let name = 'Simon';
    ```

    The declared variable is available from the block it is enclosed in.

    ```js
    // myLetVariable is *not* visible out here

    for (let myLetVariable = 0; myLetVariable < 5; myLetVariable++) {
      // myLetVariable is only visible in here
    }

    // myLetVariable is *not* visible out here
    ```

* `const` is used to declare variables whose values are never intended to
    change. The variable is available from the block it is declared in.

    ```js
    const Pi = 3.14; // variable Pi is set
    Pi = 1; // will throw an error because you cannot change a constant variable.
    ```
* `var` is the most common declarative keyword. It does not have the
    restrictions that the other two keywords have. If you declare a variable
    without assigning any value to it, its type is undefined.

    ```js
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

    ```js
    123 == '123'; // true
    1 == true; // true
    ```

    To avoid type coercion, use the triple-equals operator:

    ```js
    123 === '123'; // false
    1 === true;    // false
    ```
* `!=` and `!==`.

## Control structures

### If conditionals

```js
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

### Switch cases

```js
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

```js
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

    ```js
    for (var i = 0; i < 5; i++) {
      // Will execute 5 times
    }
    ```
* `for`...`of`.
    ```js
    for (let value of array) {
      // do something with value
    }
    ```
* `for`...`in`.
    ```js
    for (let property in object) {
      // do something with object property
    }
    ```

## Objects

Objects can be thought of as simple collections of name-value pairs, such as
Python dictionaries.

```js
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

```js
obj.details.color; // orange
obj['details']['size']; // 12
```
The following example creates an object prototype(`Person`) and an instance of
that prototype(`you`).

```js
function Person(name, age) {
  this.name = name;
  this.age = age;
}

// Define an object
var you = new Person('You', 24);
// We are creating a new person named "You" aged 24.
```

## Arrays

Arrays can be thought of as Python lists. They work very much like regular
objects but with [their own
properties and methods](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array),
such as `length`, which returns one more than the highest index in the array.

```js
var a = new Array();
a[0] = 'dog';
a[1] = 'cat';
a[2] = 'hen';
// or

var a = ['dog', 'cat', 'hen'];

a.length; // 3
```

### Iterate over the values of an array

```js
for (const currentValue of a) {
  // Do something with currentValue
}

// or

for (var i = 0; i < a.length; i++) {
  // Do something with a[i]
}
```

### Append an item to an array

Although `push()` could be used, is better to use `concat()` as it doesn't
mutate the original array.

```js
a.concat(item);
```

### Apply a function to the elements of an array

```js
const numbers = [1, 2, 3];
const doubled = numbers.map(x => x * 2); // [2, 4, 6]
```

## Functions

```js
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

```js
<button className="square" onClick={function() { alert('click'); }}>
```

It's better to use

```js
<button className="square" onClick={() => alert('click')}>
```
Notice how with `onClick={() => alert('click')}`, the function is passed as the
`onClick` prop.

### Define variable number of arguments

```js
function avg(...args) {
  var sum = 0;
  for (let value of args) {
    sum += value;
  }
  return sum / args.length;
}

avg(2, 3, 4, 5); // 3.5
```

## Custom objects

JavaScript is a prototype-based language that contains no class statement.
Instead, JavaScript uses functions as classes.

```js
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

```js
var s = makePerson('Simon', 'Willison');
var fullName = s.fullName;
fullName(); // undefined undefined
```

When calling `fullName()` alone, without using `s.fullName()`, this is bound to
the global object. Since there are no global variables called `first` or `last`
we get `undefined` for each one.

### Constructor functions

We can take advantage of the `this` keyword to improve the `makePerson` function:

```js
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

```js
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

```js
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

```js
  renderSquare(i) {
    return (
      <Square
        value={this.state.squares[i]}
        onClick={() => this.handleClick(i)}
      />
    );
  }
```



# Links

* [Re-introduction to JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript/A_re-introduction_to_JavaScript)
