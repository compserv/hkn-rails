# Welcome to HKN

## Vagrant, VMs, and You

1. Install [VirtualBox][virtualbox] (`sudo apt-get install virtualbox`)
2. Install the latest version of [Vagrant][vagrant] (`sudo apt-get install vagrant`)
4. `cd hkn-rails`
5. `vagrant up`

  If Vagrant gives you an error along the lines of `The guest machine entered
  an invalid state...`, try to start the VM from VirtualBox.  If VirtualBox
  gives you the error `VT-x is not available...`, do the following:

    1. `vagrant halt`
    2. `vagrant destroy`
    3. Change your BIOS settings to enable hardware acceleration (this will
       require a system reboot)
    4. `vagrant up` and continue to step 6.

6. `vagrant ssh`
7. `cd /vagrant`
9. `rails s -b 0`
10. On your host machine, visit `localhost:3000`

Your copy of hkn-rails on your host is a shared directory with `\vagrant` on
your guest, so you can edit files in either machine.

The guest is configured to port forward 3000 to 3000 on the host.  The VM is
allocated 1 GB of memory and is based on Debian 9 (stretch, 64 bit).

To stop the VM, either use `vagrant halt` or `vagrant suspend`. To resume
again, run `vagrant up`.

### Autosyncing

The Vagrant VM uses Debian 9, the OS run on the OCF apphost. Because it does
not have the Oracle VM Virtualbox Extension Pack installed, the `/vagrant`
folder is synced with your computer's `hkn-rails` folder using `rsync`.

By default, this is only done on VM startup, so to enable autosyncing run:

```sh
vagrant rsync-auto
```

This will trigger an rsync upon file changes.

### Running from Backups

If you would like to run with real data from the production database, then:

1. Download a backup of the website from compserv. These are kept secret
   because they contain sensitive data like password hashes.
2. Move the database backup into your copy of hkn-rails.
3. Make sure the database has been rsync'd into your VM (either by `vagrant rsync`
   or by `vagrant rsync-auto`).
4. `rake db:backup:restore FROM=[path_to_backup]`

See section below on [making backups](#making-backups) for more info on getting a backup.

[virtualbox]: https://www.virtualbox.org/wiki/Downloads
[vagrant]: http://www.vagrantup.com/downloads.html

## Deploying

First, ensure that your dev environment is setup:

```sh
bundle install
```

Then deploy to the `production` target with:

```sh
bundle exec cap production deploy
```

## Editing the Database

Once you've ssh'd into the OCF apphost server (`hkn@apphost.ocf.berkeley.edu`),
cd into the current production deploy folder and run:

```sh
bundle exec rails console -e production
```

This will open a Ruby interactive shell with access to the database model.

If you would like to sandbox your session (roll back all changes once you finish), run:

```sh
bundle exec rails console -e production --sandbox
```

## Making Backups

1. On apphost.ocf.berkeley.edu, go into `/var/www/hkn-rails`
2. `sudo su www-data`
3. `RAILS_ENV=production rake db:backup:dump` (actual script is in
   `hkn-rails/lib/tasks/backups.rb`)

This makes a backup in `hkn-rails/db/backups`, name based on datetime by
default.

To load a backup:

```sh
rake db:drop && rake db:create && rake db:backup:restore FROM=[path]
```

## Static Files

To serve new static files in production, first run 

```sh
RAILS_ENV=production bundle exec rake assets:precompile
```

### How to use Solr

1. `bundle install`
2. [Add searchables to your model][searchables]
3. Reindex

Sunspot includes its own version of solr that's easy to use, and you don't have to
install Solr on Tomcat/Jetty/etc. yourself.

Note: Puts index files somewhere in your `/tmp`

1. `rake sunspot:solr:start`
2. `rake sunspot:solr:reindex` whenever you change the 'searchable' information
   in your model.

   You don't have to reindex when you change data, that will be reindexed
   automatically. Make sure the solr server is started before you reindex.

3. `rake sunspot:solr:stop` if you want to stop the search daemon

Sunspot:Solr presents an admin page on ports 8981:8983 (per environment; see
`config/sunspot.yml`) that you probably want to close to the outside (this is
already done in production):

    iptables -I INPUT -j ACCEPT --dport 8981:8983 -i lo # Allow local only
    iptables -I INPUT -j DROP --dport 8981:8983         # Else, drop

For examples of searching, see [coursesurveys#search][coursesurveys] and
[course.rb][course.rb].

[searchables]: http://github.com/outoftime/sunspot/wiki/Setting-up-classes-for-search-and-indexing
[coursesurveys]: app/controllers/coursesurveys_controller.rb#L448
[course.rb]: app/models/course.rb#L45
