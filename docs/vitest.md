---
title: Vitest
date: 20220418
author: Lyz
---

[Vitest](https://vitest.dev/) is a blazing fast unit-test framework powered by
Vite.

# [Install](https://vitest.dev/guide/#overview)

Add it to your project with:

```bash
npm install -D vitest
```

If you've used Vite, Vitest will read the configuration from the
`vite.config.js` file so add the `test` property there.

```javascript
/// <reference types="vitest" />
import { defineConfig } from 'vite'

export default defineConfig({
  test: {
    // ...
  },
})
```

To run the tests use `npx vitest`, to see the coverage use `npx vitest
--coverage`.



# References

* [Home](https://vitest.dev/)
