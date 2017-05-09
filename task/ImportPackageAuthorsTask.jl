module ImportPackageAuthorsTask

using Genie, SearchLight, GitHub, App, App.Packages, Logger

function description()
  """
  Task to import the packages authors for existing / already imported packages
  """
end

function run_task!()
  for pkg in SearchLight.all(Package)
    author_name = split(pkg.url, "/")[end-1] |> String
    author = SearchLight.find_one_by_or_create(Author, SQLColumn("authors.name"), author_name)

    try
      github_author = GitHub.owner(author_name, auth = App.GITHUB_AUTH)
      author.fullname = isnull(github_author.name) ? "" : Base.get(github_author.name)
      author.company = isnull(github_author.company) ? "" : Base.get(github_author.company)
      author.location = isnull(github_author.location) ? "" : Base.get(github_author.location)
      author.html_url = github_author.html_url |> Base.get |> string
      author.blog_url = (isnull(github_author.blog) ? "" : Base.get(github_author.blog)) |> string
      author.followers_count = github_author.followers |> Base.get
      SearchLight.save!!(author)
    catch ex
      Logger.log(ex |> string, :err)
    end

    pkg = Packages.author(pkg, author)
    SearchLight.save!!(pkg)
  end
end

end
