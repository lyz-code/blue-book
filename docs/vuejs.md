---
title: Vue.js
date: 20210507
author: Lyz
---

[Vue.js](https://vuejs.org) is a progressive JavaScript framework for building user
interfaces. It builds on top of standard HTML, CSS and JavaScript, and provides
a declarative and component-based programming model that helps you efficiently
develop user interfaces, be it simple or complex.

Here is a minimal example:

```javascript
import { createApp } from 'vue'

createApp({
  data() {
    return {
      count: 0
    }
  }
}).mount('#app')
```

```html
<div id="app">
  <button @click="count++">
    Count is: {{ count }}
  </button>
</div>
```

The above example demonstrates the two core features of Vue:

* *Declarative Rendering*: Vue extends standard HTML with a template syntax that
    allows us to declaratively describe HTML output based on JavaScript state.

* *Reactivity*: Vue automatically tracks JavaScript state changes and
    efficiently updates the DOM when changes happen.

# Features

## [Single file components](https://vuejs.org/guide/introduction.html#single-file-components)

Single-File Component (also known as `*.vue` files, abbreviated as SFC)
encapsulates the component's logic (JavaScript), template (HTML), and styles
(CSS) in a single file. Here's the previous example, written in SFC format:

```vue
<script>
export default {
  data() {
    return {
      count: 0
    }
  }
}
</script>

<template>
  <button @click="count++">Count is: {{ count }}</button>
</template>

<style scoped>
button {
  font-weight: bold;
}
</style>
```

## [API Styles](https://vuejs.org/guide/introduction.html#api-styles)

Vue components can be authored in two different API styles: Options API and
Composition API.

### Options API

With Options API, we define a component's logic using an object of options such
as `data`, `methods`, and `mounted`. Properties defined by options are exposed
on this inside functions, which points to the component instance:

```vue
<script>
export default {
  // Properties returned from data() becomes reactive state
  // and will be exposed on `this`.
  data() {
    return {
      count: 0
    }
  },

  // Methods are functions that mutate state and trigger updates.
  // They can be bound as event listeners in templates.
  methods: {
    increment() {
      this.count++
    }
  },

  // Lifecycle hooks are called at different stages
  // of a component's lifecycle.
  // This function will be called when the component is mounted.
  mounted() {
    console.log(`The initial count is ${this.count}.`)
  }
}
</script>

<template>
  <button @click="increment">Count is: {{ count }}</button>
</template>
```

The Options API is centered around the concept of a "component instance" (`this`
as seen in the example), which typically aligns better with a class-based mental
model for users coming from OOP language backgrounds. It is also more
beginner-friendly by abstracting away the reactivity details and enforcing code
organisation via option groups.

### Composition API

With Composition API, we define a component's logic using imported API
functions. In SFCs, Composition API is typically used with `<script setup>`. The
setup attribute is a hint that makes Vue perform compile-time transforms that
allow us to use Composition API with less boilerplate. For example, imports and
top-level variables / functions declared in `<script setup>` are directly usable
in the template.

Here is the same component, with the exact same template, but using Composition
API and `<script setup>` instead:

```vue
<script setup>
import { ref, onMounted } from 'vue'

// reactive state
const count = ref(0)

// functions that mutate state and trigger updates
function increment() {
  count.value++
}

// lifecycle hooks
onMounted(() => {
  console.log(`The initial count is ${count.value}.`)
})
</script>

<template>
  <button @click="increment">Count is: {{ count }}</button>
</template>
```

The Composition API is centered around declaring reactive state variables
directly in a function scope, and composing state from multiple functions
together to handle complexity. It is more free-form, and requires understanding
of how reactivity works in Vue to be used effectively. In return, its
flexibility enables more powerful patterns for organizing and reusing logic.

# [Initialize a project](https://vuejs.org/guide/quick-start.html#with-build-tools)

To create a build-tool-enabled Vue project on your machine, run the following
command in your command line. If you don't have `npm` follow [these
instructions](nodejs.md).

```bash
npm init vue@latest
```

This command will install and execute create-vue, the official Vue project
scaffolding tool. You will be presented with prompts for a number of optional
features such as TypeScript and testing support. If you are unsure about an
option, simply choose `No`. Follow their instructions.

Once the project is created, follow the instructions to install dependencies and
start the dev server:

```bash
cd <your-project-name>
npm install
npm run dev
```

When you are ready to ship your app to production, run the following:

```bash
npm run build
```

# The basics

## [Creating a Vue Application](https://vuejs.org/guide/essentials/application.html)

Every Vue application starts by creating a new application instance with the
`createApp` function:

```vue
import { createApp } from 'vue'

const app = createApp({
  /* root component options */
})
```

The object we are passing into `createApp` is in fact a component. Every app
requires a "root component" that can contain other components as its children.

If you are using Single-File Components, we typically import the root component
from another file:

```vue
import { createApp } from 'vue'
// import the root component App from a single-file component.
import App from './App.vue'

const app = createApp(App)
```

An application instance won't render anything until its `.mount()` method is
called. It expects a "container" argument, which can either be an actual DOM
element or a selector string:

```html
<div id="app"></div>
```

```javascript
app.mount('#app')
```

The content of the app's root component will be rendered inside the container
element. The container element itself is not considered part of the app.

The `.mount()` method should always be called after all app configurations and
asset registrations are done. Also note that its return value, unlike the asset
registration methods, is the root component instance instead of the application
instance.


You are not limited to a single application instance on the same page. The
`createApp` API allows multiple Vue applications to co-exist on the same page,
each with its own scope for configuration and global assets:

```javascript
const app1 = createApp({
  /* ... */
})
app1.mount('#container-1')

const app2 = createApp({
  /* ... */
})
app2.mount('#container-2')
```

### [App configurations](https://vuejs.org/guide/essentials/application.html#app-configurations)

The application instance exposes a `.config` object that allows us to configure
a few app-level options, for example defining an app-level error handler that
captures errors from all descendent components:

```javascript
app.config.errorHandler = (err) => {
  /* handle error */
}
```

The application instance also provides a few methods for registering app-scoped
assets. For example, registering a component:

```javascript
app.component('TodoDeleteButton', TodoDeleteButton)
```

This makes the `TodoDeleteButton` available for use anywhere in our app.

## [Declarative rendering](https://vuejs.org/tutorial/#step-2)

The core feature of Vue is declarative rendering: using a template syntax that
extends HTML, we can describe how the HTML should look like based on JavaScript
state. When the state changes, the HTML updates automatically.

State that can trigger updates when changed are considered reactive. In Vue,
reactive state is held in components.

We can declare reactive state using the data component option, which should be
a function that returns an object:

```javascript
export default {
  data() {
    return {
      message: 'Hello World!'
    }
  }
}
```

The message property will be made available in the template. This is how we can
render dynamic text based on the value of message, using mustaches syntax:

```html
<h1>{{ message }}</h1>
```

The double mustaches interprets the data as plain text, not HTML. In order to
output real HTML, you will need to use the `v-html` directive, although you
should try to avoid it for security reasons.

Directives are prefixed with `v-` to indicate that they are special attributes
provided by Vue, they apply special reactive behavior to the rendered DOM.


## [Attribute bindings](https://vuejs.org/tutorial/#step-3)

To bind an attribute to a dynamic value, we use the `v-bind` directive:

```html
<div v-bind:id="dynamicId"></div>
```

A directive is a special attribute that starts with the `v-` prefix. They are part
of Vue's template syntax. Similar to text interpolations, directive values are
JavaScript expressions that have access to the component's state.

The part after the colon (`:id`) is the "argument" of the directive. Here, the
element's `id` attribute will be synced with the `dynamicId` property from the
component's state.

Because `v-bind` is used so frequently, it has a dedicated shorthand syntax:

```html
<div :id="dynamicId"></div>
```

### Class binding

For example to turn the `h1` in red:

```vue
<script>
export default {
  data() {
    return {
      titleClass: 'title'
    }
  }
}
</script>

<template>
  <h1 :class='titleClass'>Make me red</h1> <!-- add dynamic class binding here -->
</template>

<style>
.title {
  color: red;
}
</style>
```

You can have multiple classes toggled by having more fields in the object. In
addition, the `:class` directive can also co-exist with the plain class attribute.
So given the following state:

```javascript
data() {
  return {
    isActive: true,
    hasError: false
  }
}
```

And the following template:

```html
<div
  class="static"
  :class="{ active: isActive, 'text-danger': hasError }"
></div>
```


It will render:

```html
<div class="static active"></div>
```

When `isActive` or `hasError` changes, the class list will be updated
accordingly. For example, if `hasError` becomes true, the class list will become `static active text-danger`.

The bound object doesn't have to be inline:

```javascript
data() {
  return {
    classObject: {
      active: true,
      'text-danger': false
    }
  }
}
```

```html
<div :class="classObject"></div>
```

This will render the same result. We can also bind to a [computed
property](#computed-property) that returns an object. This is a common and
powerful pattern:

```javascript
data() {
  return {
    isActive: true,
    error: null
  }
},
computed: {
  classObject() {
    return {
      active: this.isActive && !this.error,
      'text-danger': this.error && this.error.type === 'fatal'
    }
  }
}
```

```html
<div :class="classObject"></div>
```

### Style binding

`:style` supports binding to JavaScript object values.

```javascript
data() {
  return {
    activeColor: 'red',
    fontSize: 30
  }
}
```

```html
<div :style="{ color: activeColor, fontSize: fontSize + 'px' }"></div>
```

It is often a good idea to bind to a style object directly so that the template is cleaner:

```javascript
data() {
  return {
    styleObject: {
      color: 'red',
      fontSize: '13px'
    }
  }
}
```

```html
<div :style="styleObject"></div>
```

Again, object style binding is often used in conjunction with computed properties that return objects.

## [Event listeners](https://vuejs.org/tutorial/#step-4)

We can listen to DOM events using the `v-on` directive:

```vue
<button v-on:click="increment">{{ count }}</button>
```

Due to its frequent use, `v-on` also has a shorthand syntax:

```vue
<button @click="increment">{{ count }}</button>
```

Here, `increment` references a function declared using the methods option:

```javascript
export default {
  data() {
    return {
      count: 0
    }
  },
  methods: {
    increment() {
      // update component state
      this.count++
    }
  }
}
```

Inside a method, we can access the component instance using `this`. The component
instance exposes the data properties declared by data. We can update the
component state by mutating these properties.

You should avoid using arrow functions when defining methods, as that prevents
Vue from binding the appropriate this value.

### [Event modifiers](https://vuejs.org/guide/essentials/event-handling.html#event-modifiers)
It is a very common need to call `event.preventDefault()` or
`event.stopPropagation()` inside event handlers. Although we can do this easily
inside methods, it would be better if the methods can be purely about data logic
rather than having to deal with DOM event details.

To address this problem, Vue provides event modifiers for `v-on`. Recall that modifiers are directive postfixes denoted by a dot.

* `.stop`
* `.prevent`
* `.self`
* `.capture`
* `.once`
* `.passive`

```html
<!-- the click event's propagation will be stopped -->
<a @click.stop="doThis"></a>

<!-- the submit event will no longer reload the page -->
<form @submit.prevent="onSubmit"></form>

<!-- modifiers can be chained -->
<a @click.stop.prevent="doThat"></a>

<!-- just the modifier -->
<form @submit.prevent></form>

<!-- only trigger handler if event.target is the element itself -->
<!-- i.e. not from a child element -->
<div @click.self="doThat">...</div>

<!-- use capture mode when adding the event listener -->
<!-- i.e. an event targeting an inner element is handled here before being handled by that element -->
<div @click.capture="doThis">...</div>

<!-- the click event will be triggered at most once -->
<a @click.once="doThis"></a>

<!-- the scroll event's default behavior (scrolling) will happen -->
<!-- immediately, instead of waiting for `onScroll` to complete  -->
<!-- in case it contains `event.preventDefault()`                -->
<div @scroll.passive="onScroll">...</div>
```

### [Key Modifiers](https://vuejs.org/guide/essentials/event-handling.html#key-modifiers)

When listening for keyboard events, we often need to check for specific keys.
Vue allows adding key modifiers for `v-on` or `@` when listening for key events:

```html
<!-- only call `vm.submit()` when the `key` is `Enter` -->
<input @keyup.enter="submit" />
```

You can directly use any valid key names exposed via
[`KeyboardEvent.key`](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values)
as modifiers by converting them to kebab-case.

```html
<input @keyup.page-down="onPageDown" />
```

Vue provides aliases for the most commonly used keys:

* `.enter`
* `.tab`
* `.delete` (captures both "Delete" and "Backspace" keys)
* `.esc`
* `.space`
* `.up`
* `.down`
* `.left`
* `.right`

You can use the following modifiers to trigger mouse or keyboard event listeners only when the corresponding modifier key is pressed:

* `.ctrl`
* `.alt`
* `.shift`
* `.meta`

For example:

```html
<!-- Alt + Enter -->
<input @keyup.alt.enter="clear" />

<!-- Ctrl + Click -->
<div @click.ctrl="doSomething">Do something</div>
```

The `.exact` modifier allows control of the exact combination of system
modifiers needed to trigger an event.

```html
<!-- this will fire even if Alt or Shift is also pressed -->
<button @click.ctrl="onClick">A</button>

<!-- this will only fire when Ctrl and no other keys are pressed -->
<button @click.ctrl.exact="onCtrlClick">A</button>

<!-- this will only fire when no system modifiers are pressed -->
<button @click.exact="onClick">A</button>
```

### Mouse Button Modifiers

* `.left`
* `.right`
* `.middle`

These modifiers restrict the handler to events triggered by a specific mouse
button.

## [Form bindings](https://vuejs.org/tutorial/#step-5)

### [Basic usage](https://vuejs.org/guide/essentials/forms.html#text)

#### Text

Using `v-bind` and `v-on` together, we can create two-way bindings on form input
elements:

```vue
<input :value="text" @input="onInput">
<p>{{ text }}</p>
```

```javascript
methods: {
  onInput(e) {
    // a v-on handler receives the native DOM event
    // as the argument.
    this.text = e.target.value
  }
}
```

To simplify two-way bindings, Vue provides a directive, `v-model`, which is
essentially a syntax sugar for the above:

```html
<input v-model="text">
```

`v-model` automatically syncs the `<input>`'s value with the bound state, so we
no longer need to use a event handler for that.

`v-model` works not only on text inputs, but also other input types such as
checkboxes, radio buttons, and select dropdowns.

#### Multiline text

```html
<span>Multiline message is:</span>
<p style="white-space: pre-line;">{{ message }}</p>
<textarea v-model="message" placeholder="add multiple lines"></textarea>
```

#### Checkbox

```html
<input type="checkbox" id="checkbox" v-model="checked" />
<label for="checkbox">{{ checked }}</label>
```

We can also bind multiple checkboxes to the same array or Set value:

```javascript
export default {
  data() {
    return {
      checkedNames: []
    }
  }
}
```

```html
<div>Checked names: {{ checkedNames }}</div>

<input type="checkbox" id="jack" value="Jack" v-model="checkedNames">
<label for="jack">Jack</label>

<input type="checkbox" id="john" value="John" v-model="checkedNames">
<label for="john">John</label>

<input type="checkbox" id="mike" value="Mike" v-model="checkedNames">
<label for="mike">Mike</label>
```

#### Radio checkboxes

```html
<div>Picked: {{ picked }}</div>

<input type="radio" id="one" value="One" v-model="picked" />
<label for="one">One</label>

<input type="radio" id="two" value="Two" v-model="picked" />
<label for="two">Two</label>
```

#### Select

Single select:

```html
<div>Selected: {{ selected }}</div>

<select v-model="selected">
  <option disabled value="">Please select one</option>
  <option>A</option>
  <option>B</option>
  <option>C</option>
</select>
```

Multiple select (bound to array):

```html
<div>Selected: {{ selected }}</div>

<select v-model="selected" multiple>
  <option>A</option>
  <option>B</option>
  <option>C</option>
</select>
```

Select options can be dynamically rendered with `v-for`:

```javascript
export default {
  data() {
    return {
      selected: 'A',
      options: [
        { text: 'One', value: 'A' },
        { text: 'Two', value: 'B' },
        { text: 'Three', value: 'C' }
      ]
    }
  }
}
```

```html
<select v-model="selected">
  <option v-for="option in options" :value="option.value">
    {{ option.text }}
  </option>
</select>

<div>Selected: {{ selected }}</div>
```

### [Value bindings](https://vuejs.org/guide/essentials/forms.html#value-bindings)

For radio, checkbox and select options, the `v-model` binding values are usually
static strings (or booleans for checkbox):.

```html
<!-- `picked` is a string "a" when checked -->
<input type="radio" v-model="picked" value="a" />

<!-- `toggle` is either true or false -->
<input type="checkbox" v-model="toggle" />

<!-- `selected` is a string "abc" when the first option is selected -->
<select v-model="selected">
  <option value="abc">ABC</option>
</select>
```

But sometimes we may want to bind the value to a dynamic property on the current
active instance. We can use `v-bind` to achieve that. In addition, using
`v-bind` allows us to bind the input value to non-string values.

#### Checkbox

```html
<input
  type="checkbox"
  v-model="toggle"
  true-value="yes"
  false-value="no" />
```

`true-value` and `false-value` are Vue-specific attributes that only work with
`v-model`. Here the toggle property's value will be set to 'yes' when the box is
checked, and set to 'no' when unchecked. You can also bind them to dynamic
values using `v-bind`:

```html
<input
  type="checkbox"
  v-model="toggle"
  :true-value="dynamicTrueValue"
  :false-value="dynamicFalseValue" />
```

#### Radio

```html
<input type="radio" v-model="pick" :value="first" />
<input type="radio" v-model="pick" :value="second" />
```

`pick` will be set to the value of first when the first radio input is checked, and set to the value of second when the second one is checked.

#### Select Options

```html
<select v-model="selected">
  <!-- inline object literal -->
  <option :value="{ number: 123 }">123</option>
</select>
```

`v-model` supports value bindings of non-string values as well! In the above
example, when the option is selected, selected will be set to the object literal
value of `{ number: 123 }`.

### [Form modifiers](https://vuejs.org/guide/essentials/forms.html#modifiers)
#### `.lazy`

By default, `v-model` syncs the input with the data after each input event. You can add the lazy modifier to instead sync after change events:

```html
<!-- synced after "change" instead of "input" -->
<input v-model.lazy="msg" />
```

#### `.number`

If you want user input to be automatically typecast as a number, you can add the
number modifier to your `v-model` managed inputs:

```html
<input v-model.number="age" />
```

If the value cannot be parsed with `parseFloat()`, then the original value is used instead.

The number modifier is applied automatically if the input has `type="number"`.

#### `.trim`

If you want whitespace from user input to be trimmed automatically, you can add
the trim modifier to your `v-model` managed inputs:

```html
<input v-model.trim="msg" />
```

## [Conditional rendering](https://vuejs.org/tutorial/#step-6)

We can use the `v-if` directive to conditionally render an element:

```html
<h1 v-if="awesome">Vue is awesome!</h1>
```

This `<h1>` will be rendered only if the value of `awesome` is truthy. If
awesome changes to a falsy value, it will be removed from the DOM.

We can also use `v-else` and `v-else-if` to denote other branches of the condition:

```html
<h1 v-if="awesome">Vue is awesome!</h1>
<h1 v-else>Oh no 😢</h1>
```

Because `v-if` is a directive, it has to be attached to a single element. But
what if we want to toggle more than one element? In this case we can use `v-if`
on a `<template>` element, which serves as an invisible wrapper. The final
rendered result will not include the `<template>` element.

```html
<template v-if="ok">
  <h1>Title</h1>
  <p>Paragraph 1</p>
  <p>Paragraph 2</p>
</template>
```

Another option for conditionally displaying an element is the `v-show`
directive. The usage is largely the same:

```html
<h1 v-show="ok">Hello!</h1>
```

The difference is that an element with `v-show` will always be rendered and
remain in the DOM; `v-show` only toggles the display CSS property of the element.

`v-show` doesn't support the `<template>` element, nor does it work with
`v-else`.

Generally speaking, `v-if` has higher toggle costs while `v-show` has higher
initial render costs. So prefer `v-show` if you need to toggle something very
often, and prefer `v-if` if the condition is unlikely to change at runtime.

## [List rendering](https://vuejs.org/tutorial/#step-7)

We can use the `v-for` directive to render a list of elements based on a source
array:

```html
<ul>
  <li v-for="todo in todos" :key="todo.id">
    {{ todo.text }}
  </li>
</ul>
```

Here `todo` is a local variable representing the array element currently being
iterated on. It's only accessible on or inside the `v-for` element.

Notice how we are also giving each todo object a unique `id`, and binding it as
the special key attribute for each `<li>`. The key allows Vue to accurately move
each `<li>` to match the position of its corresponding object in the array.

There are two ways to update the list:

* Call mutating methods on the source array:

    ```javascript
    this.todos.push(newTodo)
    ```

* Replace the array with a new one:

    ```javascript
    this.todos = this.todos.filter(/* ... */)
    ```

Example:

```vue
<script>
// give each todo a unique id
let id = 0

export default {
  data() {
    return {
      newTodo: '',
      todos: [
        { id: id++, text: 'Learn HTML' },
        { id: id++, text: 'Learn JavaScript' },
        { id: id++, text: 'Learn Vue' }
      ]
    }
  },
  methods: {
    addTodo() {
      this.todos.push({ id: id++, text: this.newTodo})
      this.newTodo = ''
    },
    removeTodo(todo) {
      this.todos = this.todos.filter((element) => element.id != todo.id)
    }
  }
}
</script>

<template>
  <form @submit.prevent="addTodo">
    <input v-model="newTodo">
    <button>Add Todo</button>
  </form>
  <ul>
    <li v-for="todo in todos" :key="todo.id">
      {{ todo.text }}
      <button @click="removeTodo(todo)">X</button>
    </li>
  </ul>
</template>
```

`v-for` also supports an optional second alias for the index of the current item:

```javascript
data() {
  return {
    parentMessage: 'Parent',
    items: [{ message: 'Foo' }, { message: 'Bar' }]
  }
}
```

```html
<li v-for="(item, index) in items">
  {{ parentMessage }} - {{ index }} - {{ item.message }}
</li>
```

Similar to template `v-if`, you can also use a `<template>` tag with `v-for` to
render a block of multiple elements. For example:

```html
<ul>
  <template v-for="item in items">
    <li>{{ item.msg }}</li>
    <li class="divider" role="presentation"></li>
  </template>
</ul>
```


It's not recommended to use `v-if` and `v-for` on the same element due
to implicit precedence. Instead of:

```html
<li v-for="todo in todos" v-if="!todo.isComplete">
  {{ todo.name }}
</li>
```

Use:

```html
<template v-for="todo in todos">
  <li v-if="!todo.isComplete">
    {{ todo.name }}
  </li>
</template>
```

### [`v-for` with an object](https://vuejs.org/guide/essentials/list.html#v-for-with-an-object)

You can also use `v-for` to iterate through the properties of an object.

```javascript
data() {
  return {
    myObject: {
      title: 'How to do lists in Vue',
      author: 'Jane Doe',
      publishedAt: '2016-04-10'
    }
  }
}
```

```html
<ul>
  <li v-for="value in myObject">
    {{ value }}
  </li>
</ul>
```

You can also provide a second alias for the property's name:

```html
<li v-for="(value, key) in myObject">
  {{ key }}: {{ value }}
</li>
```

And another for the index:

```html
<li v-for="(value, key, index) in myObject">
  {{ index }}. {{ key }}: {{ value }}
</li>
```

### v-for with a Range

`v-for` can also take an integer. In this case it will repeat the template that
many times, based on a range of `1...n`.

```html
<span v-for="n in 10">{{ n }}</span>
```

Note here `n` starts with an initial value of 1 instead of 0.

### [`v-for` with a Component](https://vuejs.org/guide/essentials/list.html#v-for-with-a-component)

You can directly use `v-for` on a [component](#components), like any normal
element (don't forget to provide a key):

```html
<my-component v-for="item in items" :key="item.id"></my-component>
```

However, this won't automatically pass any data to the component, because
components have isolated scopes of their own. In order to pass the iterated data
into the component, we should also use props:

```html
<my-component
  v-for="(item, index) in items"
  :item="item"
  :index="index"
  :key="item.id"
></my-component>
```

The reason for not automatically injecting item into the component is because
that makes the component tightly coupled to how `v-for` works. Being explicit
about where its data comes from makes the component reusable in other
situations.

## [Computed Property](https://vuejs.org/tutorial/#step-8)

We can declare a property that is reactively computed from other properties
using the `computed` option:

```javascript
export default {
  // ...
  computed: {
    filteredTodos() {
        if (this.hideCompleted) {
            return this.todos.filter((t) => t.done === false)
          } else {
            return this.todos
          }
        }
    }
  }
}
```

A computed property tracks other reactive state used in its computation as
dependencies. It caches the result and automatically updates it when its
dependencies change. So it's better than defining the function as a `method`

## [Lifecycle hooks](https://vuejs.org/guide/essentials/lifecycle.html)

Each Vue component instance goes through a series of initialization steps when
it's created - for example, it needs to set up data observation, compile the
template, mount the instance to the DOM, and update the DOM when data changes.
Along the way, it also runs functions called lifecycle hooks, giving users the
opportunity to add their own code at specific stages.

For example, the `mounted` hook can be used to run code after the component has
finished the initial rendering and created the DOM nodes:

```javascript
export default {
  mounted() {
    console.log(`the component is now mounted.`)
  }
}
```

There are also other hooks which will be called at different stages of the
instance's lifecycle, with the most commonly used being `mounted`, `updated`,
and `unmounted`.

All lifecycle hooks are called with their `this` context pointing to the current
active instance invoking it. Note this means you should avoid using arrow
functions when declaring lifecycle hooks, as you won't be able to access the
component instance via this if you do so.

## [Template Refs](https://vuejs.org/guide/essentials/template-refs.html)

While Vue's declarative rendering model abstracts away most of the direct DOM
operations for you, there may still be cases where we need direct access to the
underlying DOM elements. To achieve this, we can use the special `ref` attribute:

```html
<input ref="input">
```

`ref` allows us to obtain a direct reference to a specific DOM element or child
component instance after it's mounted. This may be useful when you want to, for
example, programmatically focus an input on component mount, or initialize a 3rd
party library on an element.

The resulting ref is exposed on `this.$refs`:

```javascript
<script>
export default {
  mounted() {
    this.$refs.input.focus()
  }
}
</script>
```

```html
<template>
  <input ref="input" />
</template>
```

Note that you can only access the `ref` after the component is mounted. If you
try to access `$refs.input` in a template expression, it will be `null` on the
first render. This is because the element doesn't exist until after the first
render!

## [Watchers](https://vuejs.org/tutorial/#step-10)

Computed properties allow us to declaratively compute derived values. However,
there are cases where we need to perform "side effects" in reaction to state
changes, for example, mutating the DOM, or changing another piece of state
based on the result of an async operation.

With Options API, we can use the `watch` option to trigger a function whenever
a reactive property changes:

```javascript
export default {
  data() {
    return {
      question: '',
      answer: 'Questions usually contain a question mark. ;-)'
    }
  },
  watch: {
    // whenever question changes, this function will run
    question(newQuestion, oldQuestion) {
      if (newQuestion.indexOf('?') > -1) {
        this.getAnswer()
      }
    }
  },
  methods: {
    async getAnswer() {
      this.answer = 'Thinking...'
      try {
        const res = await fetch('https://yesno.wtf/api')
        this.answer = (await res.json()).answer
      } catch (error) {
        this.answer = 'Error! Could not reach the API. ' + error
      }
    }
  }
}
```

```html
<p>
  Ask a yes/no question:
  <input v-model="question" />
</p>
<p>{{ answer }}</p>
```

### Deep watchers

`watch` is shallow by default: the callback will only trigger when the watched
property has been assigned a new value - it won't trigger on nested property
changes. If you want the callback to fire on all nested mutations, you need to
use a deep watcher:

```javascript
export default {
  watch: {
    someObject: {
      handler(newValue, oldValue) {
        // Note: `newValue` will be equal to `oldValue` here
        // on nested mutations as long as the object itself
        // hasn't been replaced.
      },
      deep: true
    }
  }
}
```

!!! note
        "Deep watch requires traversing all nested properties in the watched object, and can be expensive when used on large data structures. Use it only when necessary and beware of the performance implications."

### Eager watchers

`watch` is lazy by default: the callback won't be called until the watched
source has changed. But in some cases we may want the same callback logic to be
run eagerly, for example, we may want to fetch some initial data, and then
re-fetch the data whenever relevant state changes.

We can force a watcher's callback to be executed immediately by declaring it
using an object with a `handler` function and the `immediate: true` option:

```javascript
export default {
  // ...
  watch: {
    question: {
      handler(newQuestion) {
        // this will be run immediately on component creation.
      },
      // force eager callback execution
      immediate: true
    }
  }
  // ...
}
```

# [Components](https://vuejs.org/guide/essentials/component-basics.html)

Components allow us to split the UI into independent and reusable pieces, and
think about each piece in isolation. It's common for an app to be organized into
a tree of nested components

## Defining a component

When using a build step, we typically define each Vue component in a dedicated
file using the `.vue` extension.

```vue
<script>
export default {
  data() {
    return {
      count: 0
    }
  }
}
</script>

<template>
  <button @click="count++">You clicked me {{ count }} times.</button>
</template>
```

## Using a component

To use a child component, we need to import it in the parent component. Assuming
we placed our counter component inside a file called `ButtonCounter.vue`, the
component will be exposed as the file's default export:

```vue
<script>
import ButtonCounter from './ButtonCounter.vue'

export default {
  components: {
    ButtonCounter
  }
}
</script>

<template>
  <h1>Here is a child component!</h1>
  <ButtonCounter />
</template>
```

To expose the imported component to our template, we need to register it with
the `components` option. The component will then be available as a tag using the
key it is registered under.

Components can be reused as many times as you want:

```html
<h1>Here are many child components!</h1>
<ButtonCounter />
<ButtonCounter />
<ButtonCounter />
```

When clicking on the buttons, each one maintains its own, separate count. That's
because each time you use a component, a new instance of it is created.

## Passing props

Props are custom attributes you can register on a component. Vue components
require explicit `props` declaration so that Vue knows what external props passed
to the component should be treated as fallthrough attributes.

```vue
<!-- BlogPost.vue -->
<script>
export default {
  props: ['title']
}
</script>

<template>
  <h4>{{ title }}</h4>
</template>
```

When a value is passed to a prop attribute, it becomes a property on that
component instance. The value of that property is accessible within the template
and on the component's `this` context, just like any other component property.

A component can have as many props as you like and, by default, any value can be
passed to any prop.

Once a prop is registered, you can pass data to it as a custom attribute, like this:

```html
<BlogPost title="My journey with Vue" />
<BlogPost title="Blogging with Vue" />
<BlogPost title="Why Vue is so fun" />
```

In a typical app, however, you'll likely have an array of posts in your parent component:

```javascript
export default {
  // ...
  data() {
    return {
      posts: [
        { id: 1, title: 'My journey with Vue' },
        { id: 2, title: 'Blogging with Vue' },
        { id: 3, title: 'Why Vue is so fun' }
      ]
    }
  }
}
```

Then want to render a component for each one, using `v-for`:

```html
<BlogPost
  v-for="post in posts"
  :key="post.id"
  :title="post.title"
 />
```

We declare long prop names using camelCase because this avoids having to use
quotes when using them as property keys.

```javascript
export default {
  props: {
    greetingMessage: String
  }
}
```

```html
<span>{{ greetingMessage }}</span>
```

However, the convention is using kebab-case when passing props to a child
component.

```html
<MyComponent greeting-message="hello" />
```

### Passing different value types on props

* Numbers:

    ```html
    <!-- Even though `42` is static, we need v-bind to tell Vue that -->
    <!-- this is a JavaScript expression rather than a string.       -->
    <BlogPost :likes="42" />

    <!-- Dynamically assign to the value of a variable. -->
    <BlogPost :likes="post.likes" />
    ```

* Boolean:
    ```html
    <!-- Including the prop with no value will imply `true`. -->
    <BlogPost is-published />

    <!-- Even though `false` is static, we need v-bind to tell Vue that -->
    <!-- this is a JavaScript expression rather than a string.          -->
    <BlogPost :is-published="false" />

    <!-- Dynamically assign to the value of a variable. -->
    <BlogPost :is-published="post.isPublished" />
    ```

* Array

    ```html
    <!-- Even though the array is static, we need v-bind to tell Vue that -->
    <!-- this is a JavaScript expression rather than a string.            -->
    <BlogPost :comment-ids="[234, 266, 273]" />

    <!-- Dynamically assign to the value of a variable. -->
    <BlogPost :comment-ids="post.commentIds" />
    ```

* Object

    ```html
    <!-- Even though the object is static, we need v-bind to tell Vue that -->
    <!-- this is a JavaScript expression rather than a string.             -->
    <BlogPost
      :author="{
        name: 'Veronica',
        company: 'Veridian Dynamics'
      }"
     />

    <!-- Dynamically assign to the value of a variable. -->
    <BlogPost :author="post.author" />
    ```

    If you want to pass all the properties of an object as props, you can use
    v-bind without an argument.

    ```javascript
    export default {
      data() {
        return {
          post: {
            id: 1,
            title: 'My Journey with Vue'
          }
        }
      }
    }
    ```

    The following template:

    ```html
    <BlogPost v-bind="post" />
    ```

    Will be equivalent to:

    ```html
    <BlogPost :id="post.id" :title="post.title" />
    ```
### [One-way data flow in props](https://vuejs.org/guide/components/props.html#one-way-data-flow)

All props form a one-way-down binding between the child property and the parent
one: when the parent property updates, it will flow down to the child, but not
the other way around.

Every time the parent component is updated, all props in the child component
will be refreshed with the latest value. This means you should not attempt to
mutate a prop inside a child component.

### [Prop validation](https://vuejs.org/guide/components/props.html#prop-validation)

Components can specify requirements for their props, if a requirement is not
met, Vue will warn you in the browser's JavaScript console.

```javascript
export default {
  props: {
    // Basic type check
    //  (`null` and `undefined` values will allow any type)
    propA: Number,
    // Multiple possible types
    propB: [String, Number],
    // Required string
    propC: {
      type: String,
      required: true
    },
    // Number with a default value
    propD: {
      type: Number,
      default: 100
    },
    // Object with a default value
    propE: {
      type: Object,
      // Object or array defaults must be returned from
      // a factory function. The function receives the raw
      // props received by the component as the argument.
      default(rawProps) {
        // default function receives the raw props object as argument
        return { message: 'hello' }
      }
    },
    // Custom validator function
    propF: {
      validator(value) {
        // The value must match one of these strings
        return ['success', 'warning', 'danger'].includes(value)
      }
    },
    // Function with a default value
    propG: {
      type: Function,
      // Unlike object or array default, this is not a factory function - this is a function to serve as a default value
      default() {
        return 'Default function'
      }
    }
  }
}
```

Additional details:

* All props are optional by default, unless `required: true` is specified.
* An absent optional prop will have `undefined` value.
* If a `default` value is specified, it will be used if the resolved prop value
    is `undefined`, this includes both when the prop is absent, or an explicit
    `undefined` value is passed.

## Listening to Events

As we develop our `<BlogPost>` component, some features may require
communicating back up to the parent. For example, we may decide to include an
accessibility feature to enlarge the text of blog posts, while leaving the rest
of the page at its default size.

In the parent, we can support this feature by adding a `postFontSize` data property:

```javascript
data() {
  return {
    posts: [
      /* ... */
    ],
    postFontSize: 1
  }
}
```

Which can be used in the template to control the font size of all blog posts:

```html
<div :style="{ fontSize: postFontSize + 'em' }">
  <BlogPost
    v-for="post in posts"
    :key="post.id"
    :title="post.title"
   />
</div>
```

Now let's add a button to the `<BlogPost>` component's template:

```vue
<!-- BlogPost.vue, omitting <script> -->
<template>
  <div class="blog-post">
    <h4>{{ title }}</h4>
    <button>Enlarge text</button>
  </div>
</template>
```

The button currently doesn't do anything yet - we want clicking the button to
communicate to the parent that it should enlarge the text of all posts. To solve
this problem, component instances provide a custom events system. The parent can
choose to listen to any event on the child component instance with `v-on` or
`@,` just as we would with a native DOM event:

```html
<BlogPost
  ...
  @enlarge-text="postFontSize += 0.1"
 />
```

Then the child component can emit an event on itself by calling the built-in
`$emit` method, passing the name of the event:

```html
<!-- BlogPost.vue, omitting <script> -->
<template>
  <div class="blog-post">
    <h4>{{ title }}</h4>
    <button @click="$emit('enlarge-text')">Enlarge text</button>
  </div>
</template>
```

The first argument to `this.$emit()` is the event name. Any additional arguments
are passed on to the event listener.

Thanks to the `@enlarge-text="postFontSize += 0.1"` listener, the parent will
receive the event and update the value of `postFontSize`.

We can optionally declare emitted events using the emits option:

```vue
<!-- BlogPost.vue -->
<script>
export default {
  props: ['title'],
  emits: ['enlarge-text']
}
</script>
```

This documents all the events that a component emits and optionally validates
them. It also allows Vue to avoid implicitly applying them as native listeners
to the child component's root element.

### [Event arguments](https://vuejs.org/guide/components/events.html#event-arguments)

It's sometimes useful to emit a specific value with an event. For example, we
may want the `<BlogPost>` component to be in charge of how much to enlarge the
text by. In those cases, we can pass extra arguments to $emit to provide this
value:

```html
<button @click="$emit('increaseBy', 1)">
  Increase by 1
</button>
```

Then, when we listen to the event in the parent, we can use an inline arrow
function as the listener, which allows us to access the event argument:

```html
<MyButton @increase-by="(n) => count += n" />
```

Or, if the event handler is a method:

<MyButton @increase-by="increaseCount" />

Then the value will be passed as the first parameter of that method:

```javascript
methods: {
  increaseCount(n) {
    this.count += n
  }
}
```

### [Declaring emitted events](https://vuejs.org/guide/components/events.html#declaring-emitted-events)

Emitted events can be explicitly declared on the component via the `emits` option.

```javascript
export default {
  emits: ['inFocus', 'submit']
}
```

The `emits` option also supports an object syntax, which allows us to perform
[runtime
validation](https://vuejs.org/guide/components/events.html#events-validation) of
the payload of the emitted events:

```javascript
export default {
  emits: {
    submit(payload) {
      // return `true` or `false` to indicate
      // validation pass / fail
    }
  }
}
```

Although optional, it is recommended to define all emitted events in order to
better document how a component should work.

## [Content distribution with Slots](https://vuejs.org/tutorial/#step-14)

In addition to passing data via props, the parent component can also pass down
template fragments to the child via slots:

```vue
<ChildComp>
  This is some slot content!
</ChildComp>
```

In the child component, it can render the slot content from the parent using the
`<slot>` element as outlet:

```vue
<!-- in child template -->
<slot/>
```

Content inside the `<slot>` outlet will be treated as "fallback" content: it
will be displayed if the parent did not pass down any slot content:

```vue
<slot>Fallback content</slot>
```

Slot content is not just limited to text. It can be any valid template content. For example, we can pass in multiple elements, or even other components:

```html
<FancyButton>
  <span style="color:red">Click me!</span>
  <AwesomeIcon name="plus" />
</FancyButton>
```

Slot content has access to the data scope of the parent component, because it is
defined in the parent. However, slot content does not have access to the child
component's data. As a rule, remember that everything in the parent template is
compiled in parent scope; everything in the child template is compiled in the
child scope. You can however use child content using [scoped
slots](https://vuejs.org/guide/components/slots.html#scoped-slots).

### [Named Slots](https://vuejs.org/guide/components/slots.html#named-slots)

There are times when it's useful to have multiple slot outlets in a single component.

For these cases, the `<slot>` element has a special attribute, `name`, which can be
used to assign a unique ID to different slots so you can determine where content
should be rendered:

```html
<div class="container">
  <header>
    <slot name="header"></slot>
  </header>
  <main>
    <slot></slot>
  </main>
  <footer>
    <slot name="footer"></slot>
  </footer>
</div>
```

To pass a named slot, we need to use a `<template>` element with the `v-slot`
directive, and then pass the name of the slot as an argument to `v-slot`:

```html
<BaseLayout>
  <template #header>
    <h1>Here might be a page title</h1>
  </template>

  <template #default>
    <p>A paragraph for the main content.</p>
    <p>And another one.</p>
  </template>

  <template #footer>
    <p>Here's some contact info</p>
  </template>
</BaseLayout>
```
Where `#` is the shorthand of `v-slot`.

## Dynamic components

Sometimes, it's useful to dynamically switch between components, like in
a tabbed interface, for example in [this
page](https://sfc.vuejs.org/#eyJBcHAudnVlIjoiPHNjcmlwdD5cbmltcG9ydCBIb21lIGZyb20gJy4vSG9tZS52dWUnXG5pbXBvcnQgUG9zdHMgZnJvbSAnLi9Qb3N0cy52dWUnXG5pbXBvcnQgQXJjaGl2ZSBmcm9tICcuL0FyY2hpdmUudnVlJ1xuICBcbmV4cG9ydCBkZWZhdWx0IHtcbiAgY29tcG9uZW50czoge1xuICAgIEhvbWUsXG4gICAgUG9zdHMsXG4gICAgQXJjaGl2ZVxuICB9LFxuICBkYXRhKCkge1xuICAgIHJldHVybiB7XG4gICAgICBjdXJyZW50VGFiOiAnSG9tZScsXG4gICAgICB0YWJzOiBbJ0hvbWUnLCAnUG9zdHMnLCAnQXJjaGl2ZSddXG4gICAgfVxuICB9XG59XG48L3NjcmlwdD5cblxuPHRlbXBsYXRlPlxuICA8ZGl2IGNsYXNzPVwiZGVtb1wiPlxuICAgIDxidXR0b25cbiAgICAgICB2LWZvcj1cInRhYiBpbiB0YWJzXCJcbiAgICAgICA6a2V5PVwidGFiXCJcbiAgICAgICA6Y2xhc3M9XCJbJ3RhYi1idXR0b24nLCB7IGFjdGl2ZTogY3VycmVudFRhYiA9PT0gdGFiIH1dXCJcbiAgICAgICBAY2xpY2s9XCJjdXJyZW50VGFiID0gdGFiXCJcbiAgICAgPlxuICAgICAge3sgdGFiIH19XG4gICAgPC9idXR0b24+XG5cdCAgPGNvbXBvbmVudCA6aXM9XCJjdXJyZW50VGFiXCIgY2xhc3M9XCJ0YWJcIj48L2NvbXBvbmVudD5cbiAgPC9kaXY+XG48L3RlbXBsYXRlPlxuXG48c3R5bGU+XG4uZGVtbyB7XG4gIGZvbnQtZmFtaWx5OiBzYW5zLXNlcmlmO1xuICBib3JkZXI6IDFweCBzb2xpZCAjZWVlO1xuICBib3JkZXItcmFkaXVzOiAycHg7XG4gIHBhZGRpbmc6IDIwcHggMzBweDtcbiAgbWFyZ2luLXRvcDogMWVtO1xuICBtYXJnaW4tYm90dG9tOiA0MHB4O1xuICB1c2VyLXNlbGVjdDogbm9uZTtcbiAgb3ZlcmZsb3cteDogYXV0bztcbn1cblxuLnRhYi1idXR0b24ge1xuICBwYWRkaW5nOiA2cHggMTBweDtcbiAgYm9yZGVyLXRvcC1sZWZ0LXJhZGl1czogM3B4O1xuICBib3JkZXItdG9wLXJpZ2h0LXJhZGl1czogM3B4O1xuICBib3JkZXI6IDFweCBzb2xpZCAjY2NjO1xuICBjdXJzb3I6IHBvaW50ZXI7XG4gIGJhY2tncm91bmQ6ICNmMGYwZjA7XG4gIG1hcmdpbi1ib3R0b206IC0xcHg7XG4gIG1hcmdpbi1yaWdodDogLTFweDtcbn1cbi50YWItYnV0dG9uOmhvdmVyIHtcbiAgYmFja2dyb3VuZDogI2UwZTBlMDtcbn1cbi50YWItYnV0dG9uLmFjdGl2ZSB7XG4gIGJhY2tncm91bmQ6ICNlMGUwZTA7XG59XG4udGFiIHtcbiAgYm9yZGVyOiAxcHggc29saWQgI2NjYztcbiAgcGFkZGluZzogMTBweDtcbn1cbjwvc3R5bGU+IiwiaW1wb3J0LW1hcC5qc29uIjoie1xuICBcImltcG9ydHNcIjoge1xuICAgIFwidnVlXCI6IFwiaHR0cHM6Ly9zZmMudnVlanMub3JnL3Z1ZS5ydW50aW1lLmVzbS1icm93c2VyLmpzXCJcbiAgfVxufSIsIkhvbWUudnVlIjoiPHRlbXBsYXRlPlxuICA8ZGl2IGNsYXNzPVwidGFiXCI+XG4gICAgSG9tZSBjb21wb25lbnRcbiAgPC9kaXY+XG48L3RlbXBsYXRlPiIsIlBvc3RzLnZ1ZSI6Ijx0ZW1wbGF0ZT5cbiAgPGRpdiBjbGFzcz1cInRhYlwiPlxuICAgIFBvc3RzIGNvbXBvbmVudFxuICA8L2Rpdj5cbjwvdGVtcGxhdGU+IiwiQXJjaGl2ZS52dWUiOiI8dGVtcGxhdGU+XG4gIDxkaXYgY2xhc3M9XCJ0YWJcIj5cbiAgICBBcmNoaXZlIGNvbXBvbmVudFxuICA8L2Rpdj5cbjwvdGVtcGxhdGU+In0=).

The above is made possible by Vue's `<component>` element with the special `is` attribute:

```vue
<!-- Component changes when currentTab changes -->
<component :is="currentTab"></component>
```

In the example above, the value passed to `:is` can contain either:

* The name string of a registered component, OR.
* The actual imported component object.

You can also use the is attribute to create regular HTML elements.

When switching between multiple components with `<component :is="...">`,
a component will be unmounted when it is switched away from. We can force the
inactive components to stay "alive" with the built-in `<KeepAlive>` component.

## [Async components](https://vuejs.org/guide/components/async.html)

In large applications, we may need to divide the app into smaller chunks and
only load a component from the server when it's needed. To make that possible,
Vue has a `defineAsyncComponent` function:

```javascript
import { defineAsyncComponent } from 'vue'

const AsyncComp = defineAsyncComponent(() =>
  import('./components/MyComponent.vue')
)
```

Asynchronous operations inevitably involve loading and error states,
`defineAsyncComponent()` supports handling these states via advanced options:

```javascript
const AsyncComp = defineAsyncComponent({
  // the loader function
  loader: () => import('./Foo.vue'),

  // A component to use while the async component is loading
  loadingComponent: LoadingComponent,
  // Delay before showing the loading component. Default: 200ms.
  delay: 200,

  // A component to use if the load fails
  errorComponent: ErrorComponent,
  // The error component will be displayed if a timeout is
  // provided and exceeded. Default: Infinity.
  timeout: 3000
})
```

# [Testing](https://vuejs.org/guide/scaling-up/testing.html)

When designing your Vue application's testing strategy, you should leverage the following testing types:

* *Unit*: Checks that inputs to a given function, class, or composable are
    producing the expected output or side effects.
* *Component*: Checks that your component mounts, renders, can be interacted
    with, and behaves as expected. These tests import more code than unit tests,
    are more complex, and require more time to execute.
* *End-to-end*: Checks features that span multiple pages and make real network
    requests against your production-built Vue application. These tests often
    involve standing up a database or other backend.

## Unit testing

Unit tests will catch issues with a function's business logic and logical
correctness.

Take for example this increment function:

```javascript
// helpers.js
export function increment (current, max = 10) {
  if (current < max) {
    return current + 1
  }
  return current
}
```

Because it's very self-contained, it'll be easy to invoke the `increment`
function and assert that it returns what it's supposed to, so we'll write a Unit
Test.

If any of these assertions fail, it's clear that the issue is contained within
the `increment` function.

```javascript
// helpers.spec.js
import { increment } from './helpers'

describe('increment', () => {
  test('increments the current number by 1', () => {
    expect(increment(0, 10)).toBe(1)
  })

  test('does not increment the current number over the max', () => {
    expect(increment(10, 10)).toBe(10)
  })

  test('has a default max of 10', () => {
    expect(increment(10)).toBe(10)
  })
})
```

Unit testing is typically applied to self-contained business logic, components,
classes, modules, or functions that do not involve UI rendering, network
requests, or other environmental concerns.

These are typically plain JavaScript / TypeScript modules unrelated to Vue. In
general, writing unit tests for business logic in Vue applications does not
differ significantly from applications using other frameworks.

There are two instances where you DO unit test Vue-specific features:

* [Composables](https://vuejs.org/guide/scaling-up/testing.html#testing-composables)
* [Components](#component-testing)

## Component testing

In Vue applications, components are the main building blocks of the UI.
Components are therefore the natural unit of isolation when it comes to
validating your application's behavior. From a granularity perspective,
component testing sits somewhere above unit testing and can be considered a form
of integration testing. Much of your Vue Application should be covered by
a component test and we recommend that each Vue component has its own spec
file.

Component tests should catch issues relating to your component's props, events,
slots that it provides, styles, classes, lifecycle hooks, and more.

Component tests should not mock child components, but instead test the
interactions between your component and its children by interacting with the
components as a user would. For example, a component test should click on an
element like a user would instead of programmatically interacting with the
component.

Component tests should focus on the component's public interfaces rather than
internal implementation details. For most components, the public interface is
limited to: events emitted, props, and slots. When testing, remember to *test
what a component does, not how it does it*. For example:

* For Visual logic assert correct render output based on inputted props and
    slots.
* For Behavioral logic: assert correct render updates or emitted events in
    response to user input events.

The recommendation is to use [Vitest](vitest.md) for components or
composables that render headlessly, and [Cypress Component
Testing](https://on.cypress.io/component) for components whose expected behavior
depends on properly rendering styles or triggering native DOM event.

The main differences between Vitest and browser-based runners are speed and
execution context. In short, browser-based runners, like Cypress, can catch
issues that node-based runners, like Vitest, cannot (e.g. style issues, real
native DOM events, cookies, local storage, and network failures), but
browser-based runners are orders of magnitude slower than Vitest because they do
open a browser, compile your stylesheets, and more.

Component testing often involves mounting the component being tested in
isolation, triggering simulated user input events, and asserting on the rendered
DOM output. There are dedicated utility libraries that make these tasks
simpler.

* [`@testing-library/vue`](https://github.com/testing-library/vue-testing-library) is a Vue testing library focused on testing components
    without relying on implementation details. Built with accessibility in mind,
    its approach also makes refactoring a breeze. Its guiding principle is that
    the more tests resemble the way software is used, the more confidence they
    can provide.

* `@vue/test-utils` is the official low-level component testing library that was
    written to provide users access to Vue specific APIs. It's also the
    lower-level library `@testing-library/vue` is built on top of.

We recommend using `@testing-library/vue` for testing components in
applications, as its focus aligns better with the testing priorities of
applications. Use `@vue/test-utils` only if you are building advanced components
that require testing Vue-specific internals.

### Writing component tests

Tests live in `spec` files under the `__tests__` directory. You usually have
a test file for each component with the next structure. For example

```html
<template>
  <div>
    <p>Times clicked: {{ count }}</p>
    <button @click="increment">increment</button>
  </div>
</template>

<script>
  export default {
    data: () => ({
      count: 0,
    }),

    methods: {
      increment() {
        this.count++
      },
    },
  }
</script>
```

```javascript
import {test} from 'vitest'
import {render, fireEvent} from '@testing-library/vue'
import Component from './Component.vue'

test('increments value on click', async () => {
  // The render method returns a collection of utilities to query your component.
  const {getByText} = render(Component)

  // getByText returns the first matching node for the provided text, and
  // throws an error if no elements match or if more than one match is found.
  getByText('Times clicked: 0')

  const button = getByText('increment')

  // Dispatch a native click event to our button element.
  await fireEvent.click(button)
  await fireEvent.click(button)

  getByText('Times clicked: 2')
})
```

#### [Testing queries](https://testing-library.com/docs/queries/about)

Queries are the methods that Testing Library gives you to find elements on the
page. Depending on what page content you are selecting, different queries may be
more or less appropriate.

After selecting an element, you can use the Events API or user-event to fire
events and simulate user interactions with the page.

As elements appear and disappear in response to actions, Async APIs like
`waitFor` or `findBy` queries can be used to await the changes in the DOM. To find only
elements that are children of a specific element, you can use `within`.

##### Types of queries

The different types of queries are:

* Single Elements
    * `getBy...`: Returns the matching node for a query, and throw a descriptive
        error if no elements match or if more than one match is found.
    * `queryBy...`: Returns the matching node for a query, and return `null` if no
        elements match. This is useful for asserting an element that is not
        present. Throws an error if more than one match is found (use
        `queryAllBy` instead if this is OK).
    * `findBy...`: Returns a `Promise` which resolves when an element is found
        which matches the given query. The promise is rejected if no element is
        found or if more than one element is found after a default timeout of
        1000ms. If you need to find more than one element, use `findAllBy`.

* Multiple Elements
    * `getAllBy...`: Returns an array of all matching nodes for a query, and
        throws an error if no elements match.
    * `queryAllBy...`: Returns an array of all matching nodes for a query, and
        return an empty array ([]) if no elements match.
    * `findAllBy...`: Returns a promise which resolves to an array of elements
        when any elements are found which match the given query. The promise is
        rejected if no elements are found after a default timeout of 1000ms.

        `findBy` method`s are a combination of `getBy*` queries and `waitFor`. They
        accept the `waitFor` options as the last argument (i.e. `await
        screen.findByText('text', queryOptions, waitForOptions)`)

Your test should resemble how users interact with your code (component, page,
etc.) as much as possible. With this in mind, we recommend this order of
priority:

1. *Queries Accessible to Everyone* Queries that reflect the experience of
   visual/mouse users as well as those that use assistive technology.
    * `getByRole`: This can be used to query every element that is exposed in
        the accessibility tree. With the name option you can filter the returned
        elements by their accessible name. This should be your top preference
        for just about everything. There's not much you can't get with this (if
        you can't, it's possible your UI is inaccessible). Most often, this will
        be used with the name option like so: `getByRole('button', {name:
        /submit/i})`. Check the [list of roles](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/ARIA_Techniques#roles).
    * `getByLabelText`: This method is really good for form fields. When
        navigating through a website form, users find elements using label text.
        This method emulates that behavior, so it should be your top preference.
    * `getByPlaceholderText`: A placeholder is not a substitute for a label. But
        if that's all you have, then it's better than alternatives.
    * `getByText`: Outside of forms, text content is the main way users find
        elements. This method can be used to find non-interactive elements (like
        divs, spans, and paragraphs).
    * `getByDisplayValue`: The current value of a form element can be useful
        when navigating a page with filled-in values.

2. *Semantic Queries* HTML5 and ARIA compliant selectors. Note that the user
   experience of interacting with these attributes varies greatly across
   browsers and assistive technology.
    * `getByAltText`: If your element is one which supports alt text (`img`,
        `area`, `input`, and any custom element), then you can use this to find that
        element.
    * `getByTitle`: The title attribute is not consistently read by
        screenreaders, and is not visible by default for sighted users

3. *Test IDs*
    * `getByTestId`: The user cannot see (or hear) these, so this is only
        recommended for cases where you can't match by role or text or it
        doesn't make sense (e.g. the text is dynamic).

##### [Using queries](https://testing-library.com/docs/queries/about#using-queries)

The base queries from DOM Testing Library require you to pass a container as the
first argument, which is a `TextMatch` element that can be a string, regular
expression, or function. Given the following HTML:

```html
<div>Hello World</div>
```

Will find the div:

```javascript
// Matching a string:
getByText('Hello World') // full string match
getByText('llo Worl', {exact: false}) // substring match
getByText('hello world', {exact: false}) // ignore case

// Matching a regex:
getByText(/World/) // substring match
getByText(/world/i) // substring match, ignore case
getByText(/^hello world$/i) // full string match, ignore case
getByText(/Hello W?oRlD/i) // substring match, ignore case, searches for "hello world" or "hello orld"

// Matching with a custom function:
getByText((content, element) => content.startsWith('Hello'))
```

If you want some help knowing how to define the Query, you can install the
[Testing
Playground](https://addons.mozilla.org/en-US/firefox/addon/testing-playground/)
addon, which adds a tab in the developer tools to help you choose the best
selector.

## E2E Testing

While unit tests provide developers with some degree of confidence, unit and
component tests are limited in their abilities to provide holistic coverage of
an application when deployed to production. As a result, end-to-end (E2E) tests
provide coverage on what is arguably the most important aspect of an
application: what happens when users actually use your applications.

End-to-end tests focus on multi-page application behavior that makes network
requests against your production-built Vue application. They often involve
standing up a database or other backend and may even be run against a live
staging environment.

End-to-end tests will often catch issues with your router, state management
library, top-level components (e.g. an App or Layout), public assets, or any
request handling. As stated above, they catch critical issues that may be
impossible to catch with unit tests or component tests.

End-to-end tests do not import any of your Vue application's code, but instead
rely completely on testing your application by navigating through entire pages
in a real browser.

End-to-end tests validate many of the layers in your application. They can
either target your locally built application, or even a live Staging
environment. Testing against your Staging environment not only includes your
frontend code and static server, but all associated backend services and
infrastructure.

### E2E tests decissions

When doing E2E tests keep in mind:

* Cross-browser testing: One of the primary benefits that end-to-end (E2E)
    testing is known for is its ability to test your application across multiple
    browsers. While it may seem desirable to have 100% cross-browser coverage,
    it is important to note that cross browser testing has diminishing returns
    on a team's resources due the additional time and machine power required to
    run them consistently. As a result, it is important to be mindful of this
    trade-off when choosing the amount of cross-browser testing your application
    needs.

* Faster feedback loops: One of the primary problems with end-to-end (E2E) tests
    and development is that running the entire suite takes a long time.
    Typically, this is only done in continuous integration and deployment
    (CI/CD) pipelines. Modern E2E testing frameworks have helped to solve this
    by adding features like parallelization, which allows for CI/CD pipelines to
    often run magnitudes faster than before. In addition, when developing
    locally, the ability to selectively run a single test for the page you are
    working on while also providing hot reloading of tests can help to boost
    a developer's workflow and productivity.

* Visibility in headless mode: When end-to-end (E2E) tests are run in continuous
    integration / deployment pipelines, they are often run in headless browsers
    (i.e., no visible browser is opened for the user to watch). A critical
    feature of modern E2E testing frameworks is the ability to see snapshots
    and/or videos of the application during testing, providing some insight into
    why errors are happening. Historically, it was tedious to maintain these
    integrations.

Vue developers suggestion is to use [Cypress](https://www.cypress.io/) as it
provides the most complete E2E solution with features like an informative
graphical interface, excellent debuggability, built-in assertions and stubs,
flake-resistance, parallelization, and snapshots. It also provides support for
Component Testing. However, it only supports Chromium-based browsers and
Firefox.

## Installation

In a Vite-based Vue project, run:

```bash
npm install -D vitest happy-dom @testing-library/vue@next
```

Next, update the Vite configuration to add the test option block:

```javascript
// vite.config.js
import { defineConfig } from 'vite'

export default defineConfig({
  // ...
  test: {
    // enable jest-like global test APIs
    globals: true,
    // simulate DOM with happy-dom
    // (requires installing happy-dom as a peer dependency)
    environment: 'happy-dom'
  }
})
```

Then create a file ending in `*.test.js` in your project. You can place all test
files in a test directory in project root, or in test directories next to your
source files. Vitest will automatically search for them using the naming
convention.

```javascript
// MyComponent.test.js
import { render } from '@testing-library/vue'
import MyComponent from './MyComponent.vue'

test('it should work', () => {
  const { getByText } = render(MyComponent, {
    props: {
      /* ... */
    }
  })

  // assert output
  getByText('...')
})
```

Finally, update `package.json` to add the test script and run it:

```json
{
  // ...
  "scripts": {
    "test": "vitest"
  }
}
```

```bash
npm test
```

# References

* [Homepage](https://vuejs.org)
* [Tutorial](https://vuejs.org/tutorial/#step-1)
* [Examples](https://vuejs.org/examples/#hello-world)
