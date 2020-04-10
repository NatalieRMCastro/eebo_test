#/bin/sh
topdir="$(dirname "$0")/../"
olddir=`pwd`
cd "$topdir"
git diff --name-only HEAD~1  -- texts/* | xargs -I {} sh -c 'cd {}; git diff --name-only HEAD~1 -- *.xml; cd ../../'
cd "$olddir"
