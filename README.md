# Welcome to HKN

TODO: Add useful information.


## Vagrant, VMs, and You

1. Install [VirtualBox][virtualbox] (`sudo apt-get install virtualbox`)
2. Install the latest version of [Vagrant][vagrant] (`sudo apt-get install vagrant`)
3. Download a backup of the website from hkn (`/var/www/hkn-rails/db/backups/`) and move it into your copy of hkn-rails.  See section below on making backups if you want a current one.
4. `cd hkn-rails`
5. `vagrant up`

  If Vagrant gives you an error along the lines of `The guest machine entered an invalid state...`, try to start the VM from VirtualBox.  If VirtualBox gives you the error `VT-x is not available...`, do the following:

    1. `vagrant halt`
    2. `vagrant destroy`
    3. Change your BIOS settings to enable hardware acceleration
    4. `vagrant up` and continue to step 6.
6. `vagrant ssh`
7. `cd /vagrant`
8. `rake db:create && rake db:backup:restore FROM=[path_to_backup_from_hkn]`
9. `rails s`
10. On your host machine, visit `localhost:3000`

Your copy of hkn-rails on your host is a shared directory with `\vagrant` on your guest, so you can edit files in either machine.

The guest is configured to port forward 3000 to 3000 on the host.  The VM is allocated 1 GB of memory and is based on Ubuntu 14.04 64-bit.

To stop the VM, either use `vagrant halt` or `vagrant suspend`. To resume again, `vagrant up`.

[virtualbox]: https://www.virtualbox.org/wiki/Downloads
[vagrant]: http://www.vagrantup.com/downloads.html


## Making Backups

1. On hkn, go into `/var/www/hkn-rails`
2. `sudo su www-data`
3. `export RAILS_ENV=production` (if you want backup of production)
4. `rake db:backup:dump` (actual script is in `hkn-rails/lib/tasks/backups.rb`)

This makes a backup in `hkn-rails/db/backups`, name based on datetime by default.

To load a backup: `rake db:drop && rake db:create && rake db:backup:restore FROM=[path]`


## Static Files

To serve new static files in production, first run `RAILS_ENV=production bundle exec rake assets:precompile`


### How to use Solr

1. `bundle install`
2. [Add searchables to your model][searchables]
3. Reindex

Sunspot includes its own version of solr that's easy to use, and you don't have to
install Solr on Tomcat/Jetty/etc. yourself.

Note: Puts index files somewhere in your `/tmp`

1. `rake sunspot:solr:start`
2. `rake sunspot:solr:reindex` whenever you change the 'searchable' information in your model.

   You don't have to reindex when you change data.
   Also, the solr server has to be started before you reindex.

3. `rake sunspot:solr:stop` if you want to stop the search daemon

Sunspot:Solr presents an admin page on ports 8981:8983 (per environment; see
`config/sunspot.yml`) that you probably want to close to the outside:

    iptables -I INPUT -j ACCEPT --dport 8981:8983 -i lo       # Allow local connections
    iptables -I INPUT -j DROP --dport 8981:8983               # Else, drop

    (^ can somebody please verify that this is correct?)

For examples of searching, see [coursesurveys#search][coursesurveys] and [course.rb][course.rb].

[searchables]: http://github.com/outoftime/sunspot/wiki/Setting-up-classes-for-search-and-indexing
[coursesurveys]: app/controllers/coursesurveys_controller.rb#L448
[course.rb]: app/models/course.rb#L45
