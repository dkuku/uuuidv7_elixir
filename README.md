# UUUIDv7 or uUUIDv7 or microUUIDv7 for Elixir

Used for generating version 7 UUIDs using submicrosecond precision.
Normally the default precision is 1 millisecond, this causes issues
when generating UUIDs in bulk because we can generate multiple UUIDs
in the same millisecond. This module allows you to generate UUIDs with
submicrosecond precision.

Replacing the default precision with submicrosecond precision causes less
randomness in the uuid - it's 62 bits instead of 74 with normal precision.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can
be installed by adding `uuuidv7` to your list of dependencies in
`mix.exs`:

```elixir
def deps do
  [
    {:uuuidv7, "~> 0.1.0"}
  ]
end
```
