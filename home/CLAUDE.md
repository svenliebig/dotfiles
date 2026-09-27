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
- GET only, `http`/`https` only, one request per call. Responses are capped at 25 MB.
- Extra arguments are an **allowlist**: `-H`/`--header`, `--compressed`,
  `--connect-timeout`, `--max-time`. Everything else is refused, including the
  glued-on forms (`-XPOST`, `-o/tmp/x`) that a blocklist would miss.

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
- The method is fixed and the same argument allowlist applies — the body belongs
  in the positional argument, never in a flag.
- `@<file>` must name a readable file. A body that merely *starts* with `@` is
  refused instead of being read off disk; pipe it in with `-` to send it verbatim.
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
they will refuse. Say which guardrail you are stepping outside of when you do.

## What the wrappers do and don't protect against

They keep a mistake from becoming a side effect: the method cannot change, the
scheme stays `http`/`https`, one call is one request, and the response only ever
arrives on **stdout** — never written to disk by a flag. `_http-common` holds the
allowlist and the reasoning.

They are not a sandbox, and three things stay your responsibility:

- **Never pipe a response into an interpreter.** `get <url> | sh`,
  `bash <(get <url>)`, `python3 -c "$(get <url>)"` — the wrappers cannot see this,
  and it is the one step that turns a fetched file into running code. Save it,
  read it, then decide.
- **`@<file>` and `-` read whatever they are pointed at** and send it to a remote
  host. Never aim them at `.env`, `.pem`/`.crt`/`.p12`/`.jks`, `~/.ssh`, `~/.aws`
  or anything else covered by the secrets policy — that applies to the file you
  name *and* to what you pipe in.
- **A URL is a destination.** Ask before sending anything off the machine that you
  did not receive in this session, and treat `localhost` services as real systems
  with real state.
