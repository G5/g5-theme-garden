namespace :heroku do
  desc "deploy to heroku"
  task deploy: :environment do
    tarball_name = "#{SecureRandom.hex}.tar"
    project_path = File.expand_path("../../../", __FILE__)
    tarball_path = File.join(project_path, tarball_name)

    # 1. tarball repo

    `tar -cvf #{tarball_path} #{project_path}`

    # 2. upload tarball to s3

    s3 = AWS::S3.new(
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      region: ENV["AWS_REGION"])

    bucket_name = ENV["AWS_S3_BUCKET_NAME"]

    s3_bucket ||= if s3.buckets[bucket_name].exists?
      s3.buckets[bucket_name]
    else
      s3.buckets.create(bucket_name)
    end

    obj = s3_bucket.objects[tarball_name]
    obj.write(File.open(tarball_path).read, acl: :public_read)
    tarball_url = obj.public_url

    # 3. heroku build tarball -> slug

    create_build_response = HTTParty.post(
      "https://api.heroku.com/apps/#{ENV["HEROKU_APP_NAME"]}/builds",
      basic_auth: {
        username: ENV["HEROKU_USERNAME"],
        password: ENV["HEROKU_API_KEY"]
      },
      headers: {
        "Accept" => "application/vnd.heroku+json; version=3",
        "Content-Type" => "application/json"
      },
      body: {
        "source_blob" => {
          "url" => "#{tarball_url}",
          "version" => "v1.3.0"
        }
      }.to_json
    )

    pp create_build_response

    build_id = create_build_response["id"]

    get_build_response = nil

    until get_build_response && get_build_response["status"] != "pending"
      sleep 1
      get_build_response = HTTParty.get(
        "https://api.heroku.com/apps/#{ENV["HEROKU_APP_NAME"]}/builds/#{build_id}",
        basic_auth: {
          username: ENV["HEROKU_USERNAME"],
          password: ENV["HEROKU_API_KEY"]
        },
        headers: {
          "Accept" => "application/vnd.heroku+json; version=3",
          "Content-Type" => "application/json"
        },
        body: {
          "source_blob" => {
            "url" => "#{tarball_url}",
            "version" => "v1.3.0"
          }
        }.to_json
      )
      pp get_build_response
    end

    slug_id = get_build_response["slug"]["id"]

    # 4. heroku release slug

    release_response = HTTParty.post(
      "https://api.heroku.com/apps/#{ENV["HEROKU_APP_NAME"]}/releases",
      basic_auth: {
        username: ENV["HEROKU_USERNAME"],
        password: ENV["HEROKU_API_KEY"]
      },
      headers: {
        "Accept" => "application/vnd.heroku+json; version=3",
        "Content-Type" => "application/json"
      },
      body: {
        "description" => "Another release",
        "slug" => slug_id
      }.to_json
    )

    # 5. delete tarball from s3

    obj.delete
  end
end
