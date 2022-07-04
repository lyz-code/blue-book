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

You can use also [environment variables](#environment-variables)

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

## Environment variables

If you're using Vue 3 and Vite you can use [the environment
variables](https://vitejs.dev/guide/env-and-mode.html) by defining them in
`.env` files.

You can specify environment variables by placing the following files in your
project root:

* `.env`: Loaded in all cases.
* `.env.local`: Loaded in all cases, ignored by git.
* `.env.[mode]`: Only loaded in specified mode.
* `.env.[mode].local`: Only loaded in specified mode, ignored by git.

An env file simply contains `key=value` pairs of environment variables, by
default only variables that start with `VITE_` will be exposed.:

```
DB_PASSWORD=foobar
VITE_SOME_KEY=123
```

Only `VITE_SOME_KEY` will be exposed as `import.meta.env.VITE_SOME_KEY` to your
client source code, but `DB_PASSWORD` will not. So for example in a component
you can use:

```vue
export default {
  props: {},
  mounted() {
    console.log(import.meta.env.VITE_SOME_KEY)
  },
  data: () => ({
  }),
}
```

## [Make HTTP requests](https://blog.bitsrc.io/requests-in-vuejs-fetch-api-and-axios-a-comparison-a0c13f241888)

There are many ways to do requests to external services:

* [Fetch API](#fetch-api)
* [Axios](#axios)

### Fetch API

The Fetch API is a standard API for making HTTP requests on the browser.

It a great alternative to the old `XMLHttpRequestconstructor` for making
requests.

It supports all kinds of requests, including GET, POST, PUT, PATCH, DELETE, and
OPTIONS, which is what most people need.

To make a request with the Fetch API, we don’t have to do anything. All we have
to do is to make the request directly with the `fetch` object. For instance, you
can write:

```html
<template>
  <div id="app">
    {{data}}
  </div>
</template><script>export default {
  name: "App",
  data() {
    return {
      data: {}
    }
  },
  beforeMount(){
    this.getName();
  },
  methods: {
    async getName(){
      const res = await fetch('https://api.agify.io/?name=michael');
      const data = await res.json();
      this.data = data;
    }
  }
};
</script>
```

In the code above, we made a simple GET request from an API and then convert the
data from JSON to a JavaScript object with the `json()` method.

#### Adding headers

Like most HTTP clients, we can send request headers and bodies with the Fetch API.

To send a request with HTTP headers, we can write:

```html
<template>
  <div id="app">
    <img :src="data.src.tiny">
  </div>
</template><script>
export default {
  name: "App",
  data() {
    return {
      data: {
        src: {}
      }
    };
  },
  beforeMount() {
    this.getPhoto();
  },
  methods: {
    async getPhoto() {
      const headers = new Headers();
      headers.append(
        "Authorization",
        "api_key"
      );
      const request = new Request(
        "https://api.pexels.com/v1/curated?per_page=11&page=1",
        {
          method: "GET",
          headers,
          mode: "cors",
          cache: "default"
        }
      );      const res = await fetch(request);
      const { photos } = await res.json();
      this.data = photos[0];
    }
  }
};
</script>
```

In the code above, we used the `Headers` constructor, which is used to add
requests headers to Fetch API requests.

The append method appends our 'Authorization' header to the request.

We’ve to set the mode to 'cors' for a cross-domain request and headers is set to
the headers object returned by the `Headers` constructor.

#### Adding body to a request

To make a request body, we can write the following:

```html
<template>
  <div id="app">
    <form @submit.prevent="createPost">
      <input placeholder="name" v-model="post.name">
      <input placeholder="title" v-model="post.title">
      <br>
      <button type="submit">Create</button>
    </form>
    {{data}}
  </div>
</template><script>
export default {
  name: "App",
  data() {
    return {
      post: {},
      data: {}
    };
  },
  methods: {
    async createPost() {
      const request = new Request(
        "https://jsonplaceholder.typicode.com/posts",
        {
          method: "POST",
          mode: "cors",
          cache: "default",
          body: JSON.stringify(this.post)
        }
      );      const res = await fetch(request);
      const data = await res.json();
      this.data = data;
    }
  }
};
</script>
```

In the code above, we made the request by stringifying the this.post object and
then sending it with a POST request.

### [Axios](https://axios-http.com/)

Axios is a popular HTTP client that works on both browser and Node.js apps.

We can install it by running:

```bash
npm i axios
```

Then we can use it to make requests a simple GET request as follows:

```html
<template>
  <div id="app">{{data}}</div>
</template><script>

import axios from 'axios'

export default {
  name: "App",
  data() {
    return {
      data: {}
    };
  },
  beforeMount(){
    this.getName();
  },
  methods: {
    async getName(){
      const { data } = await axios.get("https://api.agify.io/?name=michael");
      this.data = data;
    }
  }
};
</script>
```

In the code above, we call the `axios.get` method with the URL to make the request.

Then we assign the response data to an object.

#### Adding headers

If we want to make a request with headers, we can write:

```html
<template>
  <div id="app">
    <img :src="data.src.tiny">
  </div>
</template><script>

import axios from 'axios'

export default {
  name: "App",
  data() {
    return {
      data: {}
    };
  },
  beforeMount() {
    this.getPhoto();
  },
  methods: {
    async getPhoto() {
      const {
        data: { photos }
      } = await axios({
        url: "https://api.pexels.com/v1/curated?per_page=11&page=1",
        headers: {
          Authorization: "api_key"
        }
      });
      this.data = photos[0];
    }
  }
};
</script>
```

In the code above, we made a GET request with our Pexels API key with the axios
method, which can be used for making any kind of request.

If no request verb is specified, then it’ll be a GET request.

As we can see, the code is a bit shorter since we don’t have to create an object
with the `Headers` constructor.

If we want to set the same header in multiple requests, we can use a request
interceptor to set the header or other config for all requests.

For instance, we can rewrite the above example as follows:

```javascript
// main.js:

import Vue from "vue";
import App from "./App.vue";
import axios from 'axios'

axios.interceptors.request.use(
  config => {
    return {
      ...config,
      headers: {
        Authorization: "api_key"
      }
    };
  },
  error => Promise.reject(error)
);

Vue.config.productionTip = false;

new Vue({
  render: h => h(App)
}).$mount("#app");
```

```html
<template>
  <div id="app">
    <img :src="data.src.tiny">
  </div>
</template><script>

import axios from 'axios'

export default {
  name: "App",
  data() {
    return {
      data: {}
    };
  },
  beforeMount() {
    this.getPhoto();
  },
  methods: {
    async getPhoto() {
      const {
        data: { photos }
      } = await axios({
        url: "https://api.pexels.com/v1/curated?per_page=11&page=1"
      });
      this.data = photos[0];
    }
  }
};
</script>

We moved the header to `main.js` inside the code for our interceptor.

The first argument that’s passed into `axios.interceptors.request.use` is
a function for modifying the request config for all requests.

And the 2nd argument is an error handler for handling error of all requests.

Likewise, we can configure interceptors for responses as well.

#### Adding body to a request

To make a POST request with a request body, we can use the `axios.post` method.

```html
<template>
  <div id="app">
    <form @submit.prevent="createPost">
      <input placeholder="name" v-model="post.name">
      <input placeholder="title" v-model="post.title">
      <br>
      <button type="submit">Create</button>
    </form>
    {{data}}
  </div>
</template><script>

import axios from 'axios'

export default {
  name: "App",
  data() {
    return {
      post: {},
      data: {}
    };
  },
  methods: {
    async createPost() {
      const { data } = await axios.post(
        "https://jsonplaceholder.typicode.com/posts",
        this.post
      );
      this.data = data;
    }
  }
};
</script>
```

We make the POST request with the `axios.post` method with the request body in
the second argument. Axios also sets the Content-Type header to
application/json. This enables web frameworks to automatically parse the data.

Then we get back the response data by getting the data property from the resulting response.

#### [Shorthand methods for Axios HTTP requests](https://blog.logrocket.com/how-to-make-http-requests-like-a-pro-with-axios/#shorthand)

Axios also provides a set of shorthand methods for performing different types of
requests. The methods are as follows:

* `axios.request(config)`
* `axios.get(url[, config])`
* `axios.delete(url[, config])`
* `axios.head(url[, config])`
* `axios.options(url[, config])`
* `axios.post(url[, data[, config]])`
* `axios.put(url[, data[, config]])`
* `axios.patch(url[, data[, config]])`

For instance, the following code shows how the previous example could be written
using the `axios.post()` method:

```javascript
axios.post('/login', {
  firstName: 'Finn',
  lastName: 'Williams'
})
.then((response) => {
  console.log(response);
}, (error) => {
  console.log(error);
});
```

Once an HTTP POST request is made, Axios returns a promise that is either
fulfilled or rejected, depending on the response from the backend service.

To handle the result, you can use the `then()`. method. If the promise is
fulfilled, the first argument of `then()` will be called; if the promise is
rejected, the second argument will be called. According to the documentation,
the fulfillment value is an object containing the following information:

```javascript
{
  // `data` is the response that was provided by the server
  data: {},

  // `status` is the HTTP status code from the server response
  status: 200,

  // `statusText` is the HTTP status message from the server response
  statusText: 'OK',

  // `headers` the headers that the server responded with
  // All header names are lower cased
  headers: {},

  // `config` is the config that was provided to `axios` for the request
  config: {},

  // `request` is the request that generated this response
  // It is the last ClientRequest instance in node.js (in redirects)
  // and an XMLHttpRequest instance the browser
  request: {}
}
```

#### Using interceptors

One of the key features of Axios is its ability to intercept HTTP requests. HTTP
interceptors come in handy when you need to examine or change HTTP requests from
your application to the server or vice versa (e.g., logging, authentication, or
retrying a failed HTTP request).

With interceptors, you won’t have to write separate code for each HTTP request.
HTTP interceptors are helpful when you want to set a global strategy for how you
handle request and response.

```javascript
axios.interceptors.request.use(config => {
  // log a message before any HTTP request is sent
  console.log('Request was sent');

  return config;
});

// sent a GET request
axios.get('https://api.github.com/users/sideshowbarker')
  .then(response => {
    console.log(response.data);
  });
```

In this code, the `axios.interceptors.request.use()` method is used to define
code to be run before an HTTP request is sent. Also,
`axios.interceptors.response.use()` can be used to intercept the response from the
server. Let’s say there is a network error; using the response interceptors, you
can retry that same request using interceptors.

#### [Handling errors](https://stackabuse.com/handling-errors-with-axios/)

To catch errors when doing requests you could use:

```javascript
try {
    let res = await axios.get('/my-api-route');

    // Work with the response...
} catch (error) {
    if (error.response) {
        // The client was given an error response (5xx, 4xx)
        console.log(err.response.data);
        console.log(err.response.status);
        console.log(err.response.headers);
    } else if (error.request) {
        // The client never received a response, and the request was never left
        console.log(err.request);
    } else {
        // Anything else
        console.log('Error', err.message);
    }
}
```

The differences in the `error` object, indicate where the request encountered the issue.

* `error.response`: If your `error` object has a `response` property, it means
    that your server returned a 4xx/5xx error. This will assist you choose what
    sort of message to return to users.

* `error.request`: This error is caused by a network error, a hanging backend
    that does not respond instantly to each request, unauthorized or
    cross-domain requests, and lastly if the backend API returns an error.

    This occurs when the browser was able to initiate a request but did not
    receive a valid answer for any reason.

* Other errors: It's possible that the `error` object does not have either
    a `response` or `request` object attached to it. In this case it is implied that
    there was an issue in setting up the request, which eventually triggered an
    error.

    For example, this could be the case if you omit the URL parameter from the
    `.get()` call, and thus no request was ever made.

#### Sending multiple requests

One of Axios’ more interesting features is its ability to make multiple requests
in parallel by passing an array of arguments to the `axios.all()` method. This
method returns a single promise object that resolves only when all arguments
passed as an array have resolved.

Here’s a simple example of how to use `axios.all` to make simultaneous HTTP requests:

```javascript
// execute simultaneous requests
axios.all([
  axios.get('https://api.github.com/users/mapbox'),
  axios.get('https://api.github.com/users/phantomjs')
])
.then(responseArr => {
  //this will be executed only when all requests are complete
  console.log('Date created: ', responseArr[0].data.created_at);
  console.log('Date created: ', responseArr[1].data.created_at);
});

// logs:
// => Date created:  2011-02-04T19:02:13Z
// => Date created:  2017-04-03T17:25:46Z
```

This code makes two requests to the GitHub API and then logs the value of the
`created_at` property of each response to the console. Keep in mind that if any of
the arguments rejects then the promise will immediately reject with the reason
of the first promise that rejects.

For convenience, Axios also provides a method called `axios.spread()` to assign
the properties of the response array to separate variables. Here’s how you could
use this method:

```javascript
axios.all([
  axios.get('https://api.github.com/users/mapbox'),
  axios.get('https://api.github.com/users/phantomjs')
])
.then(axios.spread((user1, user2) => {
  console.log('Date created: ', user1.data.created_at);
  console.log('Date created: ', user2.data.created_at);
}));

// logs:
// => Date created:  2011-02-04T19:02:13Z
// => Date created:  2017-04-03T17:25:46Z
```

The output of this code is the same as the previous example. The only difference
is that the `axios.spread()` method is used to unpack values from the response
array.

### Veredict

If you’re working on multiple requests, you’ll find that Fetch requires you to
write more code than Axios, even when taking into consideration the setup needed
for it. Therefore, for simple requests, Fetch API and Axios are quite the same.
However, for more complex requests, Axios is better as it allows you to
configure multiple requests in one place.

If you're making a simple request use the Fetch API, for the other cases use axios because:

* It allows you to configure multiple requests in one place
* Code is shorter.
* It allows you to [place all the API calls under services so that these can be
    reused across components wherever they are
    needed](https://medium.com/bb-tutorials-and-thoughts/how-to-make-api-calls-in-vue-js-applications-43e017d4dc86).
* It's easy to set a timeout of the request.
* It supports HTTP interceptors by befault
* It does automatic JSON data transformation.
* It's supported by old browsers, although you can bypass the problem with fetch
    too.
* It has a progress indicator for large files.
* Supports simultaneous requests by default.

Axios provides an easy-to-use API in a compact package for most of your HTTP
communication needs. However, if you prefer to stick with native APIs, nothing
stops you from implementing Axios features.

For more information read:

* [How To Make API calls in Vue.JS Applications by Bhargav Bachina](https://medium.com/bb-tutorials-and-thoughts/how-to-make-api-calls-in-vue-js-applications-43e017d4dc86)
* [Axios vs. fetch(): Which is best for making HTTP requests? by Faraz
    Kelhini](https://blog.logrocket.com/axios-vs-fetch-best-http-requests/)

## [Vue Router](https://router.vuejs.org/guide/)

Creating a Single-page Application with Vue + Vue Router feels natural, all we
need to do is map our components to the routes and let Vue Router know where to
render them. Here's a basic example:

```html
<script src="https://unpkg.com/vue@3"></script>
<script src="https://unpkg.com/vue-router@4"></script>

<div id="app">
  <h1>Hello App!</h1>
  <p>
    <!-- use the router-link component for navigation. -->
    <!-- specify the link by passing the `to` prop. -->
    <!-- `<router-link>` will render an `<a>` tag with the correct `href` attribute -->
    <router-link to="/">Go to Home</router-link>
    <router-link to="/about">Go to About</router-link>
  </p>
  <!-- route outlet -->
  <!-- component matched by the route will render here -->
  <router-view></router-view>
</div>
```

Note how instead of using regular `a` tags, we use a custom component
`router-link` to create links. This allows Vue Router to change the URL without reloading the
page, handle URL generation as well as its encoding.

`router-view` will display the component that corresponds to the url. You can
put it anywhere to adapt it to your layout.

```javascript
// 1. Define route components.
// These can be imported from other files
const Home = { template: '<div>Home</div>' }
const About = { template: '<div>About</div>' }

// 2. Define some routes
// Each route should map to a component.
// We'll talk about nested routes later.
const routes = [
  { path: '/', component: Home },
  { path: '/about', component: About },
]

// 3. Create the router instance and pass the `routes` option
// You can pass in additional options here, but let's
// keep it simple for now.
const router = VueRouter.createRouter({
  // 4. Provide the history implementation to use. We are using the hash history for simplicity here.
  history: VueRouter.createWebHashHistory(),
  routes, // short for `routes: routes`
})

// 5. Create and mount the root instance.
const app = Vue.createApp({})
// Make sure to _use_ the router instance to make the
// whole app router-aware.
app.use(router)

app.mount('#app')

// Now the app has started!
```

By calling `app.use(router)`, we get access to it as `this.$router` as well as
the current route as `this.$route` inside of any component:

```vue
// Home.vue
export default {
  computed: {
    username() {
      // We will see what `params` is shortly
      return this.$route.params.username
    },
  },
  methods: {
    goToDashboard() {
      if (isAuthenticated) {
        this.$router.push('/dashboard')
      } else {
        this.$router.push('/login')
      }
    },
  },
}
```

To access the router or the route inside the `setup` function, call the
`useRouter` or `useRoute` functions.

### [Dynamic route matching with params](https://router.vuejs.org/guide/essentials/dynamic-matching.html)

Very often we will need to map routes with the given pattern to the same
component. For example we may have a User component which should be rendered for
all users but with different user IDs. In Vue Router we can use a dynamic
segment in the path to achieve that, we call that a `param`:

```javascript
const User = {
  template: '<div>User</div>',
}

// these are passed to `createRouter`
const routes = [
  // dynamic segments start with a colon
  { path: '/users/:id', component: User },
]
```

Now URLs like `/users/johnny` and `/users/jolyne` will both map to the same
route.

A `param` is denoted by a colon `:.` When a route is matched, the value of its
params will be exposed as `this.$route.params` in every component. Therefore, we
can render the current user ID by updating User's template to this:

```html
const User = {
  template: '<div>User {{ $route.params.id }}</div>',
}
```

You can have multiple `params` in the same route, and they will map to
corresponding fields on `$route.params`. Examples:

| pattern                        | matched path             | $route.params                          |
| ---                            | ---                      | ---                                    |
| /users/:username               | /users/eduardo           | { username: 'eduardo' }                |
| /users/:username/posts/:postId | /users/eduardo/posts/123 | { username: 'eduardo', postId: '123' } |

In addition to `$route.params`, the `$route` object also exposes other useful
information such as `$route.query` (if there is a query in the URL),
`$route.hash`, etc.

#### Reacting to params changes

One thing to note when using routes with params is that when the user navigates
from `/users/johnny` to `/users/jolyne`, the same component instance will be reused.
Since both routes render the same component, this is more efficient than
destroying the old instance and then creating a new one. However, this also
means that the lifecycle hooks of the component will not be called.

To react to `params` changes in the same component, you can simply `watch`
anything on the `$route` object, in this scenario, the `$route.params`:

```javascript
const User = {
  template: '...',
  created() {
    this.$watch(
      () => this.$route.params,
      (toParams, previousParams) => {
        // react to route changes...
      }
    )
  },
}
```

Or, use the `beforeRouteUpdate` navigation guard, which also allows to cancel the navigation:

```javascript
const User = {
  template: '...',
  async beforeRouteUpdate(to, from) {
    // react to route changes...
    this.userData = await fetchUser(to.params.id)
  },
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

I recommend using [cypress](cypress.md) so that you can use the same language
either you are doing E2E tests or unit tests.

If you're using [Vuetify](vuetify.md) don't try to do component testing, I've
tried for days and [was unable to make it work](vuetify.md#testing).

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

### E2E tests decisions

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

# [Deploying](https://medium.com/js-dojo/vue-js-runtime-environment-variables-807fa8f68665)

It is common these days to run front-end and back-end services inside Docker
containers. The front-end service usually talks using a API with the back-end
service.

```dockerfile
FROM node as ui-builder
RUN mkdir /usr/src/app
WORKDIR /usr/src/app
ENV PATH /usr/src/app/node_modules/.bin:$PATH
COPY package.json /usr/src/app/package.json
RUN npm install
RUN npm install -g @vue/cli
COPY . /usr/src/app
RUN npm run build

FROM nginx
COPY  --from=ui-builder /usr/src/app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

The above makes use of the multi-stage build feature of Docker. The first half
of the Dockerfile build the artifacts and second half use those artifacts and
create a new image from them.

To build the production image, run:

```bash
docker build -t myapp .
```

You can run the container by executing the following command:

```bash
docker run -it -p 80:80 --rm myapp-prod
```

The application will now be accessible at `http://localhost`.

## Configuration through environmental variables

In production you want to be able to scale up or down the frontend and the
backend independently, to be able to do that you usually have one or many docker
for each role. Usually there is an SSL Proxy that acts as gate keeper and is the
only component exposed to the public.

If the user requests for `/api` it will forward the requests to the backend, if
it asks for any other url it will forward it to the frontend.

!!! note
        "You probably don't need to configure the backend api url as an environment
        variable see
        [here](frontend_development.md#your-frontend-probably-doesn't-talk-to-your-backend)
        why."

For the frontend, we need to configure the application. This is usually done
through [environmental
variables](#configuration-through-environmental-variables), such as
`EXTERNAL_BACKEND_URL`. The problem is that these environment variables are set at build
time, and can't be changed at runtime by default, so you can't offer a generic
fronted Docker and particularize for the different cases. I've literally cried
for hours trying to find a solution for this until [José Silva came to my
rescue](https://medium.com/js-dojo/vue-js-runtime-environment-variables-807fa8f68665).
The tweak is to use a docker entrypoint to inject the values we want. To do so
you need to:

* Edit the site main `index.html` (if you use Vite is in `/index.html` otherwise
    it might be at `public/index.html` to add a placeholder that will be
    replaced by the dynamic configurations.

    ```html
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <script>
          // CONFIGURATIONS_PLACEHOLDER
        </script>
        ...
    ```

* Create an executable file named `entrypoint.sh` in the root of the project.

    ```bash
    #!/bin/sh

    JSON_STRING='window.configs = { \
      "VITE_APP_VARIABLE_1":"'"${VITE_APP_VARIABLE_1}"'", \
      "VITE_APP_VARIABLE_2":"'"${VITE_APP_VARIABLE_2}"'" \
    }'

    sed -i "s@// CONFIGURATIONS_PLACEHOLDER@${JSON_STRING}@" /usr/share/nginx/html/index.html

    exec "$@"
    ```

    Its function is to replace the placeholder in the index.html by the
    configurations, injecting them in the browser window.

* Create a file named `src/utils/env.js` with the following utility function:

    ```javascript
    export default function getEnv(name) {
      return window?.configs?.[name] || process.env[name]
    }
    ```

    Which allows us to easily get the value of the configuration. If it exists
    in `window.configs` (used in remote environments like staging or production)
    it will have priority over the `process.env` (used for development).

* Replace the content of the `App.vue` file with the following:

    ```html
    <template>
      <div id="app">
        <img alt="Vue logo" src="./assets/logo.png">
        <div>{{ variable1 }}</div>
        <div>{{ variable2 }}</div>
      </div>
    </template>

    <script>
    import getEnv from '@/utils/env'export default {
      name: 'App',
      data() {
        return {
          variable1: getEnv('VITE_APP_VARIABLE_1'),
          variable2: getEnv('VITE_APP_VARIABLE_2')
        }
      }
    }
    </script>
    ```

    At this point, if you create the `.env.local` file, in the root of the project,
    with the values for the printed variables:

    ```
    VITE_APP_VARIABLE_1='I am the develoment variable 1'
    VITE_APP_VARIABLE_2='I am the develoment variable 2'
    ```

    And run the development server `npm run dev` you should see those values printed
    in the application (http://localhost:8080).

* Update the `Dockerfile` to load the `entrypoint.sh`.

    ```dockerfile
    FROM node as ui-builder
    RUN mkdir /usr/src/app
    WORKDIR /usr/src/app
    ENV PATH /usr/src/app/node_modules/.bin:$PATH
    COPY package.json /usr/src/app/package.json
    RUN npm install
    RUN npm install -g @vue/cli
    COPY . /usr/src/app
    ARG VUE_APP_API_URL
    ENV VUE_APP_API_URL $VUE_APP_API_URL
    RUN npm run build

    FROM nginx
    COPY  --from=ui-builder /usr/src/app/dist /usr/share/nginx/html
    COPY entrypoint.sh /usr/share/nginx/
    ENTRYPOINT ["/usr/share/nginx/entrypoint.sh"]
    EXPOSE 80
    CMD ["nginx", "-g", "daemon off;"]
    ```

* Build the docker

    ```bash
    docker build -t my-app .
    ```

Now if you have a `.env.production.local` file with the next contents:

```
VITE_APP_VARIABLE_1='I am the production variable 1'
VITE_APP_VARIABLE_2='I am the production variable 2'
```

And run `docker run -it -p 80:80 --env-file=.env.production.local --rm my-app`,
you'll see the values of the production variables. You can also pass the
variables directly with `-e VITE_APP_VARIABLE_1="Overriden variable"`.

## [Deploy static site on github pages](https://github.com/sitek94/vite-deploy-demo)

Sites in Github pages have the url structure of
`https://github_user.github.io/repo_name/` we need to tell vite that the base
url is `/repo_name/`, otherwise the application will try to load the assets in
`https://github_user.github.io/assets/` instead of
`https://github_user.github.io/rpeo_name/assets/`.

To change it, add in the `vite.config.js` file:

```javascript
export default defineConfig({
  base: '/repo_name/'
})
```

Now you need to configure the deployment workflow, to do so, create a new file:
`.github/workflows/deploy.yml` and paste the following code:

```yaml
---
name: Deploy

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repo
        uses: actions/checkout@v2

      - name: Setup Node
        uses: actions/setup-node@v1
        with:
          node-version: 16

      - name: Install dependencies
        uses: bahmutov/npm-install@v1

      - name: Build project
        run: npm run build

      - name: Upload production-ready build files
        uses: actions/upload-artifact@v2
        with:
          name: production-files
          path: ./dist

  deploy:
    name: Deploy
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Download artifact
        uses: actions/download-artifact@v2
        with:
          name: production-files
          path: ./dist

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./dist
```

You'd probably need to change your repository settings under *Actions/General*
and set the *Workflow permissions* to *Read and write permissions*.

Once the workflow has been successful, in the repository settings under *Pages*
you need to enable Github Pages to use the `gh-pages` branch as source.

### [Tip Handling Vue Router with a Custom 404 Page](https://learnvue.co/2020/09/how-to-deploy-your-vue-app-to-github-pages/#tip-handling-vue-router-with-a-custom-404-page)

One thing to keep in mind when setting up the Github Pages site, is that working with Vue Router gets a little tricky.

If you’re using history mode in Vue router, you’ll notice that if you try to go
directly to a page other than `/` you’ll get a 404 error. This is because Github
Pages does not automatically redirect all requests to serve `index.html`.

Luckily, there is an easy little workaround. All you have to do is duplicate
your `index.html` file and name the copy `404.html`.

What this does is make your 404 page serve the same content as your
`index.html`, which means your Vue router will be able to display the right
page.

# Testing

## Debug Jest tests

If you're not developing in Visual code, running a debugger is not easy in the
middle of the tests, so to debug one you can use `console.log()` statements and
when you run them with `yarn test:unit` you'll see the traces.

# Troubleshooting

## Failed to resolve component: X

If you've already imported the component with `import X from './X.vue` you may
have forgotten to add the component to the `components` property of the module:

```javascript
export default {
  name: 'Inbox',
  components: {
    X
  }
}
```

# References

* [Docs](https://vuejs.org/guide/introduction.html)
* [Homepage](https://vuejs.org)
* [Tutorial](https://vuejs.org/tutorial/#step-1)
* [Examples](https://vuejs.org/examples/#hello-world)

* [Awesome Vue
    Components](https://next.awesome-vue.js.org/components-and-libraries/ui-components.html)

## Axios

* [Docs](https://axios-http.com/docs/intro)
* [Git](https://github.com/axios/axios)
* [Homepage](https://axios-http.com/)
