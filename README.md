trusty_blank
============

A blank instance of a TrustyCMS site, to be used for testing.

## Getting started

1. Clone this repo to your local machine.
  * git clone git@github.com:pgharts/trusty_blank.git
2. Clone trusty-cms to your local machine, too.
  * git clone git@github.com:pgharts/trusty-cms.git
3. Clone required extensions to your local machine
  * git clone git@github.com:pgharts/trusty-snippets-extension.git
  * git clone git@github.com:pgharts/trusty-clipped-extension.git
  * git clone git@github.com:pgharts/trusty-share-layouts-extension.git
  * git clone git@github.com:pgharts/trusty-multi-site-extension.git
  * git clone git@github.com:pgharts/trusty-reorder-extension.git
4. Rename Gemfile.example to Gemfile
5. Change the :path for the trusy-cms gem & extensions to point to the folder where you cloned the trusty-cms repo.
  * it'll look like this: gem "trusty-cms", :path => '../trusty-cms'
6. Rename config/database.yml.example to config/database.yml and edit to match the username, password, and host of your local mysql setup.
7. Run 'bundle install' to install all gems.
8. Set up the database
  * rake db:create
  * rake db:bootstrap
  * rake trusty:seed:sites
9. The bootstrap script will ask you some questions.
  * when asked if you're sure, answer 'y'
  * Leave Name, Username, and Password as defaults by hitting enter when prompted
10. That should do it. If you 'rails s' a server should start.
