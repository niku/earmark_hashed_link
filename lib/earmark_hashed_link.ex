defmodule EarmarkHashedLink do
  @moduledoc """
  Documentation for EarmarkHashedLink.
  """

  @doc """
  Splits hashed link from given text

  ## Examples

      iex> EarmarkHashedLink.split_hashed_link("abc #def ghi")
      ["abc ", "#def", " ghi"]

  """
  @spec split_hashed_link(binary) :: [binary]
  def split_hashed_link(text) when is_binary(text) do
    Regex.split(~r/#[[:word:]]+/u, text, trim: true, include_captures: true)
  end

  @doc """
  Adds hashed link to given ast
  """
  @spec add_hashed_link([binary | {any, any, [any]}]) :: [any]
  def add_hashed_link(ast) when is_list(ast) do
    do_add_hashed_link(ast, [], [])
  end

  @doc false
  def do_add_hashed_link(_ast, _ancestor_tags, _result)

  def do_add_hashed_link([], _ancestor_tags, result), do: Enum.reverse(result)

  def do_add_hashed_link([{tag, atts, ast} | rest], ancestor_tags, result) do
    do_add_hashed_link(rest, [tag | ancestor_tags], [
      {tag, atts, do_add_hashed_link(ast, [tag | ancestor_tags], [])} | result
    ])
  end

  def do_add_hashed_link([string | rest], ancestor_tags, result) when is_binary(string) do
    if Enum.any?(
         ancestor_tags,
         &Enum.member?([:comment, "a", "blockquote", "code", "img", "pre"], &1)
       ) do
      do_add_hashed_link(rest, ancestor_tags, [string | result])
    else
      new_ast =
        split_hashed_link(string)
        |> Enum.map(fn
          "#" <> hashed_link ->
            # Link representation
            {"a", [{"href", hashed_link}], ["#" <> hashed_link]}

          text ->
            text
        end)
        |> Enum.reverse()

      do_add_hashed_link(rest, ancestor_tags, new_ast ++ result)
    end
  end
end
