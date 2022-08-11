import core from "@actions/core"
import github from "@actions/github"
import { Client } from "@notionhq/client"

async function searchPage(notion, commit) {
    const query = commit.message.split(" ")[0];

    const response = await notion.search({
        query: query,
        filter: {
            property: "object",
            value: "page"
        }
    });
    return response.results[0];
}

async function createComment(notion, commit) {
    let page = await searchPage(notion, commit)

    console.log("------------------------------------------");
    console.log(JSON.stringify(commit, null, 4));
    console.log("------------------------------------------");

    let template = `
    Commit 💬: ${commit.message}
    Author 🐣: ${commit.author.username}
    URL    📫: ${commit.url}
    `;

    notion.comments.create(
        {
            parent: {
                page_id: page.id
            },
            rich_text: [
                {
                    text: {
                        content: template,
                        link: { 
                            url: commit.url
                        }
                    },
                    annotations: { 
                        color: "orange"
                    }
                }
            ]
        }
    )
    .then(result => core.notice(JSON.stringify(result, null, 4)))
    .catch(error => core.setFailed(error.message));
}

(async () => {
    try {
        const notion = new Client({
            auth: core.getInput(`notion_secret`)
        });

        const commits = github.context.payload.commits;

        if (typeof commits != "undefined" && commits != null && commits.length != null && commits.length > 0) { 
            commits.forEach((commit) => {
                createComment(notion, commit);
            });
        } else { 
            createComment(notion, github.context.payload.head_commit);
        }
    } catch (error) {
        core.setFailed(error.message);
    }
})();