defmodule Social.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false

  alias Social.Accounts.User
  alias Social.Repo
  alias Social.Timeline.{Like, Post, Comment}

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts(page: 1, per_page: 2)
      [%Post{}, ...]

  """
  def list_posts(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)

    from(p in Post,
      offset: ^((page - 1) * per_page),
      limit: ^per_page,
      order_by: [desc: p.id]
    )
    |> Repo.all()
    |> Repo.preload([:user, :likes, :comments])
  end

  @doc """
  Returns the list of post ids.

  ## Examples

      iex> list_post_ids(page: 1, per_page: 2)
      [1, ...]

  """
  def list_post_ids(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)

    from(p in Post,
      select: p.id,
      offset: ^((page - 1) * per_page),
      limit: ^per_page,
      order_by: [desc: p.id]
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of posts given a set of ids.

  ## Examples

      iex> get_posts([1, 2])
      [%Post{id: 1}, ...]

  """
  def get_posts(ids) do
    from(p in Post,
      where: p.id in ^ids,
      order_by: [desc: p.id]
    )
    |> Repo.all()
    |> Repo.preload([:user, :likes, :comments])
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Post |> Repo.get!(id) |> Repo.preload([:user, :likes, :comments])

  # def get_post!(id), do: Repo.get!(Post, id) |> Repo.preload(:user) |> Repo.preload(:comments) |> Repo.preload(:likes)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
    |> preload_timeline_data()
    |> broadcast(:post_created)
  end

  defp preload_timeline_data({:error, _} = error), do: error
  defp preload_timeline_data({:ok, post}), do: {:ok, Repo.preload(post, [:user, :likes, :comments])}

  @doc """
  Likes a post.

  ## Examples

      iex> like_post!(post, user)
      %Post{}

      iex> like_post!(%{id: nil}, %{id: nil})
      ** (Ecto.NoResultsError)

  """
  def like_post!(%Post{} = post, %User{} = user) do
    %Like{}
    |> Like.changeset(%{post_id: post.id, user_id: user.id})
    |> Repo.insert!()

    updated_post = get_post!(post.id)
    broadcast_post_updated(updated_post)
    updated_post
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end


  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Repo.all(Comment)
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end


  @doc """
  Subscribes process to timeline events
  """
  @timeline_topic "timeline"
  def subscribe do
    Phoenix.PubSub.subscribe(Social.PubSub, @timeline_topic)
  end

  def broadcast_post_created(post) do
    Phoenix.PubSub.broadcast(Social.PubSub, @timeline_topic, {:post_created, post})
  end

  def broadcast_post_updated(post) do
    Phoenix.PubSub.broadcast(Social.PubSub, @timeline_topic, {:post_updated, post})
  end

  defp broadcast({:error, _} = error, _), do: error

  defp broadcast({:ok, post} = ok_tuple, _event) do
    broadcast_post_created(post)
    ok_tuple
  end
end
