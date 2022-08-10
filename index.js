import core from "@actions/core"
import github from "@actions/github"
import { Client } from "@notionhq/client"

async function createComment(notion, commits) {
    commits.forEach((commit) => {

        const task = commit.message.substring(commit.message.indexOf("atnt:") + 6);

        // search for a page in the Notion database "Tasks" given the task name
        const page = notion.search({
            query: task,
            filter: { 
                value: "page"
            }
        })[0];

        notion.comments.create({
            parent: {
                page_id: page.page_id
            },
            rich_text: [
                {
                    [core.getInput("commit_url")]: {
                        text: {
                            content: commit.url
                        }
                    }
                }
            ]
        })
        .then(response => response.text())
        .then(result => core.info(result))
        .catch(error => core.setFailed(error.message));
    });
}

(async () => {
    try {
        const payload = JSON.stringify(github.context.payload, undefined, 2)
        console.log(`The event payload: ${payload}`);

        const notion = new Client({
            auth: core.getInput(`notion_secret`)
        });
        createComment(notion, github.context.payload.commits);

        const page = notion.search({
            query: task,
            filter: { 
                value: "page"
            }
        })
    } catch (error) {
        core.setFailed(error.message);
    }
})();
