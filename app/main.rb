# frozen_string_literal: true

require 'json'
require 'notion-client'
require 'octokit'

require_relative './utils/github_event_processor'
require_relative './utils/notion_helpers'

# 💬 Commit: 6b7589b78374464b9fca58e52adee36e
# 👀 Branch: refs/tags/1.1
# 🐣 Author: Ivan Kudinov
# 📫 URL: https://github.com/medievil-inc/notion-hook/commit/64700475ec193055ce0a3c88524b50ae53c2c337

begin
    notion_secret = ENV.fetch('NOTION_SECRET', nil)

    notion = Notion::Client.new(auth: notion_secret)

    payload = GitHubEventProcessor.load_payload

    pull_request = payload['pull_request']
    commits = payload['commits']

    puts '------------------------------------------'
    puts JSON.pretty_generate(payload)
    puts '------------------------------------------'

    if pull_request
        create_comment_by_pr(notion, payload, pull_request)
    elsif commits.length.positive?
        commits.each { |commit| create_comment_by_commit(notion, payload, commit) }
    else
        create_comment_by_commit(notion, payload, payload['head_commit'])
    end
rescue StandardError => e
    puts e.message
    exit 1
end

private

async def create_comment_by_commit(notion, payload, commit)
    page = NotionHelpers.search_page(notion, commit)

    return if page.nil? || page == 'undefined'

    notion.comments.create(
        {
            parent: {
                page_id: page.id
            },
            rich_text: [
                create_comment_title(content: '💬 Commit: '),
                create_comment_description(content: "#{commit.message.gsub(/(\r\n|\n|\r)/, ' ')}\n"),
                create_comment_title(content: '👀 Branch: '),
                create_comment_description(
                    content: "#{payload.ref}\n",
                    color: 'purple'
                ),
                create_comment_title(content: '🐣 Author: '),
                create_comment_description(
                    content: "#{commit.author.name}\n",
                    color: 'yellow',
                    code: true
                ),
                create_comment_title(content: '📫 URL: '),
                create_comment_description(
                    content: commit.url.to_s,
                    color: 'blue',
                    url: commit.url
                )
            ]
        }
    )
    .then(result => core.notice(JSON.stringify(result, null, 4)))
    .catch(error => core.set_failed(error.message))
end

def create_comment_by_pr(notion, payload, pull_request)
    # your code here
end

def create_comment_title(content, color: 'gray')
    {
        text: {
            content:
        },
        annotations: {
            color:
        }
    }
end

def create_comment_description(content, color, code: false, url: nil)
    {
        text: {
            content:,
            link: {
                url:
            }
        },
        annotations: {
            code:,
            color:
        }
    }
end
