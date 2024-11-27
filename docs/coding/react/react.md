---
title: React
date: 20200402
author: Lyz
---

React is a declarative, efficient, and flexible JavaScript library for building
user interfaces. It lets you compose complex UIs from small and isolated pieces
of code called “components”.

# [Set up a new project](https://reactjs.org/tutorial/tutorial.html#setup-option-2-local-development-environment)

* [Install Node.js](../../linux/nodejs.md#install)

* Create the project baseline with [Create React
    App](https://create-react-app.dev). Using this tool avoids:

    * Learning and configuring many build tools.
    * Optimize your bundles.
    * Worry about the incompatibility of versions between the underlying pieces.

    So you can focus on the development of your code.

    ```bash
    npx create-react-app my-app
    ```

* Delete all files in the `src/` folder of the new project.
    ```bash
    cd my-app
    rm src/*
    ```

* Create the basic files `index.css`, `index.js` in the `src` directory.
* Run the server: `npm start`.

## [Start a React + Flask project](https://blog.miguelgrinberg.com/post/how-to-create-a-react--flask-project)

* Create the api directory.
    ```bash
    mkdir api
    ```
* Make the virtualenv.
    ```bash
    mkvirtualenv \
        --python=python3 \
        -a ~/projects/my-app \
        my-app
    ```
* Install flask.
    ```bash
    pip install flask python-dotenv
    ```
* Add a basic file to `api/api.py`.
    ```python
    import time
    from flask import Flask

    app = Flask(__name__)

    @app.route('/api/time')
    def get_current_time():
        return {'time': time.time()}
    ```

* Create the `.flaskenv` file.
    ```ini
    FLASK_APP=api/api.py
    FLASK_ENV=development
    ```
* Make sure everything is alright.
    ```bash
    flask run
    ```

# The basics

Components tell React what to show on the screen. When the data changes, React
will efficiently update and re-render the components.

```js
class ShoppingList extends React.Component {
  render() {
    return (
      <div className="shopping-list">
        <h1>Shopping List for {this.props.name}</h1>
        <ul>
          <li>Instagram</li>
          <li>WhatsApp</li>
          <li>Oculus</li>
        </ul>
      </div>
    );
  }
}

// Example usage: <ShoppingList name="Mark" />
```

`ShoppingList` is a *React component class*, or *React component type*.
A component takes in parameters, called `props` (short for “properties”), and
returns a hierarchy of views to display via the `render` method.

The `render` method returns a description of what you want to see on the screen.
React takes the description and displays the result. In particular, render
returns a *React element*, which is a lightweight description of what to render.

Most React developers use a special syntax called “JSX” which makes these
structures easier to write. The <div /> syntax is transformed at build time to
React.createElement('div'). The example above is equivalent to:

```js
return React.createElement('div', {className: 'shopping-list'},
  React.createElement('h1', /* ... h1 children ... */),
  React.createElement('ul', /* ... ul children ... */)
);
```

The `ShoppingList` component above only renders built-in DOM components like `<div
/>` and `<li />`. But it can compose and render custom React components too. For
example, Use `<ShoppingList />` to refer to the whole shopping list. Each React
component is encapsulated and can operate independently; this allows the
building of complex UIs from simple components.

## Pass data between components

Data is passed between components through the `props` method.

```js
class Square extends React.Component {
  render() {
    return (
      <button className="square">
        {this.props.value}
      </button>
    );
  }
}

class Board extends React.Component {
  renderSquare(i) {
    return <Square value={i} />;
  }
  ...
}
```

## Use of the state

React components can have state by setting `this.state` in their constructors.
`this.state` should be considered as private to a React component that it’s
defined in.

Components need a constructor to initialize the state. In JavaScript classes,
it's required to call super when defining the constructor of a subclass. All
React component classes that have a constructor should start with
a `super(props)` call.

```js
class Square extends React.Component {
  constructor(props){
    super(props);
    this.state = {
      value: null,
    }
  }
  render() {
    ...
  }
}
```

Then use the `this.setState` method to set the value

```js
  ...
  render() {
    return (
      <button
        className="square"
        onClick={() => this.setState({value: 'X'})}
      >
        {this.state.value}
      </button>
    );
  }
```

### Share the state between parent and children

To collect data from multiple children, or to have two child components
communicate with each other, you need to declare the shared state in their
parent component instead. The parent component can pass the state back down to
the children by using props; this keeps the child components in sync with each
other and with the parent component.

First define the parent state

```js
class Square extends React.Component {
  render() {
    return (
      <button
        className="square"
        onClick={() => this.props.onClick()}
      >
        {this.props.value}
      </button>
    );
  }
}

class Board extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      squares: Array(9).fill(null),
    };
  }

  handleClick(i) {
    const squares = this.state.squares.slice();
    squares[i] = 'X';
    this.setState({squares: squares});
  }

  renderSquare(i) {
    return <Square
      value={this.state.squares[i]}
      onClick={() => this.handleClick(i)}
    />;
  }
  ...
}
```

Since state is considered to be private to a component that defines it, it's not
possible to update the parent’s state directly from the children. Instead,
A function needs to be passed down from the parent to the children, so the
children can call that function when required. For example the `onClick={() =>
this.handleClick(i)}` in the example above.

When a `Square` is clicked, the `onClick` function provided by the `Board` is
called. Here’s a review of how this is achieved:

* The `onClick` prop on the built-in DOM `<button>` component tells React to set
    up a click event listener.
* When the button is clicked, React will call the `onClick` event handler that
    is defined in `Square`’s `render()` method.
* This event handler calls `this.props.onClick()`. The `Square`’s `onClick` prop
    was specified by the `Board`.
* Since the `Board` passed `onClick={() => this.handleClick(i)}` to `Square`,
    the `Square` calls `this.handleClick(i)` when clicked.

So now the state is stored in `Board` instead of the individual `Square`
components. When the `Board`’s state changes, the `Square` components re-render
automatically. In React terms, the `Square` components are now controlled
components.

### Handling data change

There are generally two approaches to changing data. The first one is to mutate
the data by directly changing the it’s values. The second is to replace the data
with a new copy which has the desired changes.

* Data Change with Mutation.

    ```js
    var player = {score: 1, name: 'Jeff'};
    player.score = 2;
    // Now player is {score: 2, name: 'Jeff'}
    ```

* Data Change without Mutation.

    ```js
    var player = {score: 1, name: 'Jeff'};

    var newPlayer = Object.assign({}, player, {score: 2});
    // Now player is unchanged, but newPlayer is {score: 2, name: 'Jeff'}

    // Or if you are using object spread syntax proposal, you can write:
    // var newPlayer = {...player, score: 2};
    ```

By not mutating directly, several benefits are gained:

* Complex features become simple: Immutability makes complex features much
    easier to implement.
* Detecting Changes: Detecting changes in mutable objects is difficult because
    they are modified directly. This detection requires the mutable object to be
    compared to previous copies of itself and the entire object tree to be
    traversed.

    Detecting changes in immutable objects is considerably easier. If the
    immutable object that is being referenced is different than the previous
    one, then the object has changed.

* Determining When to Re-Render in React: The main benefit of immutability is
    that it helps you build pure components in React. Immutable data can easily
    determine if changes have been made which helps to determine when
    a component requires re-rendering.

## Function components

Function components are a simpler way to write components that only contain
a render method and don’t have their own state. Instead of defining a class
which extends `React.Component`, we can write a function that takes props as
input and returns what should be rendered. Function components are less tedious
to write than classes, and many components can be expressed this way.

Instead of

```js
class Square extends React.Component {
  render() {
    return (
      <button
        className="square"
        onClick={() => this.props.onClick()}
      >
        {this.props.value}
      </button>
    );
  }
}
```

Use

```js
function Square(props) {
  return (
    <button ClassName="square" onClick={props.onClick}>
      {props.value}
    </button>
  );
}
```

## Miscellaneous

### List rendering

When React renders a list, it stores some information about each rendered list
item. Once a list is updated, React needs to determine what has changed. A key
property needs to be specified for each list item to differentiate each list
item from its siblings. So for:

```js
<li>Ben: 9 tasks left</li>
<li>Claudia: 8 tasks left</li>
<li>Alexa: 5 tasks left</li>
```

```js
<li key={user.id}>{user.name}: {user.taskCount} tasks left</li>
```

Could be used. When a list is re-rendered, React takes each list item’s key and
searches the previous list’s items for a matching key. If the current list has
a key that didn’t exist before, React creates a component. If the current list
is missing a key that existed in the previous list, React destroys the previous
component. If two keys match, the corresponding component is moved. Keys tell
React about the identity of each compone.

Keys tell React about the identity of each component which allows React to
maintain state between re-renders. If a component’s key changes, the component
will be destroyed and re-created with a new state.

`key` is a special and reserved property in React. When an element is created,
React extracts the `key` property and stores the `key` directly on the returned
element. Even though `key` may look like it belongs in `props`, `key` cannot be
referenced using `this.props.key`. React automatically uses `key` to decide
which components to update. A component cannot inquire about its `key`.

# Links

* [React tutorial](https://reactjs.org/tutorial/tutorial.html)
* [Awesome React](https://github.com/enaqx/awesome-react)
* [Awesome React components](https://github.com/brillout/awesome-react-components)

## Responsive React

* [Responsive react](https://medium.com/@mustwin/responsive-react-9b56d63c4edc)
* [Responsive websites without css](https://alligator.io/react/responsive-websites-without-css/)
* [react-responsive library](https://github.com/contra/react-responsive)

## With Flask

* [How to create a react + flask project](https://blog.miguelgrinberg.com/post/how-to-create-a-react--flask-project)
* [How to deploy a react + flask project](https://blog.miguelgrinberg.com/post/how-to-deploy-a-react--flask-project)
