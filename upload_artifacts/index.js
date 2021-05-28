const artifact = require('@actions/artifact');
const artifactClient = artifact.create()
const artifactName = 'my-artifact';
const files = [
    '/github/workflow/artifact.zip'
]
const rootDirectory = '/github/workflow/'
const options = {
    continueOnError: true
}
async function start() {
    const uploadResult = await artifactClient.uploadArtifact(artifactName, files, rootDirectory, options);
    console.log(uploadResult);
}
start();