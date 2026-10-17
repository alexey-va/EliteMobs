#!/usr/bin/env bash
set -euo pipefail

# This release is stock 10.9.8 plus a source patch. The older persistence fork
# in the repository root is a separate baseline and is never used by this build.
repo=$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel)
upstream=af46989ba2ec64609f39901dc5071bdd9d4a04c7
patch_file="$repo/patches/passive-classes-10.9.8.patch"
patch_sha=$(shasum -a 256 "$patch_file" | awk '{print $1}')
output="$repo/build/passive-classes/$patch_sha"

if ! git -C "$repo" cat-file -e "$upstream^{commit}" 2>/dev/null; then
    git -C "$repo" fetch --no-tags https://github.com/MagmaGuy/EliteMobs.git "$upstream"
fi

source_dir=$(mktemp -d "${TMPDIR:-/tmp}/elitemobs-passive-classes.XXXXXX")
git -C "$repo" archive "$upstream" | tar -x -C "$source_dir"
(
    cd "$source_dir"
    git apply --check "$patch_file"
    git apply "$patch_file"
)
mkdir -p "$output"
printf 'release_commit=%s\nupstream=%s\npatch_sha256=%s\nsource=%s\n' \
    "$(git -C "$repo" rev-parse HEAD)" "$upstream" "$patch_sha" "$source_dir" > "$output/source.properties"
printf 'Source: %s\nUpstream: %s\nPatch SHA-256: %s\n' "$source_dir" "$upstream" "$patch_sha"

if [[ $# -eq 0 ]]; then
    set -- shadowJar -x test
fi
(
    cd "$source_dir"
    "${JAVA_HOME:+$JAVA_HOME/bin/}java" -classpath gradle/wrapper/gradle-wrapper.jar \
        org.gradle.wrapper.GradleWrapperMain --console=plain "$@"
)

candidate="$source_dir/build/libs/EliteMobs.jar"
if [[ -f "$candidate" ]]; then
    cp "$candidate" "$output/EliteMobs-10.9.8-ruscrafting.1.jar"
    shasum -a 256 "$output/EliteMobs-10.9.8-ruscrafting.1.jar" > "$output/SHA256SUMS"
    printf 'Candidate: %s\n' "$output/EliteMobs-10.9.8-ruscrafting.1.jar"
fi
