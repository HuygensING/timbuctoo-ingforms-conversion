## Aanleiding:

De emigratie onderzoeksgids is gemaakt in INGForms en moet worden omgezet naar json-ld om hem te kunnen opnemen in Timbuctoo. Een spreadsheet met tabellaire data is separaat geconverteerd. In de voorafgaande besprekingen werd afgesproken dat de gids omgezet zou worden naar json-ld, een incarnatie van RDF. De reden was dat

1. in tegenstelling tot de spreadsheet zijn dit gelaagde (of geneste) data die niet zomaar naar een plat tabelformaat zijn over te zetten en
2. er zijn veel meer ingforms gebaseerde data die allemaal volgens hetzelfde principe zijn geconstrueerd, dus in principe is dit werk generaliseerbaar.

In eerste instantie is de gids het uitgangspunt; generaliseren komt later.

In principe claimt json-ld een eenvoudige uitbreiding van standaard json te zijn waaraan alleen een @context moet worden toegevoegd; in de praktijk moesten er nog veel beslissingen genomen en aanpassingen aan de data gedaan om ze voor import in Timbuctoo gereed te maken.

Niet alle iteraties van de geconverteerde data of de conversiecode zijn bewaard. Hieronder geef ik de beslissingen weer die zijn genomen in de loop van het traject en de motivatie ervoor.

>N.B. Het is lastig alles gestructureerd te documenteren, want niet alles is op schrift besproken en als het op schrift staat worden vaak verschillende dingen tegelijkertijd besproken. Ik heb getracht ze zoveel mogelijk uiteen te trekken

### Conversieprogramma

Het conversie  [programma]('documentation.md') is apart gedocumenteerd.
Uitgangspunt was een __automatische__ conversie van ingforms, zonder veel ingrijpen in de datastructuur. Dergelijk ingrijpen is vrijwel altijd projectspecifiek en maakt verder deel uit van datacuratie. Ook moeten er bijna altijd besluiten met een inhoudelijke consequentie worden genomen. Dit maakt geen deel uit van een geautomatiseerd traject, waar kleine beslissingen tot verandering onvoorziene consequenties voor het te converteren materiaal kan hebben.

Er is vooralsnog geen automatische wijze om de resultaten van de conversie te testen. Dit is gedaan door handmatig een steekproef te testen op de [json-ld playground](https://json-ld.org/playground/). Er is wel software die de output kan parsen als test, maar die is niet erg geschikt om automatisch te testen, omdat de output niet strak is gefinieerd. Ook bestaan er geen richtlijnen waaraan een json-ld bestand voor input aan Timbuctoo moet voldoen, behalve dan dat het valide json-ld moet zijn.

De json-ld specificatie doet het voorkomen of vrijwel alle json mogelijk is, maar in de praktijk kan de parser eigenlijk alleen omgaan met uitgeschreven geneste datastructuren. Het is daarnaast lastig en omslachtig een type toe te kennen aan de data, want typen bestaan uit uri's. De specificatie gaat ervan uit dat je uri's gebruikt van gepubliceerde standaarden zoals van [schema.org](schema.org), maar in het  geval betekent dat interpretatie en datacuratie. Dat is een separate activiteit.

### Conversietraject en beslissingen

Eerste conversie niet verder gedocumenteerd. De conversie is gebaseerd op de python xmltodict software, die xml structuren omzet naar python dictionaries. Python dictionaries zijn heel eenvoudig op te slaan als json.

_json-ld_ structuur
Een json-ld bestand bestaat uit twee onderdelen:
- de object declaratie, die in een object staat
en
- de datadefinitie, die is ondergebracht in de @context.

De data definitie bestaat uit uri's die (geacht worden) de specificatie bevatten waaraan objecten voldoen. JSON-LD kent een paar shorthands om dit te vereenvoudigen. Zo is een waarde impliciet een 'string', behalve als er een ander type voor staat. Als de waarde van een object bijvoorbeeld html bevat (en dat gebeurt in INGForms nogal eens) dan moet dat worden gespecificeerd.

  _bijvoorbeeld_

```
"vindplaats": {
    "@type": "http://www.w3.org/1999/02/22-rdf-syntax-ns#HTML",
    "@value": "<p>National Library Australia,  Manuscript Section, Canberra ACT, Australi&#235;</p>\n<p>&#160;</p>\n<p><a href=\"http://www.nla.gov.au/ms/\" mce_href=\"http://www.nla.gov.au/ms/\">nla.gov.au/ms/</a></p>"
},
```

Soms heeft een object subobjecten, waarmee de declaratie complexer wordt.
Een type declaratie voor persoon, luidt  bijvoorbeeld zo:

```
"typering_persoon": {
        "@type": "http://resource.huygens.knaw.nl/ingforms/migratiegids/persoon/typering",
        "typering_persoon": [
            {
                "@id": "http://resource.huygens.knaw.nl/ingforms/migratiegids/persoon/typering/beleidsambtenaar"
            },
            {
                "@id": "http://resource.huygens.knaw.nl/ingforms/migratiegids/persoon/typering/diplomaat"
            }
        ]
    },
```
Merk op dat typering_persoon wordt herhaald. Dat is uit arren moede omdat er geen subtype nodig is, en 'value' lust de parser niet.

[overigens ben ik er niet helemaal zeker van dat dit goed gaat in Timbuctoo, maar het enige alternatief is een nieuw subobject introduceren voor de geneste typering_persoon]

Deze value heeft een @type en de lijst van waarden met @ids die typeringen zijn. Deze typeringen komen als aparte nodes terug in Timbuctoo (en worden daarmee elementen om door datasets heen te zoeken)

 Een type declaratie voor periode is nog wat ingewikkelder en kent de volgende elementen:


```
@context: {
  "periode_van_bestaan": "http://resources.huygens.knaw.nl/instelling/periode_van_bestaan",
  "date": "http://resources.huygens.knaw.nl/periode_van_bestaan/date",
  "begin": "http://resources.huygens.knaw.nl/instelling/periode_van_bestaan/begin",
  "end": "http://resources.huygens.knaw.nl/instelling/periode_van_bestaan/end"
}
```
in het object moet voorts de datum nog als zodanig worden gedeclareerd om als datum herkenbaar te zijn:
"http://www.w3.org/2001/XMLSchema#dateTime"
compleet wordt dat dan:

```
{
  "periode": {
        "end": {
            "date": {
                "@value": "31-12-1988",
                "@type": "http://www.w3.org/2001/XMLSchema#dateTime"
            },
            "@type": "http://resource.huygens.knaw.nl/ingforms/migratiegids/persoon/periode/end"
        },
        "begin": {
            "date": {
                "@value": "31-12-1912",
                "@type": "http://www.w3.org/2001/XMLSchema#dateTime"
            },
            "@type": "http://resource.huygens.knaw.nl/ingforms/migratiegids/persoon/periode/begin"
        },
        "@type": "http://resource.huygens.knaw.nl/ingforms/migratiegids/persoon/periode"
    }
}
```

### Conversaties en beslissingen

verder te lezen op [conversaties en beslissingen document](conversaties_beslissingen.md)
