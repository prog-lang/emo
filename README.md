# Emo

**Emo** is an educational project that aims to improve programmers'
understanding of the machine by creating a RISC CPU emulator that resembles real
life processors. Emo is implemented in Go and compiles to WebAssembly so that
users can access and manipulate its state using our Elm based web UI.

## Dependencies

- [Go](https://go.dev/)
- [Elm](https://elm-lang.org/)

## Clone and Play

> **TODO:** include Dockerfile.

If you wanted to play with Emo on your own machine, follow instructions below.

### Clone and Build

```bash
git clone git@github.com:prog-lang/emo.git
cd emo
make all
```

### Serve Web UI Locally

As soon as you `make all`, the `dist` folder is going to be filled with a few
build artifacts and ready to be served. Use any tool you like to do that.

> If you don't have a local static file server utility yet, consider using
> [`serve`](https://github.com/sharpvik/serve).

```bash
serve --dir dist --port 8000
```

Go to <http://localhost:8000> to see it in action!

## Contributing

You can help develop and improve Emo. Read [CONTRIBUTING.md](CONTRIBUTING.md) to
lear more!
