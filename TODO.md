# TODO's

Übersicht der mir bekannten, wichtigsten TODOs bis zum GoLive. Alles andere sollte funktionieren. Wenn darüberhinaus Punkte auffallen, bitte mir melden. Zunächst bitte nur "Blocker", d.h. Punkte die unbedingt zum 1.8. laufen müssen. Dies betrifft sowohl Funktionen als auch die Darstellung und Suchbarkeit der Metadaten.

## Suche / Facetten (Lokal)

* [x] ~~Es fehlen noch die Sortierung nach Bandzählung~~
* [x] ~~Es fehlen noch einige Suchfelder~~
* [x] ~~Reihenfolge der Facetten noch nicht korrekt~~
* [x] ~~Facette "Sprache" zeigt nur die Sprach-Codes an~~
* [x] ~~Facette "Erscheinungsjahr" ist noch keine "Range"-Facette~~
* [x] ~~Facette "Neuerwerbungen" fehlt noch~~

## Suche / Facetten (CDI)

* [ ] Mit Volltext-Zugriff scheint noch nicht korrekt zu funktionieren
* [x] ~~Es fehlen noch Suchfelder~~
* [x] ~~Anzahl Suchergebnisse leicht anders als im Produktionssystem~~
* [x] ~~Es fehlen noch Facetten~~

## Titel Detailseite

* [x] ~~Die Darstellung der Metadaten ist noch nicht "schön"~~
* [x] ~~Es feht die Funktion "zeige Bände"~~
* [ ] Zeige Bände wird angezeigt, auch wenn keine Bestände hinter der Überordnung zu finden sind.
* [x] ~~Es werden noch keine hilfreichen "Standorte" angezeigt, sondern nur die interne Standortbezeichnung.~~
* [ ] Links zum Volltext sind noch nicht sortiert/priorisiert und stehen zuweit unten
* [ ] Virtuelle Exemplare um z.B. CD-Rom Beilagen via Magazinbestellung bestellen zu können, werden noch nicht generiert. Beispiel: 001458875
* [x] ~~Integration mit Regaldatenbank fehlt noch.~~
* [x] ~~"Funktionsbezeichnugen" bei Personen und Köperschaften noch nicht vollständig udn korrekt.~~
* [ ] "Funktionsbezeichnungen": Es fehlen noch Einträge in der Übersetzungstabelle für RDA-Codes.

## Exemplare

* [x] ~~Handapparatsexemplare können vorgemerkt werden. => In Alma ändern.~~
* [ ] Standort-Sonderfall Handapparat: Beispiel: 990009300360106463
* [ ] Standort-Sonderfall IEMAN
* [ ] Standort-Sonderfall E-Seminarapparate
* [x] ~~Standorte aus RegalDB für Monos anzeigen~~
* [ ] Statische Standort-Tabelle auswerten für alles was nicht aus der RegalDB kommt oder ein Sonderfall ist.
* [ ] Ausgesonderte Exemplare oder Exemplare auf Standorten die nicht angezeigt werden sollen, müssen unterdrückt werden. Beispiel: 990009694420106463
* [ ] "Status-Ampel" fehlt

## Kontofunktionen

* [x] ~~Es feht noch die Seite für Fernleihbestellungen~~
* [x] ~~Die Details bei Gebühren und Ausleihen sind noch nicht 100%ig und noch nicht "schön"~~
* [x] ~~Bisher keine Anziege hinterlegter Daten (z.B. E-Mail Adresse)~~
* [x] ~~Änderung Passwort~~
* [x] ~~Änderung der E-Mail Adresse für "externe" Nutzer~~

## Suchindex

* [x] ~~Es fehlen noch Daten zu Sekundärformen~~
* [x] ~~Als gelöscht markierte Titel und als ausgesonderte makierte Exemplare werden angezeigt.~~

## CDI

* [x] ~~CDI verwendet noch nicht den Key für die Alma-Instanz, sondern noch unseren alten für die SFX Aktivierungen~~
* [ ] Es fehlen in den Titeldetails noch ein paar Felder
* [ ] Es fehlt noch die Integration von bX
* [ ] & in einem Facetten-Wert (z.B. Thema => Science & Technology) führt zu 0 Treffern.
* [ ] Hinweis auf VPN/Shibboleth bei Suchen außerhalb des Campusnetzes anzeigen

## Sonstiges

* [ ] Icons und Cover noch nicht 100%ig
* [ ] RSS Feed für Suchergebnisse fehlt
* [ ] "Alte" Urls für Suche / Detailseite etc. sollen so gut wie möglich weiter funktionieren. Dies muss noch weiter verbessert werden.
* [ ] Anzeige Link-Resolver noch verbessern
* [ ] 500 und 404 Fehlerseiten in Katalog-Design fehlen
* [ ] NewRelic integrieren
* [ ] BibTeX export fehlt noch
* [ ] Stopwörter bei Phrasensuche für Ranking berücksichtigen
* [ ] Alle alten routen auf ggf. neue Routen umleiten
* [ ] Alert für Search-Validation anpassen/abschalten
* [ ] Info-Text über den neuen Katalog erstellen
