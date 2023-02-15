# Emo

**Emo** is an educational project that aims to improve programmers'
understanding of the machine by creating a RISC CPU emulator that resembles real
life processors. Emo is implemented in Go and compiles to WebAssembly so that
users can access and manipulate its state using our Elm based web UI.

## Dependencies

- [Go](https://go.dev/)
- [Elm](https://elm-lang.org/)

## Docker Pull and Play

Would you line to have your own no-hustle local Emo playground? It's extremely
simple with Docker.

```bash
docker pull sharpvik/emo:stable
#           sharpvik/emo:latest is also available if you're brave enough to try
docker run --rm -p 8000:8000 sharpvik/emo:stable
```

Go to <http://localhost:8000> to see it in action!

## Clone and Play

If you wanted to build and serve Emo on your own machine without using Docker,
follow instructions below.

### Clone and Build

> Make sure that you have observed our dependencies list above before
> proceeding to the next step!

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
learn more!
