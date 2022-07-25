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

* [x] ~~Mit Volltext-Zugriff scheint noch nicht korrekt zu funktionieren~~
* [x] ~~Es fehlen noch Suchfelder~~
* [x] ~~Anzahl Suchergebnisse leicht anders als im Produktionssystem~~
* [x] ~~Es fehlen noch Facetten~~

## Titel Detailseite

* [ ] Zeige Bände wird angezeigt, auch wenn keine Bestände hinter der Überordnung zu finden sind.
* [ ] Virtuelle Exemplare um z.B. CD-Rom Beilagen via Magazinbestellung bestellen zu können, werden noch nicht generiert. Beispiel: 001458875
* [ ] "Funktionsbezeichnungen": Es fehlen noch Einträge in der Übersetzungstabelle für RDA-Codes.
* [ ] "Virtueller" Zeitschriftenbestand bzw. Beschreibungen fehlen. Beispiel: 990017604110106463
* [x] ~~Die Darstellung der Metadaten ist noch nicht "schön"~~
* [x] ~~Es feht die Funktion "zeige Bände"~~
* [x] ~~Es werden noch keine hilfreichen "Standorte" angezeigt, sondern nur die interne Standortbezeichnung.~~
* [x] ~~Links zum Volltext sind noch nicht sortiert/priorisiert und stehen zuweit unten~~
* [x] ~~Integration mit Regaldatenbank fehlt noch.~~
* [x] ~~"Funktionsbezeichnugen" bei Personen und Köperschaften noch nicht vollständig udn korrekt.~~

## Exemplare

* [ ] "Status-Ampel" fehlt
* [x] ~~Ausgesonderte Exemplare oder Exemplare auf Standorten die nicht angezeigt werden sollen, müssen unterdrückt werden. Beispiel: 990009694420106463~~
* [x] ~~Standort-Sonderfall E-Seminarapparate: Es wird noch nicht der konkrete Seminarapparat angezeigt.~~
* [x] ~~Signaturen auf Webseite verlinken~~
* [x] ~~Statische Standort-Tabelle auswerten für alles was nicht aus der RegalDB kommt oder ein Sonderfall ist.~~
* [x] ~~Standort-Sonderfall Handapparat: Beispiel: 990009300360106463~~
* [x] ~~Standort-Sonderfall IEMAN~~
* [x] ~~Standort-Sonderfall E-Seminarapparate~~
* [x] ~~Handapparatsexemplare können vorgemerkt werden. => In Alma ändern.~~
* [x] ~~Standorte aus RegalDB für Monos anzeigen~~

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

* [ ] Es fehlt noch die Integration von bX
* [x] ~~& in einem Facetten-Wert (z.B. Thema => Science & Technology) führt zu 0 Treffern.~~
* [x] ~~CDI verwendet noch nicht den Key für die Alma-Instanz, sondern noch unseren alten für die SFX Aktivierungen~~
* [x] ~~Es fehlen in den Titeldetails noch ein paar Felder~~
* [x] ~~Hinweis auf VPN/Shibboleth bei Suchen außerhalb des Campusnetzes anzeigen~~


## Sonstiges

* [ ] RSS Feed für Suchergebnisse fehlt
* [ ] 500 und 404 Fehlerseiten in Katalog-Design fehlen
* [ ] NewRelic integrieren
* [ ] BibTeX export fehlt noch
* [ ] Stopwörter bei Phrasensuche für Ranking berücksichtigen
* [ ] Alert für Search-Validation anpassen/abschalten
* [ ] Info-Text über den neuen Katalog erstellen
* [ ] Anpassung an Mobilegräte
* [x] ~~!!!Alle alten routen auf ggf. neue Routen umleiten~~
* [x] ~~Anzeige Link-Resolver noch verbessern~~
* [x] ~~Icons und Cover noch nicht 100%ig~~
