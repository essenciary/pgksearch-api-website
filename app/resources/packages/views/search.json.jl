el(
  data = el(
    packages = [include("package_item.json.jl") for @vars(:package) in @vars(:packages)],
  )
)
