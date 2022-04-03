defmodule SocialWeb.PostComponentTest do
  use SocialWeb.ConnCase

  import Phoenix.LiveViewTest
  import Social.Factory

  alias Social.Timeline.Like
  alias SocialWeb.PostComponent
  alias SocialWeb.DateHelpers

  test "renders post body and date" do
    post = insert(:post)

    html = render_component(PostComponent, id: post.id, post: post, current_user: insert(:user))

    assert html =~ post.body
    assert html =~ DateHelpers.format_short(post.inserted_at)
  end

  test "renders author's name, username, and avatar" do
    user = insert(:user)
    post = insert(:post, user: user)

    html = render_component(PostComponent, id: post.id, post: post, current_user: insert(:user))

    assert html =~ user.name
    assert html =~ "@#{user.username}"
    assert html =~ user.avatar_url
  end

  test "renders like button and like count" do
    post = insert(:post, likes_count: 876)

    html = render_component(PostComponent, id: post.id, post: post, current_user: insert(:user))

    assert html =~ data_role("like-button")
    assert html =~ data_role("like-count")
    assert html =~ "876"
  end

  test "renders liked button when current user likes post" do
    current_user = insert(:user)
    post = insert(:post, likes: [%Like{user_id: current_user.id}])

    html = render_component(PostComponent, id: post.id, post: post, current_user: current_user)

    assert html =~ data_role("post-liked")
    refute html =~ data_role("like-button")
  end

  test "user can like a post", %{conn: conn} do
    post = insert(:post, likes_count: 0)
    user = insert(:user)
    {:ok, view, _html} = conn |> log_in_user(user) |> live("/")

    view
    |> element("#post-#{post.id} [data-role=like-button]")
    |> render_click()

    assert has_element?(view, "#post-#{post.id} [data-role=like-count]", "1")
  end

  test "renders post's images when present" do
    gimli_url = "/images/gimli.png"
    legolas_url = "/images/legolas.png"
    post = insert(:post, photo_urls: [gimli_url, legolas_url])

    html = render_component(PostComponent, id: post.id, post: post, current_user: insert(:user))

    assert html =~ gimli_url
    assert html =~ legolas_url
  end

  defp data_role(role), do: "data-role=\"#{role}\""
end
