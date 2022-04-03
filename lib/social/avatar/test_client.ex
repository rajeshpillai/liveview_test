defmodule Social.Avatar.TestClient do
  def generate(_email) do
    SocialWeb.Endpoint.static_url() <> "/test_image.png"
  end
end
