const publishCmd = `
echo 'Creating shadowJar and protelisdoc...'
./gradlew protelisdoc shadowJar --parallel || ./gradlew shadowJar --parallel || exit 2
echo '...assemblage done.'
echo 'Releasing on Maven Central...'
./gradlew uploadAll release --parallel
`
import config from 'semantic-release-preconfigured-conventional-commits' with { type: "json" };
config.plugins.push(
    ["@semantic-release/exec", {
        "publishCmd": publishCmd,
    }],
    ["@semantic-release/github", {
        "assets": [
            { "path": "protelis.parser.ide/build/libs/*-all.jar" },
            { "path": "protelis.parser.web/build/libs/*.war" },
        ]
    }],
    "@semantic-release/git",
)
export default config
