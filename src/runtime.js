import crypto from "crypto"
import http from "http"
import path from "path"
import sqlite3 from "sqlite3"
import * as sqlite from "sqlite"
import Elm from "./Main.elm"

const generateEmail = () => {
  return `${crypto.randomUUID()}@gmail.com`
}

const generateIdentifier = () => {
  return crypto.randomUUID()
}

const database = await sqlite.open({
  filename: "database.sqlite",
  driver: sqlite3.Database
})

await database.exec("DROP TABLE IF EXISTS users")
await database.exec("CREATE TABLE users(id TEXT PRIMARY KEY NOT NULL, email TEXT NOT NULL)")

await database.run("INSERT INTO users(id, email) VALUES(?, ?)", [generateIdentifier(), generateEmail()])

const main = Elm.Main.init({
  flags: {}
})

main.ports.getUsers.subscribe(() => {
  database.all("SELECT * FROM users").then(users => {
    main.ports.onGetUsers.send(JSON.stringify(users))
  }).catch(() => {
    main.ports.onGetUsers.send(JSON.stringify([]))
  })
})

const server = http.createServer((request, response) => {
  const url = new URL(path.join("http://localhost", request.url))
  const pathname = url.pathname
  const method = request.method

  const elmRequest = JSON.stringify({
    pathname,
    method
  })

  main.ports.sendResponse.subscribe(elmResponse => {
    response.writeHead(elmResponse.status, Object.fromEntries(elmResponse.headers))

    response.end(elmResponse.body)

    main.ports.sendResponse.unsubscribe()
  })

  main.ports.onRequest.send(elmRequest)
})

server.listen(8000, "0.0.0.0", () => {
  console.log("Elm server listening")
})
