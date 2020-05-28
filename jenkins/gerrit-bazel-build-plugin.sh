#!/bin/bash -e

git checkout -fb {branch} gerrit/{branch}
git submodule update --init
rm -rf plugins/{name}
git read-tree -u --prefix=plugins/{name} origin/{branch}
git fetch --tags origin

if [ -f plugins/{name}/external_plugin_deps.bzl ]
then
  cp -f plugins/{name}/external_plugin_deps.bzl plugins/
fi

TARGETS=$(echo "{targets}" | sed -e 's/{{name}}/{name}/g')
. set-java.sh 8

java -fullversion
bazelisk version
bazelisk build --spawn_strategy=standalone --genrule_strategy=standalone $TARGETS
bazelisk test --test_env DOCKER_HOST=$DOCKER_HOST //tools/bzl:always_pass_test plugins/{name}/...

JAR="bazel-bin/plugins/{name}/{name}.jar"
PLUGIN_VERSION=$(git describe  --always origin/{branch})
echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
echo "$PLUGIN_VERSION" > bazel-bin/plugins/{name}/$(basename $JAR-version)
