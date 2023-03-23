# frozen_string_literal: true

require 'json'
require 'notion-ruby-client'
require 'octokit'

require_relative './utils/github_event_processor'
require_relative './utils/notion_helpers'

# 💬 Commit: 6b7589b78374464b9fca58e52adee36e
# 👀 Branch: refs/tags/1.1
# 🐣 Author: Ivan Kudinov
# 📫 URL: https://github.com/medievil-inc/notion-hook/commit/64700475ec193055ce0a3c88524b50ae53c2c337

notion_secret = ENV.fetch('NOTION_SECRET', nil)

notion = Notion::Client.new(token: notion_secret)

payload = GitHubEventProcessor.load_payload

pull_request = payload['pull_request']
commits = payload['commits']

puts '------------------------------------------'
puts JSON.pretty_generate(payload)
puts '------------------------------------------'

if pull_request
    NotionHelpers.create_comment_by_pr(notion, payload, pull_request)
elsif commits.length > 1
    commits.each { |commit| NotionHelpers.create_comment_by_commit(notion, payload, commit) }
else
    NotionHelpers.create_comment_by_commit(notion, payload, payload['head_commit'])
end
