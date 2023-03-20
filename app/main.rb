# frozen_string_literal: true

require 'octokit'

# 💬 Commit: 6b7589b78374464b9fca58e52adee36e
# 👀 Branch: refs/tags/1.1
# 🐣 Author: Ivan Kudinov
# 📫 URL: https://github.com/medievil-inc/notion-hook/commit/64700475ec193055ce0a3c88524b50ae53c2c337

github_token = ENV.fetch['PERSONAL_ACCESS_TOKEN', nil]

client = Octokit::Client.new(access_token: github_token)

user = client.user
user.login
