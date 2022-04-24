---
title: Vuetify
date: 20220418
author: Lyz
---

[Vuetify](https://vuetifyjs.com/en/) is a Vue UI Library with beautifully
handcrafted Material Components.

# [Install](https://next.vuetifyjs.com/en/getting-started/installation/#installation)

First you need `vue-cli`, install it with:

```bash
sudo npm install -g @vue/cli
```

Then run:

```bash
vue add vuetify
```

If you're using [Vite](vite.md) select `Vite Preview (Vuetify 3 + Vite)`.

# Usage

## Position elements with Flex

Vuetify comes with a 12 point grid system built using [flexbox](css.md#flexbox-layout). The grid is used
to create specific layouts within an application’s content.

It is integrated by using a series of containers, rows, and columns to layout
and align content.

Vuetify makes it so that you do not need to to write css flex class inside your
web application. It has two different ways to handle flex design.

* Using [flex-helpers](https://vuetifyjs.com/en/styles/flex/).

* Using v-row (as a flex-container) and v-col (as a flex-item).

    ```html
     <v-container>
       <v-row>
        <v-col>
          <v-card
            class="pa-2"
            outlined
            tile
          >
            One of three columns
          </v-card>
        </v-col>
        <v-col>
          <v-card
            class="pa-2"
            outlined
            tile
          >
            One of three columns
          </v-card>
        </v-col>
        <v-col>
          <v-card
            class="pa-2"
            outlined
            tile
          >
            One of three columns
          </v-card>
        </v-col>
      </v-row>
    </v-container>
    ```

`v-col` and `v-row` have the next properties to manage how to order the content:

* `align`: set the vertical alignment of flex items (one of
    `start`, `center` and `end`).
* `justify`: set the horizontal alignment of the flex items (one of `start`,
    `center`, `end`, `space-around`, `space-between`).

### Margins

You can define the margins you want with:

* `ma-2`: 2 points in all directions.
* `mb-2`: 2 points of margin on bottom.
* `mt-2`: 2 points of margin on top.
* `mr-2`: 2 points of margin on right.
* `ml-2`: 2 points of margin on left.

If instead of a number you use `auto` it will fill it till the end of the
container.

To center things around, you can use `mx-auto` to center in the X axis and
`my-auto` for the Y axis.

If you are using a `flex-column` and you want to put an element to the bottom,
you'll use `mt-auto` so that the space filled on top of the element is filled
automatically.

# Elements

## Fonts

By default it uses the webfontload plugin which slows down a lot the page load,
instead you can install the fonts directly. For example for the Roboto font:

* Install the font

    ```bash
    npm install --save typeface-roboto
    ```

* Uninstall the webfontload plugin

    ```bash
    npm remove webfontloader
    ```

* Remove the loading of the webfontload in `/main.js` the lines:

    ```javascript
    import { loadFonts } from './plugins/webfontloader'

    loadFonts()
    ```
* Add the font in the `App.vue` file:

    ```html
    <style lang="sass">
      @import '../node_modules/typeface-roboto/index.css'
    </style>
    ```

## [Icons](https://next.vuetifyjs.com/en/components/icons/)

The [`v-icon`](https://next.vuetifyjs.com/en/api/v-icon) component provides a large set of glyphs to provide context to various aspects of your application.

```html
<v-icon>fas fa-user</v-icon>
```

If you have the FontAwesome icons installed, browse them
[here](https://fontawesome.com/search)

### [Install font awesome icons](https://next.vuetifyjs.com/en/features/icon-fonts/#font-awesome-5-icons)

```bash
npm install @fortawesome/fontawesome-free -D
```

```javascript

// src/plugins/vuetify.js
import '@fortawesome/fontawesome-free/css/all.css' // Ensure your project is capable of handling css files
import { createVuetify } from 'vuetify'
import { aliases, fa } from 'vuetify/lib/iconsets/fa'

export default createVuetify({
  icons: {
    defaultSet: 'fa',
    aliases,
    sets: {
      fa,
    },
  },
})
```

```html
<template>
  <v-icon icon="fas fa-home" />
</template>
```

# Testing

I tried doing component tests with Jest, [Vitest](vitest.md) and [Cypress](cypress.md) and found no
way of making component tests, they all fail one way or the other.

E2E tests worked with Cypress however, that's going to be my way of action till
this is solved.

# References

* [Home](https://vuetifyjs.com/en/)
* [Git](https://github.com/vuetifyjs/vuetify)
* [Discord](https://community.vuetifyjs.com/)
