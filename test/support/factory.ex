defmodule Social.Factory do
  use ExMachina.Ecto, repo: Social.Repo

  alias Social.Accounts.User
  alias Social.Timeline.Post
  alias Social.Timeline.Comment

  def post_factory do
    %Post{
      body: sequence("This is social"),
      user: build(:user),
      likes: [],
      comments: []
    }
  end

  def post_with_comments_factory do
    %Post{
      body: sequence("This is social post with comment"),
      user: build(:user),
      likes: [],
      comments: build_list(1, :comment)
    }
  end

  def comment_factory do
    %Comment{
      content: sequence("This is a comment"),
      name: sequence("name"),
    }
  end

  def user_factory(attrs) do
    default = %{
      name: "apple",
      username: sequence("apple"),
      email: sequence(:email, &"user#{&1}@example.com"),
      password: "hello world!"
    }

    user_attrs = merge_attributes(default, attrs)

    %User{}
    |> User.registration_changeset(user_attrs)
    |> Ecto.Changeset.apply_changes()
  end

  def extract_user_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.body, "[TOKEN]")
    token
  end
end
