module PackagesController

using App, Genie, SearchLight
@dependencies

function index()
  results_count = SearchLight.count(Package)
  packages = SearchLight.find(Package, SQLQuery(limit = @params(:page_size), offset = (@params(:page_number) - 1) * @params(:page_size), order = SQLOrder(:id, :desc) ))

  results_count, packages
end

function search()
  query = try
            String(@params(:q))
          catch
            ""
          end
  results_count = Repos.count_search_results(query)
  search_results_df = Repos.search(query, limit = SQLLimit(@params(:page_size)), offset = (@params(:page_number) - 1) * @params(:page_size))

  search_results = Dict{Int,Any}([d[:package_id] => d for d in SearchLight.dataframe_to_dict(search_results_df)])
  packages =  ! isempty(search_results) ?
              SearchLight.find(Package, SQLQuery(where = [SQLWhere(Symbol("packages.id"), SQLInput(join( map(x -> string(x), search_results_df[:package_id]), ","), raw = true), "AND", "IN" )])) :
              []

  if ! isempty(packages)
    sort!(packages, by = (p) -> search_results[p.id |> Util.expand_nullable |> Base.get][:rank], rev = true)
  end

  packages, search_results, results_count
end

# Website

module Website

using App, SearchLight, Genie, App.Packages
@dependencies

SearchLight.relation_eagerness(RELATION_EAGERNESS_EAGER)

function index()
  packages_count = SearchLight.count(Package)

  top_packages = SearchLight.find(Package, SQLQuery(where = [SQLWhere("repos.stargazers_count", "NOT NULL", "IS")], limit = 15, order = SQLOrder("repos.stargazers_count", :desc)))
  new_packages = SearchLight.find(Package, SQLQuery(where = [SQLWhere("repos.github_created_at", "NOT NULL", "IS")], limit = 15, order = SQLOrder("repos.github_created_at", :desc)))
  updated_packages = SearchLight.find(Package, SQLQuery(where = [SQLWhere("repos.github_pushed_at", "NOT NULL", "IS")], limit = 15, order = SQLOrder("repos.github_pushed_at", :desc)))

  respond_with_html(:packages, :index,
                    top_packages_data = Packages.prepare_data(top_packages),
                    new_packages_data = Packages.prepare_data(new_packages),
                    updated_packages_data = Packages.prepare_data(updated_packages),
                    packages_count = packages_count
      )
end

function search()
  @params(:page_size) = 50
  packages, search_results, results_count = PackagesController.search()
  respond_with_html(:packages, :search, search_term = @params(:q), packages = Packages.prepare_data(packages; search_results = search_results))
end

function show()
  packages = SearchLight.find_by(Package, "packages.id", @params(:package_id))
  respond_with_html(:packages, :show, packages = Packages.prepare_data(packages; details = true), package_name = packages[1].name)
end

end

# API

module API
module V1
using App, App.PackagesController, JSON
@dependencies

function index()
  results_count, packages = App.PackagesController.index()
  respond_with_json(:packages, :index, packages = packages, current_page = @params(:page_number), page_size = 20, total_items = results_count)
end

function show()
  package = SearchLight.find_one(Package, @params(:package_id))
  if ! isnull(package)
    package = Base.get(package)
    respond_with_json(:packages, :show, package = package)
  else
    respond(Dict(:json => JSON.json(Dict(:error => "404"))))
  end
end

function search()
  packages, search_results, results_count = PackagesController.search()

  respond_with_json(:packages, :search, packages = packages, search_results = search_results,
                                        current_page = @params(:page_number), page_size = @params(:page_size), total_items = results_count)
end

end
end

end
