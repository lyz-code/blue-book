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

# Components

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

# The basics

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

## [Attribute bindings](https://vuejs.org/tutorial/#step-3)

To bind an attribute to a dynamic value, we use the v-bind directive:

```html
<div v-bind:id="dynamicId"></div>
```

A directive is a special attribute that starts with the `v-` prefix. They are part
of Vue's template syntax. Similar to text interpolations, directive values are
JavaScript expressions that have access to the component's state.

The part after the colon `:id` is the "argument" of the directive. Here, the
element's `id` attribute will be synced with the `dynamicId` property from the
component's state.

Because `v-bind` is used so frequently, it has a dedicated shorthand syntax:

```html
<div :id="dynamicId"></div>
```

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

## [Form bindings](https://vuejs.org/tutorial/#step-5)


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
dependencies change.

## [Lifecycle and Template Refs](https://vuejs.org/tutorial/#step-9)

There will be cases where we need to manually work with the DOM.

We can request a template `ref`. For example a reference to an element in the template
using the special `ref` attribute:

```html
<p ref="p">hello</p>
```

The element will be exposed on `this.$refs` as `this.$refs.p`. However, you can
only access it after the component is `mounted`.

To run code after mount, we can use the `mounted` option:

```javascript
export default {
  mounted() {
    this.$refs.p.textContent = 'Hi'
  }
}
```

This is called a lifecycle hook, it allows us to register a callback to be
called at certain times of the component's lifecycle. There are other hooks such
as `created` and `updated`.

## [Watchers](https://vuejs.org/tutorial/#step-10)

Sometimes we may need to perform "side effects" reactively. For example,
fetching new data when an ID changes. We can achieve this with
watchers:

```vue
<script>
export default {
  data() {
    return {
      todoId: 1,
      todoData: null
    }
  },
  methods: {
    async fetchData() {
      const res = await fetch(
        `https://jsonplaceholder.typicode.com/todos/${this.todoId}`
      )
      this.todoData = await res.json()
    }
  },
  watch: {
    todoId(newId) {
      this.fetchData()
    }
  },
  mounted() {
    this.fetchData()
  }
}
</script>

<template>
  <p>Todo id: {{ todoId }}</p>
  <button @click="todoId++">Fetch next todo</button>
  <p v-if="!todoData">Loading...</p>
  <pre v-else>{{ todoData }}</pre>
</template>
```

Here, we are using the `watch` option to watch changes to the `todoId` property.
The watch callback is called when the id changes, and receives the new value as
the argument.

## [Components](https://vuejs.org/tutorial/#step-11)

So far, we've only been working with a single component. Real Vue applications
are typically created with nested components.

A parent component can render another component in its template as a child
component. To use a child component, we need to first import it:

```vue
import ChildComp from './ChildComp.vue'

export default {
  components: {
    ChildComp
  }
}
```

We also need to register the component using the `components` option. Here we are
using the object property shorthand to register the `ChildComp` component under
the `ChildComp` key.

Then, we can use the component in the template as:

```html
<ChildComp />
```

A child component can accept input from the parent via
[props](https://vuejs.org/tutorial/#step-12). First, it needs to declare the
props it accepts:

```vue
// in child component
export default {
  props: {
    msg: String
  }
}
```

Once declared, the `msg` prop is exposed on this and can be used in the child
component's template.

The parent can pass the prop to the child just like attributes. To pass
a dynamic value, we can also use the `v-bind` syntax:

```vue
<script>
import ChildComp from './ChildComp.vue'

export default {
  components: {
    ChildComp
  },
  data() {
    return {
      greeting: 'Hello from parent'
    }
  }
}
</script>

<template>
  <ChildComp :msg="greeting" />
</template>
```

## [Emits](https://vuejs.org/tutorial/#step-13)

In addition to receiving props, a child component can also emit events to the
parent:

```javascript
export default {
  // declare emitted events
  emits: ['response'],
  created() {
    // emit with argument
    this.$emit('response', 'hello from child')
  }
}
```

The first argument to `this.$emit()` is the event name. Any additional arguments are passed on to the event listener.

The parent can listen to child-emitted events using `v-on`, here the handler
receives the extra argument from the child emit call and assigns it to local
state:

```vue
<script>
import ChildComp from './ChildComp.vue'

export default {
  components: {
    ChildComp
  },
  data() {
    return {
      childMsg: 'No child msg yet'
    }
  }
}
</script>

<template>
  <ChildComp @response="(msg) => childMsg = msg"/>
  <p>{{ childMsg }}</p>
</template>
```

## [Slots](https://vuejs.org/tutorial/#step-14)

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


# References

* [Homepage](https://vuejs.org)
* [Tutorial](https://vuejs.org/tutorial/#step-1)
* [Examples](https://vuejs.org/examples/#hello-world)
