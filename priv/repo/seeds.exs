# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Social.Repo.insert!(%Social.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Social.{Accounts, Repo, Timeline.Post}
alias Social.Accounts.User
alias Social.Timeline.Like
alias Social.Timeline.Comment

Repo.delete_all(Like)
Repo.delete_all(Comment)
Repo.delete_all(Post)
Repo.delete_all(User)

posts = %{
  "apple" => [
    "So do all who live to see such times. But that is not for them to decide.",
    "All we have to decide is what to do with the time that is given us.",
    "do not be too eager to deal out death in judgement. For even the very wise cannot see all ends.",
    "He that breaks a thing to find out what it is has left the path of wisdom.",
    "It is not depair, for despair is only for those who see the end beyond all doubt. We do not."
  ],
  "bot" => [
    "Give me your name master horse rider. And I shall give you mine",
    "Little did I know where the chief peril lay!",
    "Torment in the dark was the danger that I feared, and it did not hold me back. But I would have never come, had I known the danger of light and joy.",
    "Hammer and tongs! I am so torn between rage and joy, that if I do not burst, it will be a marvel!"
  ],
  "coin" => [
    "Farewell! I go to find the Sun!",
    "Oft hope is born when all is forlorn.",
    "To the sea, to the sea! The white gulls are crying",
    "He stands not alone"
  ],
  "dart" => [
    "If by my life or death I can protect you, I will.",
    "A time may come soon when none will return. Then there will be need of valour without renown, for none shall remember the deeds that are done in the last defence of your homes. Yet the deeds will not be less valiant because they are unpraised.",
    "Not idly do the leaves of Lorien fall",
    "A hunted man sometimes wearies of distruct and longs for friendship."
  ],
  "elixir" => [
    "Faithless is he that says farewell when the road darkens"
  ],
  "flutter" => [
    "I wish it need not have happend in my time.",
    "I am glad you are here with me. Here at the end of all things",
    "I will take the Ring, though I do not know the way."
  ],
  "golang" => [
    "Short cuts make longs delays"
  ],
  "hyper" => [
    "You can trust us to stick with you through thick and thin--to the bitter end.",
    "And you can trust us to keep that secret of yours--closer than you keep it yourself.",
    "But you cannot trust us to let you face trouble alone, and go off without a word. We are your friends, Frodo."
  ],
  "fsharp" => [
    "It's the job that's never started as takes longest to finish.",
    "Is everything sad going to come untrue?"
  ]
}

["apple", "bot", "coin", "dart", "elixir", "flutter", "golang", "hyper", "fsharp"]
|> Enum.map(fn name ->
  username = String.downcase(name)
  email = username <> "@tekacademy.com"
  password = "secretpassword"

  params = %{name: name, username: username, email: email, password: password}

  case Accounts.register_user(params) do
    {:ok, user} -> user
    {:error, error} -> Repo.get_by!(Accounts.User, username: username)
  end
end)
|> Enum.each(fn user ->
  Enum.each(posts[user.name], fn body ->
    %Post{
      body: body, user_id: user.id,
      comments: [
        %Comment{
          content: "Sample data 1",
          name: "Sample name 1",
          user_id: user.id,
        },
        %Comment{
          content: "Sample data 2",
          name: "Sample name 2",
          user_id: user.id,
        },
      ]
    }
    |> Repo.insert!()
  end)

end)
