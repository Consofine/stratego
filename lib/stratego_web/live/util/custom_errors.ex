defmodule StrategoWeb.CustomErrors do
  defmodule GameStartedError do
    defexception message: "This game has already started- it's too late to join"
  end
end
