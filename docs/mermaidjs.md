---
title: MermaidJS
date: 20210318
author: Lyz
---

[MermaidJS](https://mermaid-js.github.io) is a Javascript library that lets you create diagrams using text and code.

It can render the [next diagram
types](https://mermaid-js.github.io/mermaid/#/?id=diagrams-that-mermaid-can-render):

* Flowchart
* Sequence.
* Gantt
* Class
* Git graph
* Entity Relationship
* User journey

# Installation

Installing it requires node, I've only used it in [mkdocs](mkdocs.md#mermaidjs),
which is easier to install and use.

# Usage

## [Flowchart](https://mermaid-js.github.io/mermaid/#/flowchart)

It can have two orientations top to bottom (`TB`) or left to right (`LR`).

```
graph TD
    Start --> Stop
```

By default the text shown is the same as the id, if you need a big text it's
recommended to use the `id1[This is the text in the box]` syntax so it's easy to
reference the node in the relationships.

To link nodes, use `-->` or `---`. If you cant to add text to the link use
`A-- text -->B`

### [Adding links](https://mermaid-js.github.io/mermaid/#/flowchart?id=interaction)

You can add `click` events to the diagrams:

```
graph LR;
    A-->B;
    B-->C;
    C-->D;
    click A callback "Tooltip for a callback"
    click B "http://www.github.com" "This is a tooltip for a link"
    click A call callback() "Tooltip for a callback"
    click B href "http://www.github.com" "This is a tooltip for a link"
```

By default the links are opened in the same browser tab/window. It is possible
to change this by adding a link target to the click definition (`_self`,
`_blank`, `_parent`, or `_top`).

```
graph LR;
    A-->B;
    B-->C;
    C-->D;
    D-->E;
    click A "http://www.github.com" _blank
```
### [Node styling](https://mermaid-js.github.io/mermaid/#/flowchart?id=styling-a-node)

You can define the style for each node with:

```
graph LR
    id1(Start)-->id2(Stop)
    style id1 fill:#f9f,stroke:#333,stroke-width:4px
    style id2 fill:#bbf,stroke:#f66,stroke-width:2px,color:#fff,stroke-dasharray: 5 5
```

Or if you're going to use the same style for multiple nodes, you can define
classes:

```
graph LR
    A:::someclass --> B
    classDef someclass fill:#f96;
```

# References

* [Docs](https://mermaid-js.github.io)
