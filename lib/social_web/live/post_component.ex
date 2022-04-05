defmodule SocialWeb.PostComponent do
  use SocialWeb, :live_component

  alias Social.Timeline
  alias SocialWeb.DateHelpers
  alias SocialWeb.SVGHelpers

  def preload(list_of_assigns) do
    list_of_ids = Enum.map(list_of_assigns, & &1.id)
    posts = Timeline.get_posts(list_of_ids)

    Enum.map(list_of_assigns, fn assigns ->
      Map.put(assigns, :post, Enum.find(posts, fn post -> post.id == assigns.id end))
    end)
  end

  def render(assigns) do
    ~L"""
    <div id="post-<%= @post.id %>" class="post">
      <img class="avatar" src="<%= @post.user.avatar_url %>">
      <div class="post-content">
        <div class="post-header">
          <div class="post-user-info">
            <span class="post-user-name">
              <%= @post.user.name %>
            </span>
            <span class="post-user-username">
              @<%= @post.user.username %>
            </span>
          </div>

          <div class="post-date-info">
            <span class="post-date-separator">.</span>
            <span class="post-date">
              <%= DateHelpers.format_short(@post.inserted_at) %>
            </span>
          </div>
        </div>

        <div class="post-body">
          <%= live_patch to: Routes.timeline_path(@socket, :index, post_id: @post.id), data: [role: "show-post"] do %>
            <%= @post.body %>
          <% end %>

          <div class="post-images">
            <%= for photo_url <- @post.photo_urls do %>
              <img class="post-image" data-role="post-image" src="<%= photo_url %>">
            <% end %>
          </div>
        </div>

        <div class="post-actions">
          <a class="post-action">
            <%= SVGHelpers.reply_svg() %>
            <span class="post-action-count" data-role="comment-count"><%= length(@post.comments) %></span>

          </a>
          <a class="post-action">
            <%= SVGHelpers.repost_svg() %>
            <span class="post-action-count"><%= @post.reposts_count %></span>
          </a>
          <%= if current_user_liked?(@post, @current_user) do %>
            <a class="post-action post-liked" href="#" data-role="post-liked">
              <%= SVGHelpers.liked_svg() %>
              <span class="post-action-count" data-role="like-count"><%= @post.likes_count %></span>
            </a>
          <% else %>
            <a class="post-action" phx-click="like" phx-target="<%= @myself %>" data-role="like-button">
              <%= SVGHelpers.like_svg() %>
              <span class="post-action-count" data-role="like-count"><%= @post.likes_count %></span>
            </a>
          <% end %>
          <a class="post-action">
            <%= SVGHelpers.export_svg() %>
          </a>
        </div>
      </div>
    </div>
    """
  end

  def current_user_liked?(post, user) do
    user.id in Enum.map(post.likes, & &1.user_id)
  end

  def handle_event("like", _, socket) do
    current_user = socket.assigns.current_user
    post = socket.assigns.post
    updated_post = Timeline.like_post!(post, current_user)

    {:noreply, assign(socket, :post, updated_post)}
  end
end
