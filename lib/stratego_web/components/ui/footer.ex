defmodule ConsWeb.Components.Ui.Footer do
  use Phoenix.Component

  def footer(assigns) do
    ~H"""
    <div class="py-2 flex flex-col flex-1 items-center text-sm bg-gray-100">
      <div>
        <p>Built by <a href="https://michaelconsidine.com">Mike Considine</a></p>
      </div>
      <div>
        <p>
          Inspired by
          <a href="https://stratego.io" class="text-blue-500 underline">
            Ben Letchford's stratego.io
          </a>
        </p>
      </div>
      <div>
        <p>
          SVGs from
          <a href="http://vector.gissen.nl/stratego.html" class="text-blue-500 underline">
            vector.gissen.nl
          </a>
        </p>
      </div>
    </div>
    """
  end
end
