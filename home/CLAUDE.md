# CLAUDE.md

Guidance for Claude Code when working anywhere under `~`.

## Fetching HTTP APIs

When you need the response body of an HTTP endpoint — checking a local service,
reading a JSON API, verifying that a route works — use the `get` script instead of
writing your own `curl` invocation:

```bash
~/.claude/bin/get <url> [extra curl args...]
```

It is a thin `curl` wrapper that does a GET and nothing else:

- **stdout is the response body only** — pipe it straight into `jq`.
- Status code, content type, size and duration go to **stderr**.
- Non-2xx still prints the body, and exits non-zero.
- Follows redirects; 10s connect / 30s total timeout (override with
  `GET_CONNECT_TIMEOUT` / `GET_MAX_TIME`).
- GET only: `-X`, `-d`/`--data*`, `--json`, `-F`, `-T`, `-I`, `-o`/`-O` are rejected.

```bash
~/.claude/bin/get http://localhost:8080/api/items | jq '.[0]'
~/.claude/bin/get https://api.example.com/v1/status -H 'Accept: application/json'
```

## Sending request bodies

For requests that carry a payload, use the `post`, `put` and `patch` scripts:

```bash
~/.claude/bin/post  <url> [body] [extra curl args...]
~/.claude/bin/put   <url> [body] [extra curl args...]
~/.claude/bin/patch <url> [body] [extra curl args...]
```

They behave exactly like `get` — body on stdout, status on stderr, non-2xx prints
the body and exits non-zero — with the request body as the second argument:

- `'<text>'` — sent verbatim.
- `@<file>` — contents of that file.
- `-` — read from stdin; also the default when stdin is piped.
- omitted with stdin on a terminal — empty body.

Further notes:

- **Content-Type defaults to `application/json`**, unless you pass your own
  `-H 'Content-Type: ...'`. For `patch` that default is plain `application/json`
  too — pass the header yourself when the API wants
  `application/merge-patch+json` or `application/json-patch+json`.
- The method is fixed, so `-X`, `-d`/`--data*`, `--json`, `-F`, `-T`, `-G`, `-I` and
  `-o`/`-O` are rejected — the body belongs in the positional argument.
- Redirects are followed with the method *and* the body preserved.
- Timeouts as with `get`, via `POST_CONNECT_TIMEOUT` / `POST_MAX_TIME`,
  `PUT_CONNECT_TIMEOUT` / `PUT_MAX_TIME` and
  `PATCH_CONNECT_TIMEOUT` / `PATCH_MAX_TIME`.

```bash
~/.claude/bin/post  http://localhost:8080/api/items '{"name":"box"}' | jq .id
~/.claude/bin/put   http://localhost:8080/api/items/7 @payload.json
~/.claude/bin/patch http://localhost:8080/api/items/7 '{"name":"crate"}'
jq -n '{name:"box"}' | ~/.claude/bin/post http://localhost:8080/api/items
~/.claude/bin/post  http://localhost:8080/api/note 'hi' -H 'Content-Type: text/plain'
~/.claude/bin/patch http://localhost:8080/api/items/7 '[{"op":"replace","path":"/name","value":"crate"}]' \
  -H 'Content-Type: application/json-patch+json'
```

## Deleting resources

For DELETE, use the `delete` script:

```bash
~/.claude/bin/delete <url> [body] [extra curl args...]
```

Same contract as the rest — body on stdout, status on stderr, non-2xx prints the
body and exits non-zero, redirects followed with the method preserved — with two
differences that follow from DELETE rarely carrying a payload:

- **Without a body argument the request is sent bodyless**: no `Content-Length`,
  no `Content-Type`.
- **A piped stdin is not picked up by itself.** Ask for it with `-`, which is the
  one case where `delete` reads stdin. `'<text>'` and `@<file>` work as they do
  for `post`, and a body then gets the usual `application/json` default.

Timeouts as with `get`, via `DELETE_CONNECT_TIMEOUT` / `DELETE_MAX_TIME`. The
same flags are rejected as for the other wrappers.

```bash
~/.claude/bin/delete http://localhost:8080/api/items/7
~/.claude/bin/delete https://api.example.com/v1/items/7 -H 'Authorization: Bearer ...'
~/.claude/bin/delete http://localhost:8080/api/items '{"ids":[1,2]}'
jq -n '{ids:[1,2]}' | ~/.claude/bin/delete http://localhost:8080/api/items -
```

A DELETE is not reversible and is usually not yours to decide: ask first unless
the target is something created in this session, or the user asked for the
deletion outright.

All four share their implementation with `~/.claude/bin/_http-send`; edit that
file rather than the wrappers.

Reach for plain `curl` only when the request is none of these five — inspecting
headers with `-I`, a multipart form, a streaming file upload, or an exotic method
like HEAD or OPTIONS. Don't use `get`/`post`/`put`/`patch`/`delete` for that —
they will refuse.
