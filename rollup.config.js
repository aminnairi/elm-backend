import elm from "rollup-plugin-elm"

export default {
  input: "src/runtime.js",
  external: [
    "crypto",
    "http",
    "path",
    "sqlite",
    "sqlite3"
  ],
  plugins: [
    elm()
  ],
  output: {
    file: "output/main.js",
    format: "esm"
  }
}
