# elm-backend

Exploration for using Elm as a backend service

## Requirements

- [Git](https://git-scm.com/)
- [Node](https://nodejs.org)
- [NPM](https://www.npmjs.com/)

## Installation

```bash
git clone https://github.com/aminnairi/elm-backend
cd elm-backend
```

## Dependencies

```bash
npm install --force
```

> Note: the [`--force`](https://docs.npmjs.com/cli/v9/commands/npm-install#description) option is required here because [`rollup-plugin-elm`](https://www.npmjs.com/package/rollup-plugin-elm) does not support the latest release version [`3.x.x`](https://www.npmjs.com/package/rollup/v/3.0.0) from [`rollup`](https://www.npmjs.com/package/rollup) which is used as the bundler of choice for this project. See [issue](https://github.com/ulisses-alves/rollup-plugin-elm/issues/13) for more details.

## Build

```bash
npm run build
```

## Start

```bash
npm start
```

## Endpoints

Endpoint | Description
---|---
`http://localhost:8000` | Hello, world!
`http://localhost:8000/users` | List of users
