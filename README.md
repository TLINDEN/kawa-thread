# kawa-thread
Archivieren eines kompletten kastenwagenforum.de Threads

# Abhängikeiten
Das Tool is in Perl geschrieben, das muss also installiert sein.

Es werden weitere Perlmodule benötigt:

* WWW::Mechanize
* HTTP::CookieJar::LWP
* IO::Socket::SSL
* Time::HiRes

Die Module können zum Beispiel mit [cpanm](https://metacpan.org/pod/distribution/App-cpanminus/lib/App/cpanminus/fatscript.pm) installiert werden.

# Benutzung

Zuerst wie üblich im Forum einloggen. Dann im Browser die Cookieliste öffnen und den Cookie **xf_session** für das Forum suchen. Ausserdem den Teil der URL notieren, der den Thread markiert, z.b:

[..]/forum/threads/**crafter-langer-radstand-mit-superhochdach-ausbautagebuch.24681**/

Ausserdem muss man sich notieren, wieviele Seiten der Thread hat, im obigen Beispiel sind es 43.

Das Tool muss in einer Shell aufgerufen werden, Beispielaufruf:

    archivethread.pl crafter-langer-radstand-mit-superhochdach-ausbautagebuch.24681 a9s78a9s7da98s7da98s7d9a87sd 43
    
Das Tool gibt sich als IE6 aus und wartet immer etwas zwischen den Seitenaufrufen, um als normaler User zu erscheinen und den Forumserver nicht unzulässig zu belasten.

# Resultate

Das Tool erzeugt pro Seite eine HTML-Datei (seite.html) und eine grosse Datei namens index.html, die alle Seiten beinhaltet. Es lädt ausserdem alle Bilder herunter und bettet sie direkt in den Seiten ein (man muss also nicht mehr draufklicken um zu vergrössern). Die index.html kann also recht gross werden!

# Weiterverarbeitung

Die index.html samt den eingebetteten Bildern kann dann mit einem geeigneten Tool zu PDF konvertiert werden. Zu empfehlen ist [Pandoc](https://pandoc.org/):

    pandoc -r html -w latex --latex-engine=xelatex -o ausbau.pdf index.html 
    
Neben Pandox muss XeTeX installiert sein.


# Lizenz und Copyright

Das Tool steht unter der BSD Lizenz, jedermann kann damit tun, was immer er will.

Auf mein Copyright verzichte ich hiermit.
