# Contributing to Emo

You can contribute in a few different ways:

1. [Create an issue][issue] to tell us about a bug you found
2. [Propose an improvement][improve] by dropping us an email
3. Contribute code - it is _much_ appreciated

[issue]: https://github.com/prog-lang/emo/issues/new
[improve]: mailto:sharp.vik@gmail.com

## Contribute Code

Suppose you clone this repo, play around with Emo, and find something you'd like
to improve. Perhaps you are familiar with some of the technologies from Emo's
tech stack and decide that this project is worth your while. Here's what you
should do:

1. [Fork it!](https://github.com/prog-lang/emo/fork)
2. Clone your own Emo fork
3. Make some changes and submit a pull request

We are going to take a look at your code, discuss a few things if necessary,
and, hopefully, merge your changes. It's _that_ simple.

### Project Layout

- [cmd](cmd) - entrypoints for Go programs
  - [cmd/tools](cmd/tools) - build tools
- [dist](dist) - static files to be served
  - [dist/js](dist/js) - `setup.js` and scripts generated by `make all`
- [pkg](pkg) - Go packages
- [src](src) - Elm source code
