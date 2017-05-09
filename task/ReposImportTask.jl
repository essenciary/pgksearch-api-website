module ReposImportTask

using GitHub, Genie, SearchLight, App, Logger

function description()
  """
  Imports list of repos (name, URL) in database, using local package information and the GitHub pkg
  """
end

function run_task!()
  # for package in Genie.SearchLight.find(Genie.Package)
  for i in (1:SearchLight.count(Package))
    package = SearchLight.find(Package, SQLQuery(limit = 1, offset = i-1, order = SQLOrder(:id, :desc))) |> first

    try
      repo = Repos.from_package(package)
      SearchLight.update_by_or_create!!(repo, :package_id)
    catch ex
      Logger.log(string(ex), :debug)
    end
  end
end

end
