Boligprisindeks
===============

Crowdsourcing av boligprisprognoser.

# Deploye til heroku

    $ heroku create min-app
    $ git push heroku master
    $ heroku run rake rake db:migrate:up
    $ rake scrape:nef

# Migrering

Migreringsscriptene er skrevet med sequel http://sequel.rubyforge.org/

# Autentisering med facebook, twitter osv.

For å kunne autentisere mot facebbok, må man logge seg inn http://developers.facebook.com/apps og
registrere en app. Husk at det er tillatt å la appen ha adresse http://localhost:1234 også hvis
man skal kjøre lokalt.

# Om denne applikasjon

Denne applikasjonen ble påbegynt av Thomas Flemming thomas.flemming@gmail.com Mars 2013.
