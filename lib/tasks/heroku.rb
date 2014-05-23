task :heroku do
  tarball_name = "g5-theme-garden.tar"
  project_path = File.expand_path("../../../", __FILE__)
  tarball_path = File.join(project_path, tarball_name)
  bucket_name = "g5-theme-garden-tarballs"

  # 1. tarball repo
  `tar -cvf #{tarball_path} #{project_path}`

  # 2. upload tarball to s3
  s3 = AWS::S3.new(
    :access_key_id => ENV["AWS_S3_ACCESS_KEY_ID"],
    :secret_access_key => ENV["AWS_S3_SECRET_ACCESS_KEY"])

  s3_bucket ||= if s3.buckets[bucket_name].exists?
    s3.buckets[bucket_name]
  else
    s3.buckets.create(bucket_name)
  end

  obj = s3_bucket.objects[tarball_name]
  obj.write(tarball_path)

  # 3. heroku build tarball -> slug
  app_id_or_name = "g5-theme-garden"
  tarball_url = obj.url
  # `curl -n -X POST https://api.heroku.com/apps/#{app_id_or_name}/builds \\
  #   -H "Accept: application/vnd.heroku+json; version=3" \\
  #   -H "Content-Type: application/json" \\
  #   -d '{"source_blob":{"url":"#{tarball_url}?token=#{s3_token}","version":"v1.3.0"}}'`
  #
  # -n, --netrc         Must read .netrc for user name and password
  # -X, --request COMMAND  Specify request command to use
  # -H, --header LINE   Custom header to pass to server (H)
  # -d, --data DATA     HTTP POST data (H)
  response = HTTParty.post(
    "https://api.heroku.com/apps/#{app_id_or_name}/builds",
    basic_auth: { username: ENV["HEROKU_USERNAME"], ENV["HEROKU_API_TOKEN"] }
    headers: {
      "Accept" => "application/vnd.heroku+json; version=3",
      "Content-Type" => "application/json"
    },
    body: {
      "source_blob" => {
        "url" => "#{tarball_url}?token=#{s3_token}",
        "version" => "v1.3.0"
      }
    }
  )

  # 4. heroku release slug
  slug_id = "get-from-previous-api-call"
  # `curl -n -X POST https://api.heroku.com/apps/#{app_id_or_name}/releases \\
  #   -H "Accept: application/vnd.heroku+json; version=3" \\
  #   -H "Content-Type: application/json" \\
  #   -d '{"description":"Another release","slug":"#{slug_id}"}'`
  response = HTTParty.post(
    "https://api.heroku.com/apps/#{app_id_or_name}/builds",
    basic_auth: { username: ENV["HEROKU_USERNAME"], ENV["HEROKU_API_TOKEN"] }
    headers: {
      "Accept" => "application/vnd.heroku+json; version=3",
      "Content-Type" => "application/json"
    },
    body: {
      "description" => "Another release",
      "slug" => slug_id
    }
  )
end
