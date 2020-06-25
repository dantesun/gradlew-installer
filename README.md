# gradlew-installer

A lightweight way install gradlew script.

I worked on a lot of gradle-based projects with different gradle versions. A global installed
gradle distribution  not only make no sense to me but also sometimes confuses me which gradle version I ran from command
line.

In bootstrap phase, it will firstly try to use [Gradle Docker](https://hub.docker.com/_/gradle). If docker is not available,
it will download the current released version of gradle from [Gradle Official Site](https://services.gradle.org).

Then it will execute `--no-daemon --no-build-cache wrapper ${gradle_version_ref} --distribution-type all` to install
a gradlew script into your current working directory.

# Usage

For the latest:

    curl -sSL https://git.io/JfhdU | bash -s

Arbitrary version:

    curl -sSL https://git.io/JfhdU | bash -s 5.4.1

# Other Tools

Tired of keep typing './gradlew' or '../gradlew'? Try [gdub](https://www.gdub.rocks/).
