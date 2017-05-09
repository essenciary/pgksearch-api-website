el(
  data = el(
    packages = [include("package_item.json.jl") for @vars(:package) in @vars(:packages)],
    links = json_pagination("/api/v1/packages", @vars(:total_items), current_page = @vars(:current_page), page_size = @vars(:page_size))
  )
)
