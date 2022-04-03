defmodule SocialWeb.ComposeLive do
  use SocialWeb, :live_view

  alias Social.Accounts
  alias Social.CloudinaryUpload
  alias Social.Timeline
  alias Social.Timeline.Post
  alias SocialWeb.SVGHelpers

  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    changeset = Timeline.change_post(%Post{})


    # CLOUD UPLOAD
    # socket =
    #   socket
    #   |> assign(changeset: changeset, current_user: current_user)
    #   |> allow_upload(:photos,
    #     accept: ~w(.jpg .jpeg .png),
    #     max_entries: 2,
    #     external: &presign_upload/2
    #   )

    socket =
      socket
      |> assign(changeset: changeset, current_user: current_user)
      |> allow_upload(:photos,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 2      )


    {:ok, socket}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    current_user = socket.assigns.current_user
    photo_urls = generate_photo_urls(socket)

    params =
      post_params
      |> Map.put("user_id", current_user.id)
      |> Map.put("photo_urls", photo_urls)

    case Timeline.create_post(params) do
      {:ok, _post} ->
        save_photos(socket)
        {:noreply, push_redirect(socket, to: Routes.timeline_path(socket, :index))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"post" => post_params}, socket) do
    current_user = socket.assigns.current_user
    params = Map.put(post_params, "user_id", current_user.id)

    changeset =
      %Post{}
      |> Timeline.change_post(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photos, ref)}
  end

  defp generate_photo_urls(socket) do
    {completed, []} = uploaded_entries(socket, :photos)

    for entry <- completed do
      Routes.static_path(socket, "/uploads/#{filename(entry)}")
    end
  end

  # CLOUD
  defp generate_photo_urlsxx(socket) do
    {completed, []} = uploaded_entries(socket, :photos)

    for entry <- completed do
      cloudinary_image_url(entry)
    end
  end

  defp cloudinary_image_url(entry) do
    folder = "testing-liveview"
    cloud_name = cloudinary_config()[:cloud_name]
    cloudinary_url = CloudinaryUpload.image_url(cloud_name)

    Path.join([cloudinary_url, folder, filename(entry)])
  end

  defp save_photos(socket) do
    consume_uploaded_entries(socket, :photos, fn %{path: path}, entry ->
      dest = Path.join(uploads_dir(), filename(entry))
      File.cp!(path, dest)
    end)
  end

  defp uploads_dir do
    Application.app_dir(:social, "priv/static/uploads")
  end

  defp filename(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    "#{entry.uuid}.#{ext}"
  end

  defp save_photosxx(socket) do
    consume_uploaded_entries(socket, :photos, fn _, _ -> :ok end)
  end

  defp presign_upload(entry, socket) do
    cloud_name = cloudinary_config()[:cloud_name]

    credentials = %{
      api_key: cloudinary_config()[:api_key],
      api_secret: cloudinary_config()[:api_secret]
    }

    fields = %{
      folder: "testing-liveview",
      public_id: filename(entry)
    }

    updated_fields = CloudinaryUpload.sign_form_upload(fields, credentials)

    meta = %{
      uploader: "Cloudinary",
      url: CloudinaryUpload.image_api_url(cloud_name),
      fields: updated_fields
    }

    {:ok, meta, socket}
  end

  defp cloudinary_config do
    Application.get_env(:social, :cloudinary)
  end

  defp filename(entry) do
    entry.uuid
  end
end
