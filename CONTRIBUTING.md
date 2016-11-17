# How to contribute

iptables Scripts is a set of scripts kicked off by [Ray-works.de]. I have
adopted the scripts, published them on GitHub and added some features I needed.
If you feel the same we, don't hesitate to contribute on form of code, test,
documentation, child projects, etc.

If you are unsure of how and where to contribute, just get in touch with me.

## Getting Started

* Make sure you have a [GitHub] account.
* Submit a ticket for your issue, assuming one does not already exist.
  * Clearly describe the issue including steps to reproduce when it is a bug.
  * Make sure you fill in the earliest version that you know has the issue.
* Fork the repository on GitHub

## Making Changes

* Create a topic branch from where you want to base your work.
  * This is usually the master branch.
  * Only target release branches if you are certain your fix must be on that
    branch.
  * To quickly create a topic branch based on master: `git checkout -b
    fix/master/my_contribution master`. Please avoid working directly on the
    `master` branch.
* Make commits of logical units.
* Check for unnecessary whitespace with `git diff --check` before committing.
* Make sure your commit messages are in the proper format.

````
    (#4321) Change the name of docker variable

    This patch changes the name of the docker variable due to compatibality reasons.
    (more details).
````

## Making Trivial Changes

### Documentation

For changes of a trivial nature to comments and documentation, it is not always
necessary to create a new ticket in GitHub. In this case, it is appropriate to
start the first line of a commit with '(doc)' instead of an issue number.

````
    (doc) Add documentation for the docker feature

    This is a trivial change..

    The first line is a real life imperative statement with '(doc)' in
    place of what would have been the issue number in a
    non-documentation related commit. The body describes the nature of
    the new documentation or comments added.
````

## Submitting Changes

* Push your changes to a topic branch in your fork of the repository.
* Submit a pull request to the repository at [moritzrupp/iptables-scripts].
* Update your issue ticket to mark that you have submitted code and are ready
for it to be reviewed.
  * Include a link to the pull request in the ticket.
* I will look at Pull Requests on a regular basis and will interact with you
directly in the pull request.

[Ray-works.de]: https://ray-works.de
[GitHub]: https://github.com
[moritzrupp/iptables-scripts]: https://github.com/moritzrupp/iptables-scripts/compare
