defmodule Images do
  def get_image() do
    Req.get!(
      "https://www.googleapis.com/customsearch/v1?key=AIzaSyBbYjizRwa1zjw7_ICTTP8gulnxK-BVWDA&cx=87fe0fec44b5f4faf&q=IIIT+Jabalpur+campus&searchType=image&num=7&gl=in"
    ).body["items"]
    |> Enum.map(fn x -> x["link"] end)
    # |> Jason.encode!()
    |> dbg()
  end
end
