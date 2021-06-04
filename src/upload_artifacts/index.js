const artifact = require('@actions/artifact');
const artifactClient = artifact.create()
const artifactName = process.env.NAME;
const files = [
    process.env.FILES
]
const rootDirectory = process.env.ROOT_DIR
const options = {
    continueOnError: true
}
console.log(artifactName)
console.log(files)
console.log(rootDirectory)
async function start() {
    const uploadResult = await artifactClient.uploadArtifact(artifactName, files, rootDirectory, options);
    console.log(uploadResult);
}
start();
