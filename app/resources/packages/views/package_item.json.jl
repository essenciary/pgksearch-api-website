el(
  id            = @vars(:package).id |> Base.get,
  attributes    = el(
    name          = @vars(:package).name,
    url           = @vars(:package).url,
    readme        = begin
                      r = SearchLight.relation_data(@vars(:package), Repo, RELATION_HAS_ONE)
                      isnull(r) ? "" : Base.get(r).collection[1].readme
                    end,
    participation = begin
                      r = SearchLight.relation_data(@vars(:package), Repo, RELATION_HAS_ONE)
                      isnull(r) ? "" : Base.get(r).collection[1].participation
                    end
  ),
  links = [el(
    self = "/api/v1/packages/$(@vars(:package).id |> Base.get)"
  )]
)
