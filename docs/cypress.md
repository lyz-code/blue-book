---
title: Cypress
date: 20220418
author: Lyz
---

[Cypress](https://www.cypress.io/) is a next generation front end testing tool
built for the modern web.

Cypress enables you to write all types of tests:

* End-to-end tests
* Integration tests
* Unit tests

Cypress can test anything that runs in a browser.

# Features

* *Time Travel*: Cypress takes snapshots as your tests run. Hover over commands
    in the Command Log to see exactly what happened at each step.
* *Debuggability*: Stop guessing why your tests are failing. Debug directly from
    familiar tools like Developer Tools. Our readable errors and stack traces
    make debugging lightning fast.
* *Automatic Waiting*: Never add waits or sleeps to your tests. Cypress
    automatically waits for commands and assertions before moving on. No more
    async hell.
* *Spies, Stubs, and Clocks*: Verify and control the behavior of functions,
    server responses, or timers. The same functionality you love from unit
    testing is right at your fingertips.
* *Network Traffic Control*: Easily control, stub, and test edge cases without
    involving your server. You can stub network traffic however you like.
* *Consistent Results*: Our architecture doesn’t use Selenium or WebDriver. Say
    hello to fast, consistent and reliable tests that are flake-free.
* *Screenshots and Videos*: View screenshots taken automatically on failure, or
    videos of your entire test suite when run from the CLI.
* *Cross browser Testing*: Run tests within Firefox and Chrome-family browsers
    (including Edge and Electron) locally and optimally in a Continuous
    Integration pipeline.

Check the [key
differences](https://docs.cypress.io/guides/overview/key-differences#Flake-resistant)
page to see more benefits of using the tool.

# [Installation](https://docs.cypress.io/guides/getting-started/installing-cypress)

```bash
npm install cypress --save-dev
```

# [Usage](https://docs.cypress.io/guides/getting-started/writing-your-first-test#What-you-ll-learn)

You first need to open cypress with `npx cypress open`.

To get an overview of cypress' workflow follow the [Writing your first test
tutorial](https://docs.cypress.io/guides/getting-started/writing-your-first-test#Write-your-first-test)

Tests live in the `cypress` directory, if you create a new file in the
`cypress/integration` directory it will automatically show up in the UI. Cypress
monitors your spec files for any changes and automatically displays any
changes.

Writing tests is meant to be simple, for example:

```javascript
describe('My First Test', () => {
  it('Does not do much!', () => {
    expect(true).to.equal(true)
  })
})
```

## [Test structure](https://docs.cypress.io/guides/core-concepts/writing-and-organizing-tests#Writing-tests)

The test interface, borrowed from
[Mocha](https://docs.cypress.io/guides/references/bundled-tools#Mocha), provides
`describe()`, `context()`, `it()` and `specify()`. `context()` is identical to `describe()` and `specify()` is identical to `it()`.

```javascript
describe('Unit test our math functions', () => {
  context('math', () => {
    it('can add numbers', () => {
      expect(add(1, 2)).to.eq(3)
    })

    it('can subtract numbers', () => {
      expect(subtract(5, 12)).to.eq(-7)
    })

    specify('can divide numbers', () => {
      expect(divide(27, 9)).to.eq(3)
    })

    specify('can multiply numbers', () => {
      expect(multiply(5, 4)).to.eq(20)
    })
  })
})
```

### Hooks

Hooks are helpful to set conditions that you want to run before a set of tests
or before each test. They're also helpful to clean up conditions after a set of
tests or after each test.

```javascript
before(() => {
  // root-level hook
  // runs once before all tests
})

beforeEach(() => {
  // root-level hook
  // runs before every test block
})

afterEach(() => {
  // runs after each test block
})

after(() => {
  // runs once all tests are done
})

describe('Hooks', () => {
  before(() => {
    // runs once before all tests in the block
  })

  beforeEach(() => {
    // runs before each test in the block
  })

  afterEach(() => {
    // runs after each test in the block
  })

  after(() => {
    // runs once after all tests in the block
  })
})
```

!!! warning "Before writing `after()` or `afterEach()` hooks, read [the
anti-pattern of cleaning up state with `after()` or `afterEach()`](https://docs.cypress.io/guides/references/best-practices#Using-after-or-afterEach-hooks)"


### Skipping tests

You can skip tests in the next ways:

```javascript
describe('TodoMVC', () => {
  it('is not written yet')

  it.skip('adds 2 todos', function () {
    cy.visit('/')
    cy.get('.new-todo').type('learn testing{enter}').type('be cool{enter}')
    cy.get('.todo-list li').should('have.length', 100)
  })

  xit('another test', () => {
    expect(false).to.true
  })
})
```

## [Querying elements](https://docs.cypress.io/guides/core-concepts/introduction-to-cypress#Querying-Elements)

Cypress automatically retries the query until either the element is found or
a set timeout is reached. This makes Cypress robust and immune to dozens of
common problems that occur in other testing tools.

### Query by HTML properties

You need to find the elements to act upon, usually you do it with the `cy.get()`
function. For example:

```javascript
cy.get('.my-selector')
```

Cypress leverages jQuery's powerful selector engine and exposes many of its DOM
traversal methods to you so you can work with complex HTML structures. For
example:

```javascript
cy.get('#main-content').find('.article').children('img[src^="/static"]').first()
```

If you follow the [Write testable code
guide](frontend_development.md#write-testable-code), you'll select elements by
the `data-cy` element.

```javascript
cy.get('[data-cy=submit]')
```

You'll probably write that a lot, that's why it's useful to define the next
commands in `/cypress/support/commands.ts`.

```javascript
Cypress.Commands.add('getById', (selector, ...args) => {
  return cy.get(`[data-cy=${selector}]`, ...args)
})

Cypress.Commands.add('getByIdLike', (selector, ...args) => {
  return cy.get(`[data-cy*=${selector}]`, ...args)
})

Cypress.Commands.add('findById', {prevSubject: true}, (subject, selector, ...args) => {
  return subject.find(`[data-cy=${selector}]`, ...args)
})
```

So you can now do
```javascript
cy.getById('submit')
```

### Query by content

Another way to locate things -- a more human way -- is to look them up by their
content, by what the user would see on the page. For this, there's the handy
`cy.contains()` command, for example:

```javascript
// Find an element in the document containing the text 'New Post'
cy.contains('New Post')

// Find an element within '.main' containing the text 'New Post'
cy.get('.main').contains('New Post')
```

This is helpful when writing tests from the perspective of a user interacting
with your app. They only know that they want to click the button labeled
"Submit". They have no idea that it has a type attribute of submit, or a CSS
class of `my-submit-button`.

### Changing the timeout

The querying methods accept the `timeout` argument to change the default
timeout.

```javascript
// Give this element 10 seconds to appear
cy.get('.my-slow-selector', { timeout: 10000 })
```

### Select by position in list

Inside our list, we can select elements based on their position in the list,
using `.first()`, `.last()` or `.eq()` selector.

```javascript
cy
  .get('li')
  .first(); // select "red"

cy
  .get('li')
  .last(); // select "violet"

cy
  .get('li')
  .eq(2); // select "yellow"
```

You can also use `.next()` and `.prev()` to navigate through the elements.

### Select elements by filtering

Once you select multiple elements, you can filter within these based on another selector.

```javascript
cy
  .get('li')
  .filter('.primary') // select all elements with the class .primary
```

To do the exact opposite, you can use `.not()` command.

cy
  .get('li')
  .not('.primary') // select all elements without the class .primary

### Finding elements

You can specify your selector by first selecting an element you want to search
within, and then look down the DOM structure to find a specific element you are
looking for.

```javascript
cy
  .get('.list')
  .find('.violet') // finds an element with class .violet inside .list element
```

Instead of looking down the DOM structure and finding an element within another
element, we can look up. In this example, we first select our list item, and
then try to find an element with a `.list` class.

```javascript
cy
  .get('.violet')
  .parent('.list') // finds an element with class .list that is above our .violet element
```

## Interacting with elements

Cypress allows you to click on and type into elements on the page by using
`.click()` and `.type()` commands with a `cy.get()` or `cy.contains()` command. This is a great example of chaining in action.

```javascript
cy.get('textarea.post-body').type('This is an excellent post.')
```

We're chaining the `.type()` onto the `cy.get()`, telling it to type into the
subject yielded from the `cy.get()` command, which will be a DOM element.

Here are even more action commands Cypress provides to interact with your app:

* `.blur()`: Make a focused DOM element blur.
* `.focus()`: Focus on a DOM element.
* `.clear()`: Clear the value of an input or `textarea`.
* `.check()`: Check checkbox(es) or radio(s).
* `.uncheck()`: Uncheck checkbox(es).
* `.select()`: Select an `<option>` within a `<select>`.
* `.dblclick()`: Double-click a DOM element.
* `.rightclick()`: Right-click a DOM element.

These commands ensure some guarantees about what the state of the elements
should be prior to performing their actions.

For example, when writing a `.click()` command, Cypress ensures that the element
is able to be interacted with (like a real user would). It will automatically
wait until the element reaches an "actionable" state by:

* Not being hidden
* Not being covered
* Not being disabled
* Not animating

This also helps prevent flake when interacting with your application in tests.

If you want to jump into the command flow and use a custom function use
`.then()`. When the previous command resolves, it will call your callback
function with the yielded subject as the first argument.

If you wish to continue chaining commands after your `.then()`, you'll need to
specify the subject you want to yield to those commands, which you can achieve
with a return value other than `null` or `undefined`. Cypress will yield that to the
next command for you.

```javascript
cy
  // Find the el with id 'some-link'
  .get('#some-link')

  .then(($myElement) => {
    // ...massage the subject with some arbitrary code

    // grab its href property
    const href = $myElement.prop('href')

    // strip out the 'hash' character and everything after it
    return href.replace(/(#.*)/, '')
  })
  .then((href) => {
    // href is now the new subject
    // which we can work with now
  })
```

### [Setting aliases](https://docs.cypress.io/guides/core-concepts/variables-and-aliases#Aliases)

Cypress has some added functionality for quickly referring back to past subjects
called Aliases.

It looks something like this:

```javascript
cy.get('.my-selector')
  .as('myElement') // sets the alias
  .click()

/* many more actions */

cy.get('@myElement') // re-queries the DOM as before (only if necessary)
  .click()
```

This lets us reuse our DOM queries for faster tests when the element is still in
the DOM, and it automatically handles re-querying the DOM for us when it is not
immediately found in the DOM. This is particularly helpful when dealing with
front end frameworks that do a lot of re-rendering.

It can be used to share context between tests, for example with fixtures:

```javascript
beforeEach(() => {
  // alias the users fixtures
  cy.fixture('users.json').as('users')
})

it('utilize users in some way', function () {
  // access the users property
  const user = this.users[0]

  // make sure the header contains the first
  // user's name
  cy.get('header').should('contain', user.name)
})
```

## [Asserting about elements](https://docs.cypress.io/guides/core-concepts/introduction-to-cypress#Assertions)

Assertions let you do things like ensuring an element is visible or has
a particular attribute, CSS class, or state. Assertions are commands that enable
you to describe the desired state of your application. Cypress will
automatically wait until your elements reach this state, or fail the test if the
assertions don't pass. For example:

```javascript
cy.get(':checkbox').should('be.disabled')

cy.get('form').should('have.class', 'form-horizontal')

cy.get('input').should('not.have.value', 'US')
```

Cypress bundles
[Chai](https://docs.cypress.io/guides/references/bundled-tools#Chai),
[Chai-jQuery](https://docs.cypress.io/guides/references/bundled-tools#Chai-jQuery),
and
[Sinon-Chai](https://docs.cypress.io/guides/references/bundled-tools#Sinon-Chai)
to provide built-in assertions. You can see a comprehensive list of them in [the
list of assertions
reference](https://docs.cypress.io/guides/references/assertions). You can also
[write your own assertions as Chai
plugins](https://docs.cypress.io/examples/examples/recipes#Fundamentals) and use
them in Cypress.

### Default assertions

Many commands have a default, built-in assertion, or rather have requirements
that may cause it to fail without needing an explicit assertion you've added.

* `cy.visit()`: Expects the page to send text/html content with a 200 status
    code.
* `cy.request()`: Expects the remote server to exist and provide a response.
* `cy.contains()`: Expects the element with content to eventually exist in the
    DOM.
* `cy.get()`: Expects the element to eventually exist in the DOM.
* `.find()`: Also expects the element to eventually exist in the DOM.
* `.type()`: Expects the element to eventually be in a typeable state.
* `.click()`: Expects the element to eventually be in an actionable state.
* `.its()`: Expects to eventually find a property on the current subject.

Certain commands may have a specific requirement that causes them to immediately
fail without retrying: such as `cy.request()`. Others, such as DOM based
commands will automatically retry and wait for their corresponding elements to
exist before failing.

### Writing assertions

There are two ways to write assertions in Cypress:

* Implicit Subjects: Using `.should()` or `.and()`.
* Explicit Subjects: Using `expect`.

The implicit form is much shorter, so only use the explicit form in the next
cases:

* Assert multiple things about the same subject.
* Massage the subject in some way prior to making the assertion.

#### Implicit Subjects

Using `.should()` or `.and()` commands is the preferred way of making assertions
in Cypress.

```javascript
// the implicit subject here is the first <tr>
// this asserts that the <tr> has an .active class
cy.get('tbody tr:first').should('have.class', 'active')
```

You can chain multiple assertions together using `.and()`, which is another name
for `.should()` that makes things more readable:

```javascript
cy.get('#header a')
  .should('have.class', 'active')
  .and('have.attr', 'href', '/users')
```

Because `.should('have.class')` does not change the subject, `.and('have.attr')`
is executed against the same element. This is handy when you need to assert
multiple things against a single subject quickly.

#### Explicit Subjects

Using `expect` allows you to pass in a specific subject and make an assertion
about it.

```javascript
// the explicit subject here is the boolean: true
expect(true).to.be.true
```

### [Common Assertions](https://docs.cypress.io/guides/references/assertions#Common-Assertions)

* *Length*:

    ```javascript
    // retry until we find 3 matching <li.selected>
    cy.get('li.selected').should('have.length', 3)
    ```

* *Attribute*: For example to test links
    ```javascript
    // check the content of an attribute
    cy
      .get('a')
      .should('have.attr', 'href', 'https://docs.cypress.io')
      .and('have.attr', 'target', '_blank') // Test it's meant to be opened
      // another tab
    ```

* *Class*:

    ```javascript
    // retry until this input does not have class disabled
    cy.get('form').find('input').should('not.have.class', 'disabled')
    ```

* *Value*:

    ```javascript
    // retry until this textarea has the correct value
    cy.get('textarea').should('have.value', 'foo bar baz')
    ```

* *Text Content*:

    ```javascript
    // assert the element's text content is exactly the given text
    cy.get('#user-name').should('have.text', 'Joe Smith')
    // assert the element's text includes the given substring
    cy.get('#address').should('include.text', 'Atlanta')
    // retry until this span does not contain 'click me'
    cy.get('a').parent('span.help').should('not.contain', 'click me')
    // the element's text should start with "Hello"
    cy.get('#greeting')
      .invoke('text')
      .should('match', /^Hello/)
    // tip: use cy.contains to find element with its text
    // matching the given regular expression
    cy.contains('#a-greeting', /^Hello/)
    ```

* *Visibility*:

    ```javascript
    // retry until the button with id "form-submit" is visible
    cy.get('button#form-submit').should('be.visible')
    // retry until the list item with text "write tests" is visible
    cy.contains('.todo li', 'write tests').should('be.visible')
    ```

    *Note*: if there are multiple elements, the assertions `be.visible` and
    `not.be.visible` act differently:

    ```javascript
    // retry until SOME elements are visible
    cy.get('li').should('be.visible')
    // retry until EVERY element is invisible
    cy.get('li.hidden').should('not.be.visible')
    ```

* *Existence*:

    ```javascript
    // retry until loading spinner no longer exists
    cy.get('#loading').should('not.exist')
    ```

* *State*:

    ```javascript
    // retry until our radio is checked
    cy.get(':radio').should('be.checked')
    ```

* *CSS*:

    ```javascript
    // retry until .completed has matching css
    cy.get('.completed').should('have.css', 'text-decoration', 'line-through')

    // retry while .accordion css has the "display: none" property
    cy.get('#accordion').should('not.have.css', 'display', 'none')
    ```

* *Disabled property*:

    ```html
    <input type="text" id="example-input" disabled />
    ```

    ```javascript
    cy.get('#example-input')
      .should('be.disabled')
      // let's enable this element from the test
      .invoke('prop', 'disabled', false)

    cy.get('#example-input')
      // we can use "enabled" assertion
      .should('be.enabled')
      // or negate the "disabled" assertion
      .and('not.be.disabled')
    ```

### Negative assertions

There are positive and negative assertions. Examples of positive assertions
are:

```javascript
cy.get('.todo-item').should('have.length', 2).and('have.class', 'completed')
```

The negative assertions have the `not` chainer prefixed to the assertion. For
example:

```javascript
cy.contains('first todo').should('not.have.class', 'completed')
cy.get('#loading').should('not.be.visible')
```

We recommend using negative assertions to verify that a specific condition is no
longer present after the application performs an action. For example, when
a previously completed item is unchecked, we might verify that a CSS class is
removed.

```javascript
// at first the item is marked completed
cy.contains('li.todo', 'Write tests')
  .should('have.class', 'completed')
  .find('.toggle')
  .click()

// the CSS class has been removed
cy.contains('li.todo', 'Write tests').should('not.have.class', 'completed')
```

Read more on the topic in the blog post [Be Careful With Negative
Assertions](https://glebbahmutov.com/blog/negative-assertions/).

### Custom assertions

You can write your own assertion function and pass it as a callback to the
`.should()` command.

```javascript
cy.get('div').should(($div) => {
  expect($div).to.have.length(1)

  const className = $div[0].className

  // className will be a string like "main-abc123 heading-xyz987"
  expect(className).to.match(/heading-/)
})
```

## Setting up the tests

Depending on how your application is built - it's likely that your web
application is going to be affected and controlled by the server.

Traditionally when writing e2e tests using Selenium, before you automate the
browser you do some kind of set up and tear down on the server.

You generally have three ways to facilitate this with Cypress:

* `cy.exec()`: To run system commands.
* `cy.task()`: To run code in Node via the `pluginsFile`.
* `cy.request()`: To make HTTP requests.

If you're running node.js on your server, you might add a `before` or `beforeEach`
hook that executes an npm task.

```javascript
describe('The Home Page', () => {
  beforeEach(() => {
    // reset and seed the database prior to every test
    cy.exec('npm run db:reset && npm run db:seed')
  })

  it('successfully loads', () => {
    cy.visit('/')
  })
})
```

Instead of just executing a system command, you may want more flexibility and
could expose a series of routes only when running in a test environment.

For instance, you could compose several requests together to tell your server
exactly the state you want to create.

```javascript
describe('The Home Page', () => {
  beforeEach(() => {
    // reset and seed the database prior to every test
    cy.exec('npm run db:reset && npm run db:seed')

    // seed a post in the DB that we control from our tests
    cy.request('POST', '/test/seed/post', {
      title: 'First Post',
      authorId: 1,
      body: '...',
    })

    // seed a user in the DB that we can control from our tests
    cy.request('POST', '/test/seed/user', { name: 'Jane' })
      .its('body')
      .as('currentUser')
  })

  it('successfully loads', () => {
    // this.currentUser will now point to the response
    // body of the cy.request() that we could use
    // to log in or work with in some way

    cy.visit('/')
  })
})
```

While there's nothing really wrong with this approach, it does add a lot of
complexity. You will be battling synchronizing the state between your server and
your browser - and you'll always need to set up / tear down this state before
tests (which is slow).

The good news is that we aren't Selenium, nor are we a traditional e2e testing
tool. That means we're not bound to the same restrictions.

With Cypress, there are several other approaches that can offer an arguably
better and faster experience.

### Stubbing the server

Another valid approach opposed to seeding and talking to your server is to
bypass it altogether.

While you'll still receive all of the regular HTML / JS / CSS assets from your
server and you'll continue to `cy.visit()` it in the same way - you can instead
stub the JSON responses coming from it.

This means that instead of resetting the database, or seeding it with the state
we want, you can force the server to respond with whatever you want it to. In
this way, we not only prevent needing to synchronize the state between the
server and browser, but we also prevent mutating state from our tests. That
means tests won't build up state that may affect other tests.

Another upside is that this enables you to build out your application without
needing the contract of the server to exist. You can build it the way you want
the data to be structured, and even test all of the edge cases, without needing
a server.

However - there is likely still a balance here where both strategies are valid
(and you should likely do them).

While stubbing is great, it means that you don't have the guarantees that these
response payloads actually match what the server will send. However, there are
still many valid ways to get around this:

* *Generate the fixture stubs ahead of time*: You could have the server generate
    all of the fixture stubs for you ahead of time. This means their data will
    reflect what the server will actually send.

* *Write a single e2e test without stubs, and then stub the rest*: Another more
    balanced approach is to integrate both strategies. You likely want to have
    a single test that takes a true e2e approach and stubs nothing. It'll use
    the feature for real - including seeding the database and setting up state.

    Once you've established it's working you can then use stubs to test all of
    the edge cases and additional scenarios. There are no benefits to using real
    data in the vast majority of cases. We recommend that the vast majority of
    tests use stub data. They will be orders of magnitude faster, and much less
    complex.

`cy.intercept()` is used to control the behavior of HTTP requests. You can
statically define the body, HTTP status code, headers, and other response
characteristics.

```javascript
cy.intercept(
  {
    method: 'GET', // Route all GET requests
    url: '/users/*', // that have a URL that matches '/users/*'
  },
  [] // and force the response to be: []
).as('getUsers') // and assign an alias
```

### [Fixtures](https://docs.cypress.io/guides/guides/network-requests#Fixtures)

A fixture is a fixed set of data located in a file that is used in your tests.
The purpose of a test fixture is to ensure that there is a well known and fixed
environment in which tests are run so that results are repeatable. Fixtures are
accessed within tests by calling the `cy.fixture()` command.

When stubbing a response, you typically need to manage potentially large and
complex JSON objects. Cypress allows you to integrate fixture syntax directly
into responses.

```javascript
// we set the response to be the activites.json fixture
cy.intercept('GET', '/activities/*', { fixture: 'activities.json' })
```

Fixtures live in `/cypress/fixtures/` and can be further organized within
additional directories. For instance, you could create another folder called images
and add images:

```
/cypress/fixtures/images/cats.png
/cypress/fixtures/images/dogs.png
/cypress/fixtures/images/birds.png
```

To access the fixtures nested within the images folder, include the folder in
your `cy.fixture()` command.

```javascript
cy.fixture('images/dogs.png') // yields dogs.png as Base64
```

#### [Use the content of a fixture set in a hook in a test](https://docs.cypress.io/api/commands/fixture#Encoding)


If you store and access the fixture data using this test context object, make
sure to use `function () { ... }` callbacks both for the hook and the test.
Otherwise the test engine will NOT have this pointing at the test context.

```javascript
describe('User page', () => {
  beforeEach(function () {
    // "this" points at the test context object
    cy.fixture('user').then((user) => {
      // "this" is still the test context object
      this.user = user
    })
  })

  // the test callback is in "function () { ... }" form
  it('has user', function () {
    // this.user exists
    expect(this.user.firstName).to.equal('Jane')
  })
})
```


### Logging in

One of the first (and arguably one of the hardest) hurdles you'll have to
overcome in testing is logging into your application.

It's a great idea to get your signup and login flow under test coverage since it
is very important to all of your users and you never want it to break.

Logging in is one of those features that are mission critical and should likely
involve your server. We recommend you test signup and login using your UI as
a real user would. For example:

```javascript
describe('The Login Page', () => {
  beforeEach(() => {
    // reset and seed the database prior to every test
    cy.exec('npm run db:reset && npm run db:seed')

    // seed a user in the DB that we can control from our tests
    // assuming it generates a random password for us
    cy.request('POST', '/test/seed/user', { username: 'jane.lane' })
      .its('body')
      .as('currentUser')
  })

  it('sets auth cookie when logging in via form submission', function () {
    // destructuring assignment of the this.currentUser object
    const { username, password } = this.currentUser

    cy.visit('/login')

    cy.get('input[name=username]').type(username)

    // {enter} causes the form to submit
    cy.get('input[name=password]').type(`${password}{enter}`)

    // we should be redirected to /dashboard
    cy.url().should('include', '/dashboard')

    // our auth cookie should be present
    cy.getCookie('your-session-cookie').should('exist')

    // UI should reflect this user being logged in
    cy.get('h1').should('contain', 'jane.lane')
  })
})
```

You'll likely also want to test your login UI for:

* Invalid username / password.
* Username taken.
* Password complexity requirements.
* Edge cases like locked / deleted accounts.

Each of these likely requires a full blown e2e test, and it makes sense to go
through the login process. But when you're testing another area of the system
that relies on a state from a previous feature: do not use your UI to set up
this state. So for these cases you'd do:

```javascript
describe('The Dashboard Page', () => {
  beforeEach(() => {
    // reset and seed the database prior to every test
    cy.exec('npm run db:reset && npm run db:seed')

    // seed a user in the DB that we can control from our tests
    // assuming it generates a random password for us
    cy.request('POST', '/test/seed/user', { username: 'jane.lane' })
      .its('body')
      .as('currentUser')
  })

  it('logs in programmatically without using the UI', function () {
    // destructuring assignment of the this.currentUser object
    const { username, password } = this.currentUser

    // programmatically log us in without needing the UI
    cy.request('POST', '/login', {
      username,
      password,
    })

    // now that we're logged in, we can visit
    // any kind of restricted route!
    cy.visit('/dashboard')

    // our auth cookie should be present
    cy.getCookie('your-session-cookie').should('exist')

    // UI should reflect this user being logged in
    cy.get('h1').should('contain', 'jane.lane')
  })
})
```
This saves an enormous amount of time visiting the login page, filling out the
username, password, and waiting for the server to redirect us before every
test.

Because we previously tested the login system end-to-end without using any
shortcuts, we already have 100% confidence it's working correctly.

[Here](https://github.com/cypress-io/cypress-example-recipes#logging-in-recipes)
are other login recipes.

### Setting up backend servers for E2E tests

Cypress team does NOT recommend trying to start your back end web server from
within Cypress.

Any command run by `cy.exec()` or `cy.task()` has to exit eventually. Otherwise,
Cypress will not continue running any other commands.

Trying to start a web server from `cy.exec()` or `cy.task()` causes all kinds of
problems because:

* You have to background the process.
* You lose access to it via terminal.
* You don't have access to its stdout or logs.
* Every time your tests run, you'd have to work out the complexity around
    starting an already running web server.
* You would likely encounter constant port conflicts.

Therefore you should start your web server before running Cypress and kill it
after it completes. They have [examples showing you how to start and stop your
web server in a CI
environment](https://docs.cypress.io/guides/continuous-integration/introduction#Boot-your-server).

## [Waiting](https://docs.cypress.io/guides/guides/network-requests#Waiting)

Cypress enables you to declaratively `cy.wait()` for requests and their
responses.

```javascript
cy.intercept('/activities/*', { fixture: 'activities' }).as('getActivities')
cy.intercept('/messages/*', { fixture: 'messages' }).as('getMessages')

// visit the dashboard, which should make requests that match
// the two routes above
cy.visit('http://localhost:8888/dashboard')

// pass an array of Route Aliases that forces Cypress to wait
// until it sees a response for each request that matches
// each of these aliases
cy.wait(['@getActivities', '@getMessages'])

// these commands will not run until the wait command resolves above
cy.get('h1').should('contain', 'Dashboard')
```

If you would like to check the response data of each response of an aliased
route, you can use several `cy.wait()` calls.

```javascript
cy.intercept({
  method: 'POST',
  url: '/myApi',
}).as('apiCheck')

cy.visit('/')
cy.wait('@apiCheck').then((interception) => {
  assert.isNotNull(interception.response.body, '1st API call has data')
})

cy.wait('@apiCheck').then((interception) => {
  assert.isNotNull(interception.response.body, '2nd API call has data')
})

cy.wait('@apiCheck').then((interception) => {
  assert.isNotNull(interception.response.body, '3rd API call has data')
})
```

Waiting on an aliased route has big advantages:

* Tests are more robust with much less flake.
* Failure messages are much more precise.
* You can assert about the underlying request object.

### Avoiding Flake tests

One advantage of declaratively waiting for responses is that it decreases test
flake. You can think of `cy.wait()` as a guard that indicates to Cypress when you
expect a request to be made that matches a specific routing alias. This prevents
the next commands from running until responses come back and it guards against
situations where your requests are initially delayed.

```javascript
cy.intercept('/search*', [{ item: 'Book 1' }, { item: 'Book 2' }]).as(
  'getSearch'
)

// our autocomplete field is throttled
// meaning it only makes a request after
// 500ms from the last keyPress
cy.get('#autocomplete').type('Book')

// wait for the request + response
// thus insulating us from the
// throttled request
cy.wait('@getSearch')

cy.get('#results').should('contain', 'Book 1').and('contain', 'Book 2')
```

### Assert on wait content

Another benefit of using `cy.wait()` on requests is that it allows you to access
the actual request object. This is useful when you want to make assertions about
this object.

In our example above we can assert about the request object to verify that it
sent data as a query string in the URL. Although we're mocking the response, we
can still verify that our application sends the correct request.

```javascript
// any request to "/search/*" endpoint will automatically receive
// an array with two book objects
cy.intercept('/search/*', [{ item: 'Book 1' }, { item: 'Book 2' }]).as(
  'getSearch'
)

cy.get('#autocomplete').type('Book')

// this yields us the interception cycle object which includes
// fields for the request and response
cy.wait('@getSearch').its('request.url').should('include', '/search?query=Book')

cy.get('#results').should('contain', 'Book 1').and('contain', 'Book 2')
```

Of the intercepted object you can check:

* URL.
* Method.
* Status Code.
* Request Body.
* Request Headers.
* Response Body.
* Response Headers.

```javascript
// spy on POST requests to /users endpoint
cy.intercept('POST', '/users').as('new-user')
// trigger network calls by manipulating web app's user interface, then
cy.wait('@new-user').should('have.property', 'response.statusCode', 201)

// we can grab the completed interception object again to run more assertions
// using cy.get(<alias>)
cy.get('@new-user') // yields the same interception object
  .its('request.body')
  .should(
    'deep.equal',
    JSON.stringify({
      id: '101',
      firstName: 'Joe',
      lastName: 'Black',
    })
  )

// and we can place multiple assertions in a single "should" callback
cy.get('@new-user').should(({ request, response }) => {
  expect(request.url).to.match(/\/users$/)
  expect(request.method).to.equal('POST')
  // it is a good practice to add assertion messages
  // as the 2nd argument to expect()
  expect(response.headers, 'response headers').to.include({
    'cache-control': 'no-cache',
    expires: '-1',
    'content-type': 'application/json; charset=utf-8',
    location: '<domain>/users/101',
  })
})
```

!!! note "You can inspect the full request cycle object by logging it to the console"

    ```javascript
    cy.wait('@new-user').then(console.log)
    ```

## Don't repeat yourself

### Share code before each test

```javascript
describe('my form', () => {
  beforeEach(() => {
    cy.visit('/users/new')
    cy.get('#first').type('Johnny')
    cy.get('#last').type('Appleseed')
  })

  it('displays form validation', () => {
    cy.get('#first').clear() // clear out first name
    cy.get('form').submit()
    cy.get('#errors').should('contain', 'First name is required')
  })

  it('can submit a valid form', () => {
    cy.get('form').submit()
  })
})
```

### Parametrization

If you want to run similar tests with different data, you can use
parametrization. For example to test the same pages for different screen sizes
use:

```javascript
const sizes = ['iphone-6', 'ipad-2', [1024, 768]]

describe('Logo', () => {
  sizes.forEach((size) => {
    // make assertions on the logo using
    // an array of different viewports
    it(`Should display logo on ${size} screen`, () => {
      if (Cypress._.isArray(size)) {
        cy.viewport(size[0], size[1])
      } else {
        cy.viewport(size)
      }

      cy.visit('https://www.cypress.io')
      cy.get('#logo').should('be.visible')
    })
  })
})
```

### Use functions

Sometimes, the piece of code is redundant and we don't we don't require it in
all the test cases. We can create utility functions and move such code there.

We can create a separate folder as utils in support folder and store our
functions in a file in that folder.

Consider the following example of utility function for login.

```javascript
//cypress/support/utils/common.js

export const loginViaUI = (username, password) => {
  cy.get("[data-cy='login-email-field']").type(username);
  cy.get("[data-cy='login-password-field']").type(password);
  cy.get("[data-cy='submit-button']").submit()
}
```

This is how we can use utility function in our test case:

```javascript
import {
  loginViaUI
} from '../support/utils/common.js';

describe("Login", () => {
  it('should allow user to log in', () => {
    cy.visit('/login');
    loginViaUI('username', 'password');
  });
});
```

Utility functions are similar to Cypress commands. If the code being used in
almost every test suite, we can create a custom command for it. The benefit of
this is that we don't have to import the js file to use the command, it is
available directly on cy object i.e. `cy.loginViaUI()`.

But, this doesn't mean that we should use commands for everything. If the code
is used in only some of the test suite, we can create a utility function and
import it whenever needed.

## [Setting up time of the tests](https://docs.cypress.io/api/commands/clock#No-Args)

Specify a `now` timestamp

```javascript
// your app code
$('#date').text(new Date().toJSON())

const now = new Date(2017, 3, 14).getTime() // April 14, 2017 timestamp

cy.clock(now)
cy.visit('/index.html')
cy.get('#date').contains('2017-04-14')
```

## [Simulate errors](https://dev.to/walmyrlimaesilv/how-to-simulate-errors-with-cypress-3o3l)

End-to-end tests are excellent for testing “happy path” scenarios and the most
important application features.

However, there are unexpected situations, and when they occur, the application
cannot completely "break".

Such situations can occur due to errors on the server or the network, to name
a few.

With Cypress, we can easily simulate error situations.

Below are examples of tests for server and network errors.

```javascript
context('Errors', () => {
  const errorMsg = 'Oops! Try again later'

  it('simulates a server error', () => {
    cy.intercept(
      'GET',
      '**/search?query=cypress',
      { statusCode: 500 }
    ).as('getServerFailure')

    cy.visit('https://example.com/search')

    cy.get('[data-cy="search-field"]')
      .should('be.visible')
      .type('cypress{enter}')
    cy.wait('@getServerFailure')

    cy.contains(errorMsg)
      .should('be.visible')
  })

  it('simulates a network failure', () => {
    cy.intercept(
      'GET',
      '**/search?query=cypressio',
      { forceNetworkError: true }
    ).as('getNetworkFailure')

    cy.visit('https://example.com/search')

    cy.get('[data-cy="search-field"]')
      .should('be.visible')
      .type('cypressio{enter}')
    cy.wait('@getNetworkFailure')

    cy.contais(errorMsg)
      .should('be.visible')
  })
})
```

In the above tests, the HTTP request of type GET to the search endpoint is
intercepted. In the first test, we use the `statusCode` option with the value
`500`. In the second test, we use the `forceNewtworkError` option with the value
of `true`. After that, you can test that the correct message is visible to the
user.

## [Sending different responses](https://glebbahmutov.com/blog/cypress-intercept-problems/#sending-different-responses)

To return different responses from a single `GET /todos` intercept, you can
place all prepared responses into an array, and then use Array.prototype.shift
to return and remove the first item.

```javascript
it('returns list with more items on page reload', () => {
  const replies = [{ fixture: 'articles.json' }, { statusCode: 404 }]
  cy.intercept('GET', '/api/inbox', req => req.reply(replies.shift()))
})
```


## [Component testing](https://docs.cypress.io/guides/component-testing/introduction)

Component testing in Cypress is similar to end-to-end testing. The notable differences are:

* There's no need to navigate to a URL. You don't need to call `cy.visit()` in
your test.
* Cypress provides a blank canvas where we can `mount` components in isolation.

For example:

```javascript
import { mount } from '@cypress/vue'
import TodoList from './components/TodoList'

describe('TodoList', () => {
  it('renders the todo list', () => {
    mount(<TodoList />)
    cy.get('[data-testid=todo-list]').should('exist')
  })

  it('contains the correct number of todos', () => {
    const todos = [
      { text: 'Buy milk', id: 1 },
      { text: 'Learn Component Testing', id: 2 },
    ]

    mount(<TodoList todos={todos} />)

    cy.get('[data-testid=todos]').should('have.length', todos.length)
  })
})
```

If you are using Cypress Component Testing in a project that also has tests
written with the Cypress End-to-End test runner, you may want to [configure some
Component Testing specific defaults](#configure-component-testing).

!!! warning "It doesn't yet work with vuetify"

### Install

Run:

```bash
npm install --save-dev cypress @cypress/vue @cypress/webpack-dev-server webpack-dev-server
```

You will also need to configure the component testing framework of your choice
by installing the corresponding component testing plugin.

```javascript
// cypress/plugins/index.js

module.exports = (on, config) => {
  if (config.testingType === 'component') {
    const { startDevServer } = require('@cypress/webpack-dev-server')

    // Vue's Webpack configuration
    const webpackConfig = require('@vue/cli-service/webpack.config.js')

    on('dev-server:start', (options) =>
      startDevServer({ options, webpackConfig })
    )
  }
}
```

### Usage

```javascript
// components/HelloWorld.spec.js
import { mount } from '@cypress/vue'
import { HelloWorld } from './HelloWorld.vue'
describe('HelloWorld component', () => {
  it('works', () => {
    mount(HelloWorld)
    // now use standard Cypress commands
    cy.contains('Hello World!').should('be.visible')
  })
})
```
You can pass additional styles, css files and external stylesheets to load, see
docs/styles.md for full list.

```javascript
import Todo from './Todo.vue'
const todo = {
  id: '123',
  title: 'Write more tests',
}

mount(Todo, {
  propsData: { todo },
  stylesheets: [
    'https://cdnjs.cloudflare.com/ajax/libs/bulma/0.7.2/css/bulma.css',
  ],
})
```

## [Visual testing](https://docs.cypress.io/guides/tooling/visual-testing#Functional-vs-visual-testing)

Cypress is a functional Test Runner. It drives the web application the way
a user would, and checks if the app functions as expected: if the expected
message appears, an element is removed, or a CSS class is added after the
appropriate user action. Cypress does NOT see how the page actually looks though.

You could technically write a functional test asserting the CSS properties using
the have.css assertion, but these may quickly become cumbersome to write and
maintain, especially when visual styles rely on a lot of CSS styles.

Visual testing can be done through plugins that do visual regression testing,
which is to take an image snapshot of the entire application under test or
a specific element, and then compare the image to a previously approved baseline
image. If the images are the same (within a set pixel tolerance), it is
determined that the web application looks the same to the user. If there are
differences, then there has been some change to the DOM layout, fonts, colors or
other visual properties that needs to be investigated.

If you want to test if your app is responsive use
[parametrization](#parametrization) to have maintainable tests.

For more information on how to do visual regression testing read [this
article](https://medium.com/norwich-node-user-group/visual-regression-testing-with-cypress-io-and-cypress-image-snapshot-99c520ccc595).

As of 2022-04-23 the most popular tools that don't depend on third party servers are:

* [cypress-plugin-snapshots](https://github.com/meinaart/cypress-plugin-snapshots):
    It looks to be the best plugin as it allows you to update the screenshots
    directly through the Cypress interface, but it is [unmaintained](https://github.com/meinaart/cypress-plugin-snapshots/issues/210)
* [cypress-visual-regression](https://github.com/mjhea0/cypress-visual-regression):
    Maintained but it doesn't show the differences in the cypress interface and
    you have to interact with them through the command line.
* [cypress-image-snapshot](https://github.com/jaredpalmer/cypress-image-snapshot):
    Most popular but it looks unmaintained
    ([1](https://github.com/jaredpalmer/cypress-image-snapshot/issues/231),
    [2](https://github.com/jaredpalmer/cypress-image-snapshot/issues/247))

Check the [Visual testing plugins
list](https://docs.cypress.io/plugins/directory#visual-testing) to see all
available solutions. Beware of the third party solutions like  [Percy](https://percy.io/)
and [Applitools](https://applitools.com/cypress/) as they send your pictures to
their servers on each test.

### `cypress-visual-regression`

#### Installation

```bash
npm install --save-dev cypress-visual-regression
```

Add the following config to your `cypress.json` file:

```json
{
  "screenshotsFolder": "./cypress/snapshots/actual",
  "trashAssetsBeforeRuns": true
}
```

Add the plugin to `cypress/plugins/index.js`:

```javascript
const getCompareSnapshotsPlugin = require('cypress-visual-regression/dist/plugin');

module.exports = (on, config) => {
  getCompareSnapshotsPlugin(on, config);
};
```

Add the command to `cypress/support/commands.js`:

```javascript
const compareSnapshotCommand = require('cypress-visual-regression/dist/command');

compareSnapshotCommand();
```

Make sure you import `commands.js` in `cypress/support/index.js`:

```javascript
import './commands'
```

#### Use

Add `cy.compareSnapshot('home')` in your tests specs whenever you want to test
for visual regressions, making sure to replace home with a relevant name. You
can also add an optional error threshold: Value can range from 0.00 (no
difference) to 1.00 (every pixel is different). So, if you enter an error
threshold of 0.51, the test would fail only if > 51% of pixels are different. For example:

```javascript
it('should display the login page correctly', () => {
  cy.visit('/03.html');
  cy.get('H1').contains('Login');
  cy.compareSnapshot('login', 0.0);
  cy.compareSnapshot('login', 0.1);
});
```

You can target a single HTML element as well:

```javascript
cy.get('#my-header').compareSnapshot('just-header')
```

Check more examples [here](https://github.com/mjhea0/cypress-visual-regression/blob/master/docker/cypress/integration/main.spec.js)

You need to take or update the base images, do it with:

```bash
npx cypress run \
    --env type=base \
    --config screenshotsFolder=cypress/snapshots/base,testFiles=\"**/*regression-tests.js\"
```

To find regressions run:

```bash
npx cypress run --env type=actual
```

Or if you want to just check a subset of tests use:

```bash
npx cypress run --env type=actual --spec "cypress\integration\visual-tests.spec.js"
npx cypress run --env type=actual --spec "cypress\integration\test1.spec.js","cypress\integration\test2.spec.js"
npx cypress run --env type=actual --spec "cypress\integration\**\*.spec.js
```

## Third party component testing

Other examples of testing third party components

* [Testing HTML emails](https://www.cypress.io/blog/2021/05/11/testing-html-emails-using-cypress/)

# [Configuration](https://docs.cypress.io/guides/references/configuration)

Cypress saves it's configuration in the `cypress.json` file.

```javascript
{
  "baseUrl": "http://localhost:8080"
}
```

Where:

* `baseUrl`: Will be prefixed on `cy.visit()` and `cy.requests()`.

## [Environment variables](https://docs.cypress.io/guides/guides/environment-variables#Setting)

Environment variables are useful when:

* Values are different across developer machines.
* Values are different across multiple environments: (dev, staging, qa, prod).
* Values change frequently and are highly dynamic.

Instead of hard coding this in your tests:

```javascript
cy.request('https://api.acme.corp') // this will break on other environments
```

We can move this into a Cypress environment variable:

```javascript
cy.request(Cypress.env('EXTERNAL_API')) // points to a dynamic env var
```

Any key/value you set in your configuration file under
the `env` key will become an environment variable.

```json
{
  "projectId": "128076ed-9868-4e98-9cef-98dd8b705d75",
  "env": {
    "login_url": "/login",
    "products_url": "/products"
  }
}
```

To access it use:

```javascript
Cypress.env() // {login_url: '/login', products_url: '/products'}
Cypress.env('login_url') // '/login'
Cypress.env('products_url') // '/products'
```

## Configure component testing

You can configure or override Component Testing defaults in your configuration
file using the `component` key.

```javascript
{
  "testFiles": "cypress/integration/*.spec.js",
  "component": {
    "componentFolder": "src",
    "testFiles": ".*/__tests__/.*spec.tsx",
    "viewportHeight": 500,
    "viewportWidth": 700
  }
}
```


# [Debugging](https://docs.cypress.io/guides/guides/debugging#What-you-ll-learn)

## Using the debugger

Use the `.debug()` command directly BEFORE the action.

```javascript
// break on a debugger before the action command
cy.get('button').debug().click()
```

## Step through test commands

You can run the test command by command using the `.pause()` command.

```javascript
it('adds items', () => {
  cy.pause()
  cy.get('.new-todo')
  // more commands
})
```

This allows you to inspect the web application, the DOM, the network, and any
storage after each command to make sure everything happens as expected.

# Issues

* [Allow rerun only failed
    tests](https://github.com/cypress-io/cypress/issues/4886): Until it's ready
    use `it.only` on the test you want to run.

# References

* [Home](https://www.cypress.io/)
* [Git](https://github.com/cypress-io/cypress)
* [Examples of usage](https://github.com/cypress-io/cypress-example-recipes#logging-in-recipes)
* [Cypress API](https://docs.cypress.io/api/table-of-contents)
* [Real World Application Cypress testing example](https://github.com/cypress-io/cypress-realworld-app)
* [Tutorial on writing
    tests](https://docs.cypress.io/guides/getting-started/writing-your-first-test)
* [Video tutorials](https://docs.cypress.io/examples/examples/tutorials)
