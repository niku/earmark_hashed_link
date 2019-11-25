# EarmarkHashedLink

It adds link to hashed text in a markdown using Earmark's [AST feature](https://github.com/pragdave/earmark#earmarkas_ast2).
It doesn't only add but also switch behavior in its context (e.g. It doesn't add link to text in a code tag).

Status: **EXPERIMENTAL**

## Installation

```elixir
def deps do
  [
    {:earmark_hashed_link, github: "niku/earmark_hashed_link"}
  ]
end
```

## Usage

```elixir
markdown = "abc #hashedLink def\n`#hashedLink2 ghi`"
{:ok, ast, []} = Earmark.as_ast(markdown)
EarmarkHashedLink.add_hashed_link(ast) |> Earmark.Transform.transform() |> IO.puts()
# <p>
#   abc
#   <a href="hashedLink">
#     #hashedLink
#   </a>
#    def
# <code class="inline">#hashedLink2 ghi</code></p>
```

## LICENSE

MIT. Check the [LICENSE](LICENSE) file for more information.
