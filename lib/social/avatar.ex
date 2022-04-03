defmodule Social.Avatar do
  def generate(email) when is_binary(email) do
    avatar_client().generate(email)
  end

  defp avatar_client do
    Application.get_env(:social, :avatar_client)
  end
end
