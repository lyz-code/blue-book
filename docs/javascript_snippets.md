---
title: javascript snippets
date: 20220419
author: Lyz
---

# [Concatenate two arrays](https://www.w3schools.com/jsref/jsref_concat_array.asp)

```javascript
const arr1 = ["Cecilie", "Lone"];
const arr2 = ["Emil", "Tobias", "Linus"];
const children = arr1.concat(arr2);
```

To join more arrays you can use:

```javascript
const arr1 = ["Cecilie", "Lone"];
const arr2 = ["Emil", "Tobias", "Linus"];
const arr3 = ["Robin"];
const children = arr1.concat(arr2,arr3);
```

# [Check if a variable is not undefined](https://stackoverflow.com/questions/10192662/how-to-check-if-a-javascript-variable-is-not-undefined)

```javascript
if(typeof lastname !== "undefined")
{
  alert("Hi. Variable is defined.");
}
```

# [Select a substring](https://medium.com/coding-at-dawn/how-to-select-a-range-from-a-string-a-substring-in-javascript-1ba611e7fc1)

```javascript
'long string'.substring(startIndex, endIndex)
```

# [Round a number](https://www.w3schools.com/jsref/jsref_round.asp)

```javascript
Math.round(2.5)
```

# [Remove focus from element](https://stackoverflow.com/questions/60684165/how-to-remove-focus-from-vuetify-v-select)

```javascript
document.activeElement.blur();
```
