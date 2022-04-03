defmodule Social.Timeline.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :content, :string
    field :name, :string

    belongs_to :post, Social.Timeline.Post
    belongs_to :user, Social.Accounts.User


    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:name, :content, :user_id, :post_id])
    |> validate_required([:name, :content])
  end
end
