---
title: Vue snippets
date: 20220419
author: Lyz
---

# Apply a style to a component given a condition

if you use `:class` you can write javascript code in the value, for example:

```html
<b-form-radio
  class="user-retrieve-language p-2"
  :class="{'font-weight-bold': selected === language.key}"
  v-for="language in languages"
  v-model="selected"
  :id="language.key"
  :checked="selected === language.key"
  :value="language.key"
>
```

# Get assets url

If you're using Vite, you can save the assets such as images or audios in the
`src/assets` directory, and you can get the url with:

```javascript

getImage() {
  return new URL(`../assets/pictures/${this.active_id}.jpg`, import.meta.url).href
},
```

This way it will give you the correct url whether you're in the development
environment or in production.

# [Play audio files](https://www.w3schools.com/jsref/dom_obj_audio.asp)

You can get the file and save it into a `data` element with:

```javascript
getAudio() {
  this.audio = new Audio(new URL(`../assets/audio/${this.active_id}.mp3`, import.meta.url).href)
},
```

You can start playing with `this.audio.play()`, and stop with
`this.audio.pause()`.

# [Run function in background](https://renatello.com/vue-js-polling-using-setinterval/)

To achieve that you need to use [the javascript method called
`setInterval()`](javascript.md#timing-events). It’s a simple function that would
repeat the same task over and over again. Here’s an example:

```javascript
function myFunction() {
	setInterval(function(){ alert("Hello world"); }, 3000);
}
```

If you add a call to this method for any button and click on it, it will print
Hello world every 3 seconds (3000 milliseconds) until you close the page.

In Vue you could do something like:

```vue

<script>
export default {
  data: () => ({
    inbox_retry: undefined
  }),
  methods: {
    retryGetInbox() {
      this.inbox_retry = setInterval(() => {
        if (this.showError) {
          console.log('Retrying the fetch of the inbox')
          // Add your code here.
        } else {
          clearInterval(this.inbox_retry)
        }
      }, 30000)
    }
  },
```

You can call `this.retryGetInbox()` whenever you want to start running the
function periodically. Once `this.showError` is `false`, we stop running the
function with `clearInterval(this.inbox_retry)`.

# [Truncate text given a height](https://vue-clamp.vercel.app/)

By default css is able to truncate text with the size of the screen but only on
one line, if you want to fill up a portion of the screen (specified in number of
lines or height css parameter) and then truncate all the text that overflows,
you need to use [vue-clamp](https://vue-clamp.vercel.app/).

They have a nice demo in their page where you can see their features.

## Installation

If you're lucky and [this
issue](https://github.com/Justineo/vue-clamp/issues/55) has been solved, you can
simply:

```bash
npm i --save vue-clamp
```

Else you need to create the Vue component yourself

??? note "VueClamp.vue"

    ```vue
    <script>
    import { addListener, removeListener } from "resize-detector";
    import { defineComponent } from "vue";
    import { h } from "vue";

    export default defineComponent({
      name: "vue-clamp",
      props: {
        tag: {
          type: String,
          default: "div",
        },
        autoresize: {
          type: Boolean,
          default: false,
        },
        maxLines: Number,
        maxHeight: [String, Number],
        ellipsis: {
          type: String,
          default: "…",
        },
        location: {
          type: String,
          default: "end",
          validator(value) {
            return ["start", "middle", "end"].indexOf(value) !== -1;
          },
        },
        expanded: Boolean,
      },
      data() {
        return {
          offset: null,
          text: this.getText(),
          localExpanded: !!this.expanded,
        };
      },
      computed: {
        clampedText() {
          if (this.location === "start") {
            return this.ellipsis + (this.text.slice(0, this.offset) || "").trim();
          } else if (this.location === "middle") {
            const split = Math.floor(this.offset / 2);
            return (
              (this.text.slice(0, split) || "").trim() +
              this.ellipsis +
              (this.text.slice(-split) || "").trim()
            );
          }

          return (this.text.slice(0, this.offset) || "").trim() + this.ellipsis;
        },
        isClamped() {
          if (!this.text) {
            return false;
          }
          return this.offset !== this.text.length;
        },
        realText() {
          return this.isClamped ? this.clampedText : this.text;
        },
        realMaxHeight() {
          if (this.localExpanded) {
            return null;
          }
          const { maxHeight } = this;
          if (!maxHeight) {
            return null;
          }
          return typeof maxHeight === "number" ? `${maxHeight}px` : maxHeight;
        },
      },
      watch: {
        expanded(val) {
          this.localExpanded = val;
        },
        localExpanded(val) {
          if (val) {
            this.clampAt(this.text.length);
          } else {
            this.update();
          }
          if (this.expanded !== val) {
            this.$emit("update:expanded", val);
          }
        },
        isClamped: {
          handler(val) {
            this.$nextTick(() => this.$emit("clampchange", val));
          },
          immediate: true,
        },
      },
      mounted() {
        this.init();

        this.$watch(
          (vm) => [vm.maxLines, vm.maxHeight, vm.ellipsis, vm.isClamped].join(),
          this.update
        );
        this.$watch((vm) => [vm.tag, vm.text, vm.autoresize].join(), this.init);
      },
      updated() {
        this.text = this.getText();
        this.applyChange();
      },
      beforeUnmount() {
        this.cleanUp();
      },
      methods: {
        init() {
          const contents = this.$slots.default();

          if (!contents) {
            return;
          }

          this.offset = this.text.length;

          this.cleanUp();

          if (this.autoresize) {
            addListener(this.$el, this.update);
            this.unregisterResizeCallback = () => {
              removeListener(this.$el, this.update);
            };
          }
          this.update();
        },
        update() {
          if (this.localExpanded) {
            return;
          }
          this.applyChange();
          if (this.isOverflow() || this.isClamped) {
            this.search();
          }
        },
        expand() {
          this.localExpanded = true;
        },
        collapse() {
          this.localExpanded = false;
        },
        toggle() {
          this.localExpanded = !this.localExpanded;
        },
        getLines() {
          return Object.keys(
            Array.prototype.slice
              .call(this.$refs.content.getClientRects())
              .reduce((prev, { top, bottom }) => {
                const key = `${top}/${bottom}`;
                if (!prev[key]) {
                  prev[key] = true;
                }
                return prev;
              }, {})
          ).length;
        },
        isOverflow() {
          if (!this.maxLines && !this.maxHeight) {
            return false;
          }

          if (this.maxLines) {
            if (this.getLines() > this.maxLines) {
              return true;
            }
          }

          if (this.maxHeight) {
            if (this.$el.scrollHeight > this.$el.offsetHeight) {
              return true;
            }
          }
          return false;
        },
        getText() {
          // Look for the first non-empty text node
          const [content] = (this.$slots.default() || []).filter(
            (node) => !node.tag && !node.isComment
          );
          return content ? content.children : "";
        },
        moveEdge(steps) {
          this.clampAt(this.offset + steps);
        },
        clampAt(offset) {
          this.offset = offset;
          this.applyChange();
        },
        applyChange() {
          this.$refs.text.textContent = this.realText;
        },
        stepToFit() {
          this.fill();
          this.clamp();
        },
        fill() {
          while (
            (!this.isOverflow() || this.getLines() < 2) &&
            this.offset < this.text.length
          ) {
            this.moveEdge(1);
          }
        },
        clamp() {
          while (this.isOverflow() && this.getLines() > 1 && this.offset > 0) {
            this.moveEdge(-1);
          }
        },
        search(...range) {
          const [from = 0, to = this.offset] = range;
          if (to - from <= 3) {
            this.stepToFit();
            return;
          }
          const target = Math.floor((to + from) / 2);
          this.clampAt(target);
          if (this.isOverflow()) {
            this.search(from, target);
          } else {
            this.search(target, to);
          }
        },
        cleanUp() {
          if (this.unregisterResizeCallback) {
            this.unregisterResizeCallback();
          }
        },
      },
      render() {
        const contents = [
          h(
            "span",
            {
              ref: "text",
              attrs: {
                "aria-label": this.text?.trim(),
              },
            },
            this.realText
          ),
        ];

        const { expand, collapse, toggle } = this;
        const scope = {
          expand,
          collapse,
          toggle,
          clamped: this.isClamped,
          expanded: this.localExpanded,
        };
        const before = this.$slots.before
          ? this.$slots.before(scope)
          : this.$slots.before;
        if (before) {
          contents.unshift(...(Array.isArray(before) ? before : [before]));
        }
        const after = this.$slots.after
          ? this.$slots.after(scope)
          : this.$slots.after;
        if (after) {
          contents.push(...(Array.isArray(after) ? after : [after]));
        }
        const lines = [
          h(
            "span",
            {
              style: {
                boxShadow: "transparent 0 0",
              },
              ref: "content",
            },
            contents
          ),
        ];
        return h(
          this.tag,
          {
            style: {
              maxHeight: this.realMaxHeight,
              overflow: "hidden",
            },
          },
          lines
        );
      },
    });
    </script>
    ```

## Usage

If you were able to install it with `npm`, use:

```vue
<template>
<v-clamp autoresize :max-lines="3">{{ text }}</v-clamp>
</template>

<script>
import VClamp from 'vue-clamp'

export default {
  components: {
    VClamp
  },
  data () {
    return {
      text: 'Some very very long text content.'
    }
  }
}
</script>
```

Else use:

```vue
<template>
  <VueClamp maxHeight="30vh">
  {{ text }}
  </VueClamp>
</template>

<script>
import VueClamp from './VueClamp.vue'

export default {
  components: {
    VueClamp
  },
  data () {
    return {
      text: 'Some very very long text content.'
    }
  }
}
</script>
```

# [Display time ago from timestamp](https://vue2-timeago.netlify.app/guide/timeago/timeago.html)

Install with:

```bash
npm install vue2-timeago@next
```
