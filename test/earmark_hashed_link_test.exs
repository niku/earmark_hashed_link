defmodule EarmarkHashedLinkTest do
  use ExUnit.Case, async: true
  doctest EarmarkHashedLink

  describe "EarmarkHashedLink.split_hashed_link/1" do
    test "when a hashed link brings in the first of a text" do
      text = "#abc def ghi"
      expected = ["#abc", " def ghi"]
      assert expected == EarmarkHashedLink.split_hashed_link(text)
    end

    test "when a hashed link brings in the last of a text" do
      text = "abc def #ghi"
      expected = ["abc def ", "#ghi"]
      assert expected == EarmarkHashedLink.split_hashed_link(text)
    end

    test "when hashed links bring many times in a text" do
      text = "abc #def #ghi"
      expected = ["abc ", "#def", " ", "#ghi"]
      assert expected == EarmarkHashedLink.split_hashed_link(text)
    end

    test "when a hashed link brings at the first of a text" do
      text = "# abc def ghi"
      expected = ["# abc def ghi"]
      assert expected == EarmarkHashedLink.split_hashed_link(text)
    end

    test "when a hashed link brings at the last of a text" do
      text = "abc def ghi #"
      expected = ["abc def ghi #"]
      assert expected == EarmarkHashedLink.split_hashed_link(text)
    end

    test "when a hashed link brings in a multiline text" do
      text = """
      abc def #ghi
      jk #l mn
      """

      expected = ["abc def ", "#ghi", "\njk ", "#l", " mn\n"]
      assert expected == EarmarkHashedLink.split_hashed_link(text)
    end

    test "when a hashed link which includes multibyte brings in the middle of a text" do
      text = "abc #こんにちは ghi"
      expected = ["abc ", "#こんにちは", " ghi"]
      assert expected == EarmarkHashedLink.split_hashed_link(text)
    end
  end

  describe "EarmarkHashedLink.add_hashed_link/1" do
    test "adds link to a text in paragraph" do
      {:ok, expected, []} =
        Earmark.as_ast("""
        [#abc](abc) def ghi
        jkl [#mno](mno) pqr

        stu vwx [#yz](yz)
        """)

      {:ok, ast, []} =
        Earmark.as_ast("""
        #abc def ghi
        jkl #mno pqr

        stu vwx #yz
        """)

      actual = EarmarkHashedLink.add_hashed_link(ast)
      assert expected == actual
    end

    test "adds link to a text in header" do
      {:ok, expected, []} =
        Earmark.as_ast("""
        # [#abc](abc)
        ## [#def](def)
        ### [#ghi](ghi)
        #### [#jkl](jkl)
        ##### [#mno](mno)
        ###### [#pqr](pqr)
        """)

      {:ok, ast, []} =
        Earmark.as_ast("""
        # #abc
        ## #def
        ### #ghi
        #### #jkl
        ##### #mno
        ###### #pqr
        """)

      actual = EarmarkHashedLink.add_hashed_link(ast)
      assert expected == actual
    end

    test "doesn't add link to a text in blockquote" do
      {:ok, expected, []} =
        Earmark.as_ast("""
        > #abc
        """)

      {:ok, ast, []} =
        Earmark.as_ast("""
        > #abc
        """)

      actual = EarmarkHashedLink.add_hashed_link(ast)
      assert expected == actual
    end

    test "adds link to a text in list" do
      {:ok, expected, []} =
        Earmark.as_ast("""
        - [#abc](abc)
        """)

      {:ok, ast, []} =
        Earmark.as_ast("""
        - #abc
        """)

      actual = EarmarkHashedLink.add_hashed_link(ast)
      assert expected == actual
    end

    test "adds link to a text in ordered list" do
      {:ok, expected, []} =
        Earmark.as_ast("""
        1. [#abc](abc)
        """)

      {:ok, ast, []} =
        Earmark.as_ast("""
        1. #abc
        """)

      actual = EarmarkHashedLink.add_hashed_link(ast)
      assert expected == actual
    end

    test "doesn't add link to a text in code block" do
      {:ok, expected, []} =
        Earmark.as_ast("""
        `#abc`

            #def

        ```
        #ghi
        ```
        """)

      {:ok, ast, []} =
        Earmark.as_ast("""
        `#abc`

            #def

        ```
        #ghi
        ```
        """)

      actual = EarmarkHashedLink.add_hashed_link(ast)
      assert expected == actual
    end

    test "doesn't add link to a text in link" do
      {:ok, expected, []} =
        Earmark.as_ast("""
        [abc#def](abc#def)
        """)

      {:ok, ast, []} =
        Earmark.as_ast("""
        [abc#def](abc#def)
        """)

      actual = EarmarkHashedLink.add_hashed_link(ast)
      assert expected == actual
    end

    test "adds link to a text in emphasis" do
      {:ok, expected, []} =
        Earmark.as_ast("""
        *[#abc](abc)*
        _[#def](def)_
        **[#ghi](ghi)**
        __[#jkl](jkl)__
        """)

      {:ok, ast, []} =
        Earmark.as_ast("""
        *#abc*
        _#def_
        **#ghi**
        __#jkl__
        """)

      actual = EarmarkHashedLink.add_hashed_link(ast)
      assert expected == actual
    end

    test "doesn't add link to a text in image" do
      {:ok, expected, []} =
        Earmark.as_ast("""
        ![#abc](#abc.jpg)
        ![def#ghi](def#ghi.jpg)
        """)

      {:ok, ast, []} =
        Earmark.as_ast("""
        ![#abc](#abc.jpg)
        ![def#ghi](def#ghi.jpg)
        """)

      actual = EarmarkHashedLink.add_hashed_link(ast)
      assert expected == actual
    end

    test "doesn't add link to a text in comment" do
      {:ok, expected, []} =
        Earmark.as_ast("""
        <!-- #abc -->
        """)

      {:ok, ast, []} =
        Earmark.as_ast("""
        <!-- #abc -->
        """)

      actual = EarmarkHashedLink.add_hashed_link(ast)
      assert expected == actual
    end
  end
end
