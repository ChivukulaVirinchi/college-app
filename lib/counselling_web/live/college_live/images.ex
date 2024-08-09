defmodule Images do
  def get_image() do
    {:ok, document} =
      Req.get!(
        "https://www.bing.com/images/search?sp=-1&lq=0&pq=%22indian+institute+of+technology+bombay%22+campus+images&sc=0-53&cvid=12827CBE38564DCF97098A67769B7D06&ghsh=0&ghacc=0&q=%22Indian+Institute+of+Technology+Bombay%22+campus+images&qft=+filterui:imagesize-custom_800_500&form=IRFLTR&first=1"
      ).body
      |> Floki.parse_document()

    document
    |> Floki.find("ul")
    |> Floki.find(".dgControl_list")
    |> Floki.find("li")
    |> Floki.find("a")
    |> Enum.take(4)
    |> dbg()
  end
end
