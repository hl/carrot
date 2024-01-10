defmodule CarrotWeb.ErrorJSONTest do
  use CarrotWeb.ConnCase, async: true

  test "renders 404" do
    assert CarrotWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert CarrotWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
