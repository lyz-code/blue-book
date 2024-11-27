---
title: Abstract syntax trees
date: 20220902
author: Lyz
---

[Abstract syntax trees](https://en.wikipedia.org/wiki/Abstract_syntax_tree)
(AST) is a tree representation of the abstract syntactic structure of text
(often source code) written in a formal language. Each node of the tree denotes
a construct occurring in the text.

The syntax is "abstract" in the sense that it does not represent every detail
appearing in the real syntax, but rather just the structural or content-related
details. For instance, grouping parentheses are implicit in the tree structure,
so these do not have to be represented as separate nodes. Likewise, a syntactic
construct like an if-condition-then statement may be denoted by means of
a single node with three branches.

This distinguishes abstract syntax trees from concrete syntax trees,
traditionally designated parse trees. Parse trees are typically built by
a parser during the source code translation and compiling process. Once built,
additional information is added to the AST by means of subsequent processing,
e.g., contextual analysis.

Abstract syntax trees are also used in program analysis and program transformation systems.

# [How to construct an AST](https://stackoverflow.com/questions/1721553/how-to-construct-an-abstract-syntax-tree)

TBD

[`pyparsing`](https://github.com/pyparsing/pyparsing/) looks to be a good
candidate to implement ASTs.
