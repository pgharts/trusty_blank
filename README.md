trusty_blank
============

A blank instance of a TrustyCMS site, to be used for testing.

## Getting started

1. Clone this repo to your local machine.
  * git clone git@github.com:pgharts/trusty_blank.git
2. Clone trusty-cms to your local machine, too.
  * git clone git@github.com:pgharts/trusty-cms.git
3. Rename Gemfile.example to Gemfile
4. Change the :path for the trusy-cms gem to point to the folder where you cloned the trusty-cms repo.
  * it'll look like this: gem "trusty-cms", :path => '../trusty-cms'
5. Rename database.yml.example to database.yml and edit to match the username, password, and host of your local mysql setup.
6. Run 'bundle install' to install all gems.
7. Set up the database
  * rake db:create
  * rake db:bootstrap
8. The bootstrap script will ask you some questions.
  * when asked if you're sure, answer 'y'
  * Leave Name, Username, and Password as defaults by hitting enter when prompted
  * ERROR: Install currently breaking at this step. Checking in docs to this point.
