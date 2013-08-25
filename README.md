Welcome to HKN
==============

TODO: Add useful information.

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
