# EEBO-TCP texts for the Early Print Library from the EarlyPrint Project.

Currently contains approximately 52,000 EEBO-TCP-derived texts with linguistic
tagging and other enhancements.

This is a combined repository using a git submodule for each subdirectory of the texts
directory.  Each submodule is named after the first three letters of the TCP
identifiers, so, for example A77349.xml is found under `texts/A77/`.

## Cloning

From the command line, if you have a BitBucket account and have loaded your public key
on the account, you can get the combined repository with:

    git clone git@bitbucket.org:eplib/eebotcp.git
    cd eebotcp
    git submodule init
    git submodule update

For a GUI interface, BitBucket has one called
[SourceTree](https://www.sourcetreeapp.com) that can handle submodules.  To
clone, click the New button, choose "Clone from URL," enter the URL
`git@bitbucket.org:eplib/eebotcp.git`, and under advanced options make
sure that "Recurse submodules" is checked.

With or without a BitBucket account, you may use the HTTPS URL to clone:

    git clone https://bitbucket.org/eplib/eebotcp.git eebotcp
    cd eebotcp
    git submodule init

At this point there is an additional step in which you must replace every
occurrence of `git@bitbucket.org:` with `https://bitbucket.org/` in the git
configuration file located at `.git/config`.  This step is necessary to convert the
git URLs for all the subrepositories to HTTPS URLs.  If you have Perl, this can be
done from the command line like so:

    perl -pi -e 's|git\@bitbucket.org:|https://bitbucket.org/|' .git/config 

or use a global search and replace in your favorite text editor.  Finally,
complete your local repository initiation with:

    git submodule update
    git submodule foreach 'git checkout master'

## Formatting Pre-commit Hook

If you will be committing any changes to the texts, please install the formatting
pre-commit hook in the `util/` directory.  Install it like so:

    git submodule foreach 'cp ../../util/pre-commit-format.sh ../../.git/modules/$path/hooks/pre-commit'

The hook requires Python 3 and the [lxml](https://lxml.de) library.  What this
hook does is intervene right before each commit and consistently format the
XML, sorting attributes for each element by name and indenting with a single
space, thus preventing non-meaningful changes to formatting from being recorded
in git history.

## Committing

Adding more texts or changing existing texts requires additional steps
compared to working with a single repository.  Commits must first be done in
all affected subrepositories.  Something like the following command, which
checks for uncommitted changes in each submodule and then commits them, should
do the trick:

    git submodule foreach 'if [ -n "$(git status --porcelain)" ]; then git commit -a -m "Make a change"; fi'

At this point, each updated subrepository registers as a single uncommited
file in the super-repository, which you can see by running `git status`. Do a
single commit in the super-repository followed by `git push` and all the
subrepositories will be iteratively pushed.
