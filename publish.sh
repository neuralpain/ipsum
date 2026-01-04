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

# This will clone the latest commit for your package, if it exists.
echo "======== Creating partial clone ========"

cd ..
rm -rf $packages_fork_name
git clone --depth 1 --no-checkout --filter="tree:0" $packages_fork_address
cd $packages_fork_name
git sparse-checkout init
git sparse-checkout set packages/preview/$package_name
git remote add upstream $upstream
git config remote.upstream.partialclonefilter tree:0
git checkout main
# cd ..

echo "======== Updating with latest commit ========"

# cd $packages_fork_name
git log -n 1
git fetch upstream --depth=1
git reset --hard upstream/main
git log -n 1
cd ..

echo "======== Creating directories ========"

# If this is a brand new package, the directory will need to be created
# manually as it does not yet exist on the typst/packages Github repository.
if [ ! -d "$packages_fork_name/packages/preview/$package_name" ]; then
  mkdir -v "$packages_fork_name/packages"
  mkdir -v "$packages_fork_name/packages/preview"
  mkdir -v "$packages_fork_name/packages/preview/$package_name"
fi
# Create new version directories. Empty folders will not be committed to git.
mkdir -v "$packages_fork_name/packages/preview/$package_name/$version"
mkdir -v "$packages_fork_name/packages/preview/$package_name/$version/examples"
mkdir -v "$packages_fork_name/packages/preview/$package_name/$version/src"

# ---
# Destination directory
dest="$packages_fork_name/packages/preview/$package_name/$version"

echo "======== Copying new files ========"

cp -rv "$repository/examples" $dest
cp -rv "$repository/src" $dest
cp -v "$repository/lib.typ" $dest
cp -v "$repository/LICENSE" $dest
cp -v "$repository/README.md" $dest
cp -v "$repository/typst.toml" $dest

echo "======== Removing PDFs ========"

find $dest -name "*.pdf" -type f -delete -print

echo "======== Removing Temporary Files ========"

find $dest -name "*.bak" -type f -delete -print
find $dest -name "*.tmp" -type f -delete -print
find $dest -name "*temp*" -type f -delete -print

echo "======== Removing Test Files ========"

find $dest -name "*test*" -type f -delete -print

echo "======== Committing changes on new branch ========"

new_branch=$package_name-$version
commit_message=$package_name:$version
cd $packages_fork_name
git branch $new_branch
git switch $new_branch
git add .
git commit -m "$commit_message"
git log -n 1

echo "======== Pushing new branch ========"

# NOTE: This is a test. Remove `--dry-run` to actually push your code upstream.
git push --dry-run origin $new_branch # --force # <-- Overwrite branch on origin
cd ..

echo "======== Done ========"
echo
echo "Go to <$packages_fork_address/tree/$new_branch> to review and create a pull request."

# Return to local package directory
cd $repository
