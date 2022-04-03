defmodule Social.Social.TimelineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Social.Social.Timeline` context.
  """

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        content: "some content",
        name: "some name"
      })
      |> Social.Social.Timeline.create_comment()

    comment
  end
end
