defmodule StrategoWeb.Services.UtilsService do
  @moduledoc """
  Service to help with utilities such as parsing, conversions, etc.
  """

  def parse_coordinates_string(coords) do
    with true <- String.contains?(coords, ","),
         coordinates <- String.split(coords, ","),
         2 <- length(coordinates),
         {x, ""} <- Integer.parse(coordinates |> List.first()),
         {y, ""} <- Integer.parse(coordinates |> List.last()) do
      {:ok, {x, y}}
    else
      _ -> {:error}
    end
  end
end
