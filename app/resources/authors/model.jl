export Author

type Author <: AbstractModel
  _table_name::String
  _id::String

  id::Nullable{SearchLight.DbId}
  name::String
  fullname::String
  company::String
  location::String
  html_url::String
  blog_url::String
  followers_count::Int

  has_many::Vector{SearchLight.SQLRelation}

  Author(;
    id = Nullable{SearchLight.DbId}(),
    name = "",
    fullname = "",
    company = "",
    location = "",
    html_url = "",
    blog_url = "",
    followers_count = 0,

    has_many = [
                  SearchLight.SQLRelation(Package, eagerness = RELATION_EAGERNESS_AUTO),
                  SearchLight.SQLRelation(Repo, join = SQLJoin(Repo, SQLOn("packages.id", "repos.package_id"), join_type = "LEFT" ), eagerness = RELATION_EAGERNESS_AUTO)
                ],

  ) = new("authors", "id", id, name, fullname, company, location, html_url, blog_url, followers_count, has_many)
end

module Authors
end
