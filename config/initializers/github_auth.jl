using GitHub, Logger

const GITHUB_AUTH = try
                      GitHub.authenticate(GITHUB_AUTH_KEY)
                    catch ex
                      Logger.log("Can't auth to GitHub", :err)
                      Logger.log(ex, :err)

                      nothing
                    end
