var publishCmd = `
./gradlew injectVersion -PnewVersion="\${nextRelease.version}" || exit 2
mvn clean
mvn deploy nexus-staging:release -Dmaven.test.skip=true || exit 3
mkdir -p .mvn
echo '--illegal-access=permit' > .mvn/jvm.config
git commit -a -m 'chore: update version to \${nextRelease.version}'
git push
git tag -a -f \${nextRelease.version} \${nextRelease.version} -F CHANGELOG.md
git push --force origin \${nextRelease.version} || exit 1
mv update-site/.git protelis.parser.repository/target/.git
git -C protelis.parser.repository/target/ add . || exit 4
git -C protelis.parser.repository/target/ commit -m "chore: update update site to version \${nextRelease.version}" || exit 5
git -C protelis.parser.repository/target/ tag -a "\${nextRelease.version}" -m "\${nextRelease.version}" || exit 6
git -C protelis.parser.repository/target/ push --follow-tags || exit 7
`
var config = require('semantic-release-preconfigured-conventional-commits');
config.plugins.push(
    ["@semantic-release/exec", {
        "publishCmd": publishCmd,
    }],
    ["@semantic-release/github", {
        "assets": [
            { "path": "build/shadow/*-all.jar" },
        ]
    }],
    "@semantic-release/git",
)
module.exports = config
