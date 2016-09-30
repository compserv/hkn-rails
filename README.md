Welcome to HKN
==============

TODO: Add useful information.

Vagrant, VMs, and You
---------------------
1) Install <a href = "https://www.virtualbox.org/wiki/Downloads">VirtualBox</a> (<tt>sudo apt-get install virtualbox</tt>)<br>
2) Install the latest version of <a href = "http://www.vagrantup.com/downloads.html">Vagrant</a> (<tt>sudo apt-get install vagrant</tt>)<br>
3) Download a backup of the website from hkn (<tt>/var/www/hkn-rails/db/backups/</tt>) and move it into your copy of hkn-rails.  See section below on making backups if you want a current one.<br>
4) <tt>cd hkn-rails</tt><br>
5) <tt>vagrant up</tt><br>
If Vagrant gives you an error along the lines of "The guest machine entered an invalid state...", try to start the VM from VirtualBox.  If VirtualBox gives you the error "VT-x is not available...", do the following:<br>
    5.1) <tt>vagrant halt</tt><br>
    5.2) <tt>vagrant destroy</tt><br>
    5.3) Change your BIOS settings to enable hardware acceleration<br>
    5.4) <tt>vagrant up</tt> and continue to step 6.<br>
6) <tt>vagrant ssh</tt><br>
7) <tt>cd /vagrant</tt><br>
8) <tt>rake db:create && rake db:backup:restore FROM=[path\_to\_backup\_from\_hkn]</tt><br>
9) <tt>rails s</tt><br>
10) On your host machine, visit <tt>localhost:3000</tt><br>
<p>
Your copy of hkn-rails on your host is a shared directory with \vagrant on your guest, so you can edit files in either machine.
</p>
<p>
The guest is configured to port forward 3000 to 3000 on the host.  The VM is allocated 1 GB of memory and is based on Ubuntu 12.04 64-bit.
</p>
<p>
To stop the VM, either <tt>vagrant halt</tt> or <tt>vagrant suspend</tt>.  To resume again, <tt>vagrant up</tt>.
<p>
Making Backups
---------------------
1) On hkn, go into <tt>/var/www/hkn-rails</tt><br>
2) <tt>sudo su www-data</tt><br>
3) <tt>export RAILS_ENV=production</tt>  (if you want backup of production)<br>
4) <tt>rake db:backup:dump</tt> (actual script is in <tt>hkn-rails/lib/tasks/backups.rb</tt>)<br>
This makes a backup in <tt>hkn-rails/db/backups</tt>, name based on datetime by default.<br>

To load a backup: <tt>rake db:drop && rake db:create && rake db:backup:restore FROM=[path]</tt><br>

Static Files
----------------------
To serve new static files in production, first run <tt>RAILS_ENV=production bundle exec rake assets:precompile</tt>

Stuff that used to be in README.d
---------------------------------

### How to use Solr ###

1) bundle install
2) add searchables to your model
   http://github.com/outoftime/sunspot/wiki/Setting-up-classes-for-search-and-indexing
3) reindex


Sunspot includes its own version of solr that's easy to use, and you don't have to
install Solr on Tomcat/Jetty/etc. yourself.
 Note: Puts index files somewhere in your /tmp
1) rake sunspot:solr:start
2) rake sunspot:solr:reindex whenever you change the 'searchable' information in your model.
   You don't have to reindex when you change data.
   Also, the solr server has to be started before you reindex.
3) rake sunspot:solr:stop if you want to stop the search daemon


Sunspot:Solr presents an admin page on ports 8981:8983 (per environment; see
config/sunspot.yml) that you probably want to close to the outside:
  iptables -I INPUT -j ACCEPT --dport 8981:8983 -i lo       # Allow local connections
  iptables -I INPUT -j DROP --dport 8981:8983               # Else, drop

  ( ^ can somebody please verify that this is correct? )


For examples of searching, see coursesurveys#search and course.rb.
