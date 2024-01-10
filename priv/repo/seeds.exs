article_collection =
  Carrot.Repo.insert!(%Carrot.Collection{
    name: "Articles",
    description: "A collection of blog articles",
    template: "<h1><%= @title %></h1>",
    fields: [
      %{name: "Title", type: :text, required: true},
      %{name: "Content", type: :markdown, required: false}
    ]
  })

for i <- 1..100 do
  Carrot.Repo.insert!(%Carrot.Page{
    collection_id: article_collection.id,
    path: "test-article-#{i}",
    template: article_collection.template,
    fields: [
      %{name: "Title", type: :text, required: true, value: "Hello, World!"},
      %{name: "Content", type: :markdown, required: false, value: "## Goodbye, Moon!"}
    ]
  })
end
