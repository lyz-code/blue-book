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

## [Flex](https://vuetifyjs.com/en/styles/flex/)

Control the layout of flex containers with alignment, justification and more
with responsive flexbox utilities.

!!! note
        "I suggest you use this page only as a reference, if it's the first time
        you see this content, it's better to see it at the
        [source](https://vuetifyjs.com/en/styles/flex) as you can see Flex in
        action at the same time you read, which makes it much more easy to
        understand."

Using `display` utilities you can turn any element into a flexbox container
transforming direct children elements into flex items. Using additional flex
property utilities, you can customize their interaction even further.

You can also customize flex utilities to apply based upon various breakpoints.

* `.d-flex`
* `.d-inline-flex`
* `.d-sm-flex`
* `.d-sm-inline-flex`
* `.d-md-flex`
* `.d-md-inline-flex`
* `.d-lg-flex`
* `.d-lg-inline-flex`
* `.d-xl-flex`
* `.d-xl-inline-flex`

You define the attributes inside the `class` of the Vuetify object. For example:

```html
<v-card class="d-flex flex-row mb-6" />
```

### [Display breakpoints](https://vuetifyjs.com/en/features/breakpoints/)

With Vuetify you can control various aspects of your application based upon the
window size.

| Device      | Code | Type                   | Range                |
| ---         | ---  | ---                    | ---                  |
| Extra small | xs   | Small to large phone   | `< 600px`            |
| Small       | sm   | Small to medium tablet | `600px > < 960px`    |
| Medium      | md   | Large tablet to laptop | `960px > < 1264px*`  |
| Large       | lg   | Desktop                | `1264px > < 1904px*` |
| Extra large | xl   | 4k and ultra-wide      | `> 1904px*`          |

The breakpoint service is a programmatic way of accessing viewport information
within components. It exposes a number of properties on the `$vuetify` object that
can be used to control aspects of your application based upon the viewport size.
The `name` property correlates to the currently active breakpoint; e.g. xs, sm,
md, lg, xl.

In the following snippet, we use a switch statement and the current breakpoint
name to modify the `height` property of the `v-card` component:

```html
<template>
  <v-card :height="height">
    ...
  </v-card>
</template>

<script>
  export default {
    computed: {
      height () {
        switch (this.$vuetify.breakpoint.name) {
          case 'xs': return 220
          case 'sm': return 400
          case 'md': return 500
          case 'lg': return 600
          case 'xl': return 800
        }
      },
    },
  }
</script>
```

The following is the public signature for the breakpoint service:

```javascript
{
  // Breakpoints
  xs: boolean
  sm: boolean
  md: boolean
  lg: boolean
  xl: boolean

  // Conditionals
  xsOnly: boolean
  smOnly: boolean
  smAndDown: boolean
  smAndUp: boolean
  mdOnly: boolean
  mdAndDown: boolean
  mdAndUp: boolean
  lgOnly: boolean
  lgAndDown: boolean
  lgAndUp: boolean
  xlOnly: boolean

  // true if screen width < mobileBreakpoint
  mobile: boolean
  mobileBreakpoint: number

  // Current breakpoint name (e.g. 'md')
  name: string

  // Dimensions
  height: number
  width: number

  // Thresholds
  // Configurable through options
  {
    xs: number
    sm: number
    md: number
    lg: number
  }

  // Scrollbar
  scrollBarWidth: number
}
```

Access these properties within Vue files by referencing
`$vuetify.breakpoint.<property>` For example to log the current viewport width
to the console once the component fires the mounted lifecycle hook you can use:

```html
<!-- Vue Component -->

<script>
  export default {
    mounted () {
      console.log(this.$vuetify.breakpoint.width)
    }
  }
</script>
```

### [Flex direction](https://vuetifyjs.com/en/styles/flex/#flex-direction)

By default, `d-flex` applies `flex-direction: row` and can generally be omitted.

The `flex-column` and `flex-column-reverse` utility classes can be used to change
the orientation of the flexbox container.

There are also responsive variations for flex-direction.

* `.flex-row`
* `.flex-row-reverse`
* `.flex-column`
* `.flex-column-reverse`
* `.flex-sm-row`
* `.flex-sm-row-reverse`
* `.flex-sm-column`
* `.flex-sm-column-reverse`
* `.flex-md-row`
* `.flex-md-row-reverse`
* `.flex-md-column`
* `.flex-md-column-reverse`
* `.flex-lg-row`
* `.flex-lg-row-reverse`
* `.flex-lg-column`
* `.flex-lg-column-reverse`
* `.flex-xl-row`
* `.flex-xl-row-reverse`
* `.flex-xl-column`
* `.flex-xl-column-reverse`

### [Flex justify](https://vuetifyjs.com/en/styles/flex/#flex-justify)

The `justify-content` flex setting can be changed using the flex justify
classes. This by default will modify the flexbox items on the *x-axis* but is
reversed when using `flex-direction: column`, modifying the *y-axis*. Choose
from:

* `start` (browser default): Everything together on the left.
* `end`: Everything together on the right.
* `center`: Everything together on the center.
* `space-between`: First item on the top left, second on the center, third at
    the end, with space between the items.
* `space-around`: Like `space-between` but with space on the top left and right
    too.

For example:

```html
<v-card class="d-flex justify-center mb-6" />
```

There are also responsive variations for `justify-content`.

* `.justify-start`
* `.justify-end`
* `.justify-center`
* `.justify-space-between`
* `.justify-space-around`
* `.justify-sm-start`
* `.justify-sm-end`
* `.justify-sm-center`
* `.justify-sm-space-between`
* `.justify-sm-space-around`
* `.justify-md-start`
* `.justify-md-end`
* `.justify-md-center`
* `.justify-md-space-between`
* `.justify-md-space-around`
* `.justify-lg-start`
* `.justify-lg-end`
* `.justify-lg-center`
* `.justify-lg-space-between`
* `.justify-lg-space-around`
* `.justify-xl-start`
* `.justify-xl-end`
* `.justify-xl-center`
* `.justify-xl-space-between`
* `.justify-xl-space-around`

### [Flex align](https://vuetifyjs.com/en/styles/flex/#flex-align)

The `align-items` flex setting can be changed using the flex align
classes. This by default will modify the flexbox items on the *y-axis* but is
reversed when using `flex-direction: column`, modifying the *x-axis*. Choose
from:

* `start`: Everything together on the top.
* `end`: Everything together on the bottom.
* `center`: Everything together on the center.
* `baseline`: (I don't understand this one).
* `align-stretch`: Align content to the top but extend the container to the
    bottom.
For example:

```html
<v-card class="d-flex align-center mb-6" />
```

There are also responsive variations for `align-items`.

* `.align-start`
* `.align-end`
* `.align-center`
* `.align-baseline`
* `.align-stretch`
* `.align-sm-start`
* `.align-sm-end`
* `.align-sm-center`
* `.align-sm-baseline`
* `.align-sm-stretch`
* `.align-md-start`
* `.align-md-end`
* `.align-md-center`
* `.align-md-baseline`
* `.align-md-stretch`
* `.align-lg-start`
* `.align-lg-end`
* `.align-lg-center`
* `.align-lg-baseline`
* `.align-lg-stretch`
* `.align-xl-start`
* `.align-xl-end`
* `.align-xl-center`
* `.align-xl-baseline`
* `.align-xl-stretch`

The `align-self` attribute works like `align` but for a single element instead
of all the children.

### [Margins](https://vuetifyjs.com/en/styles/flex/#auto-margins)

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

### [Flex grow and shrink](https://vuetifyjs.com/en/styles/flex/#flex-grow-and-shrink)

Vuetify has helper classes for applying grow and shrink manually. These can be
applied by adding the helper class in the format `flex-{condition}-{value}`, where
condition can be either `grow` or `shrink` and value can be either `0` or `1`. The
condition `grow` will permit an element to grow to fill available space, whereas
`shrink` will permit an element to shrink down to only the space needs for its
contents. However, this will only happen if the element must shrink to fit their
container such as a container resize or being effected by a `flex-grow-1`. The
value `0` will prevent the condition from occurring whereas `1` will permit the
condition. The following classes are available:

* `flex-grow-0`
* `flex-grow-1`
* `flex-shrink-0`
* `flex-shrink-1`

For example:

```html
<template>
  <v-container>
    <v-row
      no-gutters
      style="flex-wrap: nowrap;"
    >
      <v-col
        cols="2"
        class="flex-grow-0 flex-shrink-0"
      >
        <v-card>
          I'm 2 column wide
        </v-card>
      </v-col>
      <v-col
        cols="1"
        style="min-width: 100px; max-width: 100%;"
        class="flex-grow-1 flex-shrink-0"
      >
        <v-card>
          I'm 1 column wide and I grow to take all the space
        </v-card>
      </v-col>
      <v-col
        cols="5"
        style="min-width: 100px;"
        class="flex-grow-0 flex-shrink-1"
      >
        <v-card>
          I'm 5 column wide and I shrink if there's not enough space
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>
```

### Position elements with Flex

If the properties above don't give you the control you need you can use rows and
columns directly. Vuetify comes with a 12 point grid system built using
[Flexbox](css.md#flexbox-layout). The grid is used to create specific layouts
within an application’s content.

Using `v-row` (as a flex-container) and `v-col` (as a flex-item).

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

[`v-row`](https://vuetifyjs.com/en/api/v-row/) has the next properties:

* `align`: set the [vertical alignment](#flex-align) of flex items (one of
    `start`, `center` and `end`). It also has one property for each device size
    (`align-md`, `align-xl`, ...). The `align-content` variation is also
    available.
* `justify`: set the [horizontal alignment](#flex-jusitfy) of the flex items (one of `start`,
    `center`, `end`, `space-around`, `space-between`). It also has one property for each device size
    (`justify-md`, `justify-xl`, ...).
* `no-gutters`: Removes the spaces between items.
* `dense`: Reduces the spaces between items.

[`v-col`](https://vuetifyjs.com/en/api/v-col/) has the next properties:

* `cols`: Sets the default number of columns the component extends. Available
    options are `1 -> 12` and `auto`. you can use `lg`, `md`, ... to define the
    number of columns for the other sizes.

* `offset`: Sets the default offset for the column. You can also use `offset-lg`
    and the other sizes.

#### Keep the structure even if some components are hidden

If you want the components to remain in their position even if the items around
disappear, you need to use `<v-row>` and `<v-col>`. For example:

```html
<v-row align=end justify=center class="mt-auto">
  <v-col align=center>
    <v-btn
      v-show=isNotFirstElement
      ...
    >Button</v-btn>
  </v-col>
  <v-col align=center>
    <v-rating
      v-show="isNotLastElement"
      ...
    ></v-rating>
  </v-col>
  <v-col align=center>
    <v-btn
      v-show="isNotLastVisitedElement && isNotLastElement"
      ...
    >Button</v-btn>
  </v-col>
</v-row>
```

If instead you had use the next snippet, whenever one of the elements got
hidden, the rest would move around to fill up the remaining space.

```html
<v-row align=end justify=center class="mt-auto">
  <v-btn
    v-show=isNotFirstElement
    ...
  >Button</v-btn>
  <v-rating
    v-show="isNotLastElement"
    ...
  ></v-rating>
  <v-btn
    v-show="isNotLastVisitedElement && isNotLastElement"
    ...
  >Button</v-btn>
</v-row>
```

## [Themes](https://next.vuetifyjs.com/en/features/theme/)

Vuetify comes with two themes pre-installed, light and dark. To set the default
theme of your application, use the `defaultTheme` option.

!!! note "File: `src/plugins/vuetify.js`"
    ```javascript
    import { createApp } from 'vue'
    import { createVuetify } from 'vuetify'

    export default createVuetify({
      theme: {
        defaultTheme: 'dark'
      }
    })
    ```
Adding new themes is as easy as defining a new property in the `theme.themes`
object. A theme is a collection of colors and options that change the overall
look and feel of your application. One of these options designates the theme as
being either a light or dark variation. This makes it possible for Vuetify to
implement Material Design concepts such as elevated surfaces having a lighter
overlay color the higher up they are.

!!! note "File: `src/plugins/vuetify.js`"

    ```javascript
    import { createApp } from 'vue'
    import { createVuetify, ThemeDefinition } from 'vuetify'

    export default createVuetify({
      theme: {
        defaultTheme: 'myCustomLightTheme',
        themes: {
          myCustomLightTheme: {
            dark: false,
            colors: {
              background: '#FFFFFF',
              surface: '#FFFFFF',
              primary: '#510560',
              'primary-darken-1': '#3700B3',
              secondary: '#03DAC6',
              'secondary-darken-1': '#018786',
              error: '#B00020',
              info: '#2196F3',
              success: '#4CAF50',
              warning: '#FB8C00',
            }
          }
        }
      }
    })
    ```

To dynamically change theme during runtime.

```javascript
<template>
  <v-app>
    <v-btn @click="toggleTheme">toggle theme</v-btn>
    ...
  </v-app>
</template>

<script>
import { useTheme } from 'vuetify'

export default {
  setup () {
    const theme = useTheme()

    return {
      theme,
      toggleTheme: () => theme.global.name.value = theme.global.current.value.dark ? 'light' : 'dark'
    }
  }
}
</script>
```

Most components support the `theme` prop. When used, a new context is created
for that specific component and all of its children. In the following example,
the `v-btn` uses the dark theme applied by its parent `v-card`.

```javascript
<template>
  <v-app>
    <v-card theme="dark">
      <!-- button uses dark theme -->
      <v-btn>foo</v-btn>
    </v-card>
  </v-app>
</template>
```

# Elements

## [Cards](https://next.vuetifyjs.com/en/components/cards/)

The [`v-card`](https://next.vuetifyjs.com/en/api/v-card/) can be used to place
any kind of text on your site, in this case use the `variant=text`.

## [Buttons](https://next.vuetifyjs.com/en/api/v-btn/)

The `sizes` can be: `x-small`, `small`, `default`, `large`, `x-large`.

## Illustrations

You can get nice illustrations for your web on [Drawkit](https://drawkit.com),
for example I like to use the [Classic
kit](https://drawkit.com/product/drawkit-classic).

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

## Carousels

Vuetify has their own
[carousel](https://dev.vuetifyjs.com/en/components/carousels/#custom-transition)
component, [here's it's API](https://next.vuetifyjs.com/en/api/v-carousel/). In
the [Awesome Vue.js
compilation](https://next.awesome-vue.js.org/components-and-libraries/ui-components.html#carousel)
there are other suggestions. As some users say, it looks like [Vuetify's doesn't
have the best responsive
behaviour](https://stackoverflow.com/questions/67532319/how-do-i-make-vuetify-carousel-images-responsive-especially-on-mobile-screens).

The best looking alternatives I've seen are:

* [vue-agile](#vue-agile):
    [Demo](https://lukaszflorczak.github.io/vue-agile/).
* [vue-picture-swipe](https://github.com/rap2hpoutre/vue-picture-swipe)
* [vue-slick-carousel](https://github.com/gs-shop/vue-slick-carousel):
    [Demo](https://gs-shop.github.io/vue-slick-carousel/#/example/simple). It
    doesn't yet support Vue3
* [swiper](https://github.com/nolimits4web/swiper): [Demo](https://swiperjs.com/demos)
* [vue-splide](https://github.com/Splidejs/vue-splide): [Demo](https://splidejs.com/)

### Vuetify component

I tried binding the model with `v-model` but when I click on the arrows, the
image doesn't change and the binded property doesn't change. If I change the
property with other component, the image does change

### [vue-agile](https://github.com/lukaszflorczak/vue-agile)

If you encounter the `modules have no default` error, [add this to your
`vite.config.js`](https://github.com/lukaszflorczak/vue-agile/issues/237):

```javascript
export default defineConfig({
  ...
  optimizeDeps: { include: [ 'lodash.throttle', 'lodash.orderby' ] },
  ...
})
```

### Small vertical carousel

If you want to do a vertical carousel for example the one shown in the video
playlists, you can't yet use
[`v-slide-group`](https://github.com/vuetifyjs/vuetify/issues/11006).
[vue-agile](#vue-agile) doesn't either yet have [vertical
option](https://github.com/lukaszflorczak/vue-agile/issues/96).

## Audio

* [vuejs-sound-player](https://github.com/shershen08/vuejs-sound-player?ref=madewithvuejs.com)
* [vue-audio-visual](https://github.com/staskobzar/vue-audio-visual): [Demo](https://staskobzar.github.io/vue-audio-visual/)
* [vue3-audio-player](https://github.com/RealCoolSnow/vue3-audio-player?ref=vuejsexamples.com):
    [Demo](http://vue3-audio-player.joy666.cn/)
* [vuetify-audio](https://github.com/wilsonwu/vuetify-audio?ref=madewithvuejs.com):
    [Demo](https://wilsonwu.github.io/dist/index.html#/vuetifyaudio)

# Testing

I tried doing component tests with Jest, [Vitest](vitest.md) and [Cypress](cypress.md) and found no
way of making component tests, they all fail one way or the other.

E2E tests worked with Cypress however, that's going to be my way of action till
this is solved.

# References

* [Docs](https://vuetifyjs.com/en/getting-started/installation/)
* [Home](https://vuetifyjs.com/en/)
* [Git](https://github.com/vuetifyjs/vuetify)
* [Discord](https://community.vuetifyjs.com/)
