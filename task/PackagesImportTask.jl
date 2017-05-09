module PackagesImportTask

using MetadataTools, Genie, SearchLight, App, App.Packages, Logger, GitHub

function description()
  """
  Imports list of packages (name, URL) in database, using MetadataTools
  """
end

function run_task!()
  for pkg in MetadataTools.get_all_pkg()
    author = package_author(pkg)

    package = Package(name = pkg[2].name, url = pkg[2].url, official = true)
    package = Packages.author(package, author)
    try
      SearchLight.update_by_or_create!!(package, :url)
    catch ex
      Logger.log(ex |> string, :error)
    end
  end
end

function package_author(pkg::Pair{String,MetadataTools.PkgMeta})
  author_name = split(pkg[2].url, "/")[end-1] |> String
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

  author
end

end
