using Router

# API
route("/api/v1/packages", "packages#PackagesController.API.V1.index", named = :api_packages)
route("/api/v1/packages/search", "packages#PackagesController.API.V1.search", named = :api_packages_search)
route("/api/v1/packages/:package_id", "packages#PackagesController.API.V1.show", named = :api_package)

# web app
route("/", "packages#PackagesController.Website.index", named = :root)
route("/packages", "packages#PackagesController.Website.index", named = :packages)
route("/packages/search", "packages#PackagesController.Website.search", named = :packages_search)
route("/packages/:package_id", "packages#PackagesController.Website.show", named = :package)
