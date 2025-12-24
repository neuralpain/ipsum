#!/bin/sh

# NOTE: This requires a VERSION file
# OR you can write the version as x.x.x
version=$(<VERSION)

username="neuralpain"
package_name="ipsum"
repository=$package_name
packages_fork_name="typst-packages"

ssh="git@github.com:"
http="https://github.com/"
upstream="${http}typst/packages"
packages_fork_address="${http}$username/$packages_fork_name"

echo "======== Creating partial clone ========" # latest commit for your package

cd ..
rm -rf typst-packages
git clone --depth 1 --no-checkout --filter="tree:0" $packages_fork_address
cd typst-packages
git sparse-checkout init
git sparse-checkout set packages/preview/$package_name
git remote add upstream $upstream
git config remote.upstream.partialclonefilter tree:0
git checkout main
cd ..

echo "======== Updating with latest commit ========"

cd typst-packages
git log -n 1
git fetch upstream --depth=1
git reset --hard upstream/main
git log -n 1
cd ..

echo "======== Creating directories ========"

mkdir -v typst-packages/packages/preview/$package_name/$version
mkdir -v typst-packages/packages/preview/$package_name/$version/examples
mkdir -v typst-packages/packages/preview/$package_name/$version/src

echo "======== Copying new files ========"

cp -rv $repository/examples typst-packages/packages/preview/$package_name/$version
cp -rv $repository/src typst-packages/packages/preview/$package_name/$version
cp -v $repository/lib.typ typst-packages/packages/preview/$package_name/$version
cp -v $repository/LICENSE typst-packages/packages/preview/$package_name/$version
cp -v $repository/README.md typst-packages/packages/preview/$package_name/$version
cp -v $repository/typst.toml typst-packages/packages/preview/$package_name/$version

echo "======== Committing changes on new branch ========"

new_branch=$package_name-$version
commit_message=$package_name:$version
cd typst-packages
git branch $new_branch
git switch $new_branch
git add .
git commit -m "$commit_message"
git log -n 1

echo "======== Pushing new branch ========"

# NOTE: This is a test. Remove `--dry-run` to actually push your code upstream.
git push --dry-run origin $new_branch
cd ..

echo "======== Done ========"
echo
echo "Go to <$packages_fork_address/tree/$new_branch> to review and create a pull request."

# Return to local package directory
cd $repository
