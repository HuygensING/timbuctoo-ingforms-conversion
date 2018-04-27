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


**Conversaties en beslissingen**

__algemeen__

[1 mei]
[rik]

Hierbij een zipfile met de emigratie gids die in ingforms stonden in json-ld formaat, met included context. Ze valideren nu helemaal tegen de parser op http://json-ld.org/playground/. Dat was nog wel een klusje met de geneste objecten

Voor wat betreft de import in Timbuctoo: Wat ons betreft is het voor nu genoeg om verschillende bestanden te importeren:

- de spreadsheet met de steekproef (‘mastersheet’), die we vorige maand samen op google docs hebben gezet (https://docs.google.com/spreadsheets/d/1nJvcXoMlT8vRn55LZXhXjAPM7v4KjosZgrCj9OuQ4nM/edit#gid=1383328803)
- dit bestand, dat ik voor het gemak maar even attach.

De ‘ruwe’, grotere database laten we nu even buiten beschouwing; het is belangrijker dat we nu verder kunnen met de data in deze bestanden.

Als we dit kunnen importeren, kunnen we er mee aan de gang. Ik weet niet hoe ik een json-ld bestand in timbuctoo moet importeren. Kon geen documentatie vinden. Kun je me dat leren of de documentatie wijzen?


[jauco]

Ik denk dat je conversie nog niet helemaal goed is. Er zijn een paar simpele foutjes
 - je zet een @context in een @context
 - je gebruikt de prefix huy, maar definieert die niet
 - alle documenten hebben dezelfde @id ("http://resources.huygens.knaw.nl//instelling") wat betekent dat ze uiteindelijk allemaal 1 entiteit in de database gaan worden

er zijn ook wat meer data-inhoudelijke issues
 - sommige items bevatten html, dit is sowieso niet zo fijn, maar het is wel goed als die iig een datatype mee krijgen. Dan kunnen we het dalijk goed renderen in de frontend<sup>[1](#fn1)</sup>. Dit doe je door achter de sluitende " het volgende te plaatsen

 ```
 ^^<http://www.w3.org/1999/02/22-rdf-syntax-ns#HTML> dus         "huy:verw_wetten": "<p>geen [m.b.t. emigratie]</p>",  wordt dan         "huy:verw_wetten": "<p>geen [m.b.t. emigratie]</p>"^^<http://www.w3.org/1999/02/22-rdf-syntax-ns#HTML>,
 ```

 - je wil periode misschien niet als html encoderen maar als echte datum range?
 - bij een link geef je een @id en een huy:relation op. Ik weet niet goed wat huy: relation betekent. De @id moet iig hetzelfde zijn als de @id in het json-document waar je heen linked

Nog twee tips
 - huy:land_herkomst en huy:zuil is een anoniem object met 1 property. Dat kan denk ik beter een link worden (een @id) zodat we dalijk een land entiteit hebben waar alles aan gelinked is ipv heel veel land entiteitjes met dezelfde huy:land waarde Dit gebeurt vast ook op andere plaatsen
 - voor de import is het handig als het 1 grote file wordt met daarin de @context en dan een property @graph met daarin een array met alle objecten

<a href="#fn1"> we moeten er dan wel een filter overheen gooien. dat hebben we nu nog niet gebouwd.</a>

>_opmerkingen_: in principe was afgesproken de



__type__

>Ik bedacht me net dat het ook erg nuttig is dat objecten per classe een @type krijgen. (dus dat alle instelling een
<pre>
"@type": "http://resource.huygens.knaw.nl/ingforms/migratiegids/instelling"</pre>, krijgen) anders denkt timbuctoo dat ze allemaal van hetzelfde type zijn.

[jauco]
Verder kan ik je ook aanraden om minimaal 1 keer de "non-conformative" gedeeltes van de json-ld spec te lezen (dat zijn de voorbeelden en de tutorial)
```
 http://json-ld.org/spec/latest/json-ld/#basic-concepts
 ```

 en
```
 http://json-ld.org/spec/latest/json-ld/#advanced-concepts
```

__verwijzingen__

[rik]
De relations had ik even zo gelaten omdat ze ingforms specifiek waren (had ook relations). Verwijzen naar het id in het referentieobject kan natuurlijk, maar het zou kunnen dat er verschillende typen objecten zijn met dezelfde id. In principe (hoewel dat hier niet aan de orde is) zou je ook willen kunnen verwijzen naar objecten in andere datasets. Bestaat daar al een methode voor?

[jauco]
> Ik denk dat je dan het beste een url kan maken met zowel het type als het id erin.
dus de @id van een entry is dan:

>```
http://resource.huygens.knaw.nl/ingforms/{
collectienaam-in-ingforms}/{typenaam}/{filename}
```
>bijvoorbeeld:

>```
 http://resource.huygens.knaw.nl/ingforms/migratiegids/instelling/01Aartsbisdom_Utrecht
 ```


__perioden__
[18 mei]
[rik]

Nog een paar dingetjes nav je suggesties:


```
"huy:verw_wetten": "<p>geen [m.b.t. emigratie]</p>",  
```
wordt dan
```         "huy:verw_wetten": "<p>geen [m.b.t. emigratie]</p>"^^<http://www.w3.org/1999/02/22-rdf-syntax-ns#HTML>
```,


Je stelt voor values met html erin te declareren door
``` ^^<http://www.w3.org/1999/02/22-rdf-syntax-ns#HTML>
```
achter het sluitende aanhalingsteken te plaatsen. Dat is geen valide json en ook de json-ld voorbeeld parser op de site slikt het niet. Bovendien wil mijn jsonwriter het niet schrijven :-) Ik kan wel de declaratie in de aanhalingtekens plaatsen, maar vermoed dat de parser er dan overheen kijkt.

Ik stel voor in plaats daarvan het op te lossen door een value object te gebruiken zoals gespecificeerd in de specificatie
```
 http://json-ld.org/spec/latest/json-ld/#typed-values
```

 en voorbeeld 24; het voorbeeld wordt dan


```
 "huy:verw_wetten": {“value”: "<p>geen [m.b.t. emigratie]</p>”,
“type”:"http://www.w3.org/1999/02/22-rdf-syntax-ns#HTML” }
```


Als er meer dan een link is, staan ze in een lijst. Bijvoorbeeld

```
"huy:andere_archiefvormers_link”:
"@id” =  [
            "http://resource.huygens.knaw.nl/ingforms/migratiegids/persoon/01cnv",
            "http://resource.huygens.knaw.nl/ingforms/migratiegids/persoon/01arp"
        ],
```

Dat lijkt me een prima oplossing, maar de json-ld parser lust het niet, want vindt dat een @id een string als value moet hebben. Dubbele declaratie van @id slikt hij wel, maar het lijkt me dat je dan in de tweede declaratie van @id de eerste override

vb (uit het hoofd opgeschreven, dus misschien niet helemaal goed:

```
"huy:andere_archiefvormers_link": [
            "@id":"http://resource.huygens.knaw.nl/ingforms/migratiegids/persoon/01cnv",
            "@id":"http://resource.huygens.knaw.nl/ingforms/migratiegids/persoon/01arp"  
        ],
```

Voorstel oplossing om dan de @id declaraties maar in een anonieme dictionary te zetten:

```
"huy:andere_archiefvormers_link": [
            {"@id":"http://resource.huygens.knaw.nl/ingforms/migratiegids/persoon/01cnv"},
            {"@id":"http://resource.huygens.knaw.nl/ingforms/migratiegids/persoon/01arp"}  
        ],
        ```

Ook niet helemaal duidelijk wat dit betekent, maar logischer dan de andere oplossing

____

[november]
[rik]

Ik heb zitten knutselen aan de json-ld van ingforms. Het meeste van de problemen kan ik wel oplossen, maar in de json-ld playground is er met het bijgeloten minimalistische json-ld bestand een verschil tussen periode_van_bestaan en land_herkomst .... Ik zie het verschil niet in input, maar de output is anders. Zie jij meer dan ik?

_Input_:

```
{
        "naam_archiefvormer": "Centrale Stichting Landbouw Emigratie",
        "land_herkomst": {
            "land": {
                "@type": "http://resource.huygens.knaw.nl/ingforms/migratiegids/instelling/land",
                "@value": "nederland"
            },
          "@type": "http://resource.huygens.knaw.nl/ingforms/migratiegids/instelling/land_herkomst"
        },
        "periode_van_bestaan": {         
          "end": {
                    "@type": "http://resource.huygens.knaw.nl/ingforms/migratiegids/instelling/period/end",

"@value": "31-12-1953"

          },
           "@type": "http://resource.huygens.knaw.nl/ingforms/migratiegids/instelling/period_van_bestaan"},
        "organisatie": {
            "@value": "<p>De Centrale Stichting Landbouw Emigratie werd opgericht op 15 juni 1946 ...</p>",
            "@type": "http://www.w3.org/1999/02/22-rdf-syntax-ns#HTML"
        },
    "@type": "http://resources.huygens.knaw.nl/ingforms/migratiegids/instelling",
    "@id": "http://resource.huygens.knaw.nl/ingforms/migratiegids/instelling/01Centrale Stichting Landbouw Emigratie",
    "@context": {
      "land": "http://resources.huygens.knaw.nl/instelling/land",
        "periode_van_bestaan": "http://resources.huygens.knaw.nl/instelling/periode_van_bestaan",
        "land_herkomst": "http://resources.huygens.knaw.nl/instelling/land_herkomst",
        "typering_instelling": "http://resources.huygens.knaw.nl/instelling/typering_instelling",
        "indices_toegang_link": "http://resources.huygens.knaw.nl/instelling/indices_toegang_link",
      "naam_archiefvormer": "http://resources.huygens.knaw.nl/instelling/naam_archiefvormer",
      "organisatie": "http://resources.huygens.knaw.nl/instelling/organisatie"
    }
}
```

_output_

```
[
  {
    "@id": "http://resource.huygens.knaw.nl/ingforms/migratiegids/instelling/01Centrale Stichting Landbouw Emigratie",
    "@type": [
      "http://resources.huygens.knaw.nl/ingforms/migratiegids/instelling"
    ],
    "http://resources.huygens.knaw.nl/instelling/land_herkomst": [
      {
        "@type": [
          "http://resource.huygens.knaw.nl/ingforms/migratiegids/instelling/land_herkomst"
        ],
        "http://resources.huygens.knaw.nl/instelling/land": [
          {
            "@type": "http://resource.huygens.knaw.nl/ingforms/migratiegids/instelling/land",
            "@value": "nederland"
          }
        ]
      }
    ],
    "http://resources.huygens.knaw.nl/instelling/naam_archiefvormer": [
      {
        "@value": "Centrale Stichting Landbouw Emigratie"
      }
    ],
    "http://resources.huygens.knaw.nl/instelling/organisatie": [
      {
        "@type": "http://www.w3.org/1999/02/22-rdf-syntax-ns#HTML",
        "@value": "<p>De Centrale Stichting Landbouw Emigratie werd opgericht op 15 juni 1946 ...</p>"
      }
    ],
    "http://resources.huygens.knaw.nl/instelling/periode_van_bestaan": [
      {
        "@type": [
          "http://resource.huygens.knaw.nl/ingforms/migratiegids/instelling/period_van_bestaan"
        ]
      }
    ]
  }
]```

[jauco]
de key "end" staat niet in je context en wordt dus weggegooid uit de json.

Als oplossing werden end en begin apart aangegeven, maar er waren nog meer complicaties.

__@context__:

Veel objecten hebben geen (goed) type bij import, en worden weergegeven als 'unknown'. Bij alle herzieningen van de code blijkt @type weggevallen uit de declaratie van de objecten; dat is  weer toegevoegd.


[rik]
Ik heb er nog s over nagedacht, maar ik denk dat het probleem nog anders zit. De output is nu al een aantal keren nogal fundamenteel herzien. Het probleem zit nu niet zozeer in de aparte json files, die allemaal een eigen context hebben; dus dat moet goed gaan.

Het probleem zit in de output in de enkele file, die alles achterelkaar plakt. Sinds de laatste wijziging, is de context platgeslagen, want een array met verschillende types begrijpt de parser niet. Dan krijg je wel mogelijke duplicatie in de @context declaratie. Zo komt bijvoorbeeld periode in bijna alle types (instelling, persoon etc) voor en daarmee ook in alle @contexts, want dat zijn de schema’s waarop dit is gebaseerd.

Op zichzelf maakt het niet zoveel uit of een entity in de uiteindelijke representatie in Timbuctoo wordt geresolved naar <…>/persoon/begin of <…>/instelling/begin, maar in de objecten staat in het ene geval @type:<…>/persoon/begin en het andere @type:<…>/instelling/begin.

Vraag 1: kan de parser die je in Timbuctoo gebruikt daarmee omgaan?
Vraag 2: zo nee, dan zie ik eigenlijk maar 1 oplossing -  het aangeven van namespaces in ‘veld’ namen. Dan wordt het dus persoon.begin of persoon_begin (en instelling_begin), welke heeft dan de voorkeur?
Een alternatief zou nog zijn de nu enkele file migratiegids.jsonld op te delen in verschillende files waarin telkens slechts 1 type voorkomt (dus alle persoon en alle instelling objecten bij elkaar)

het moet een generieke oplossing zijn, want alleen dan kan een hele ingforms tree automatisch worden geconverteerd

[martijn] Voor Timbuctoo maakt het alleen uit of de data valide RDF is. Dus voor json-ld geldt dat de prefixen geregistreerd zijn. Voor een andere dataset gebruik ik http://schema.org/startDate voor zowel aanstelling van een persoon aan een instituut, als voor een periode die een persoon ergens geleefd heeft.

[martijn]

Volgens mij importeert het bestand nog niet goed. Er staan nog 956 entiteiten in de import, waarvan er geen type is opgegeven. Het gaat om entiteiten met één of meerdere van de volgende properties:

```
"http://resources.huygens.knaw.nl/persoon/archieven_link"
"http://resources.huygens.knaw.nl/persoon/opmerkingen_archief"
"http://resources.huygens.knaw.nl/instelling/organisatie_link"
"http://resources.huygens.knaw.nl/persoon/opmerkingen"
"http://resources.huygens.knaw.nl/instelling/periode_van_bestaan"
"http://resources.huygens.knaw.nl/tekst/tekst"
"http://resources.huygens.knaw.nl/persoon/omvang_invnr"
"http://resources.huygens.knaw.nl/persoon/biografie_link"
"http://resources.huygens.knaw.nl/persoon/toegang"
"http://resources.huygens.knaw.nl/instelling/zuil"
"http://resources.huygens.knaw.nl/persoon/verw_wetten_link"
"http://resources.huygens.knaw.nl/persoon/kenmerk_toegang"
"http://resources.huygens.knaw.nl/tekst/titel"
"http://resources.huygens.knaw.nl/persoon/naam_varianten"
"http://resources.huygens.knaw.nl/persoon/informatiedrager"
"http://resources.huygens.knaw.nl/persoon/originele_archivalia_ander"
"http://resources.huygens.knaw.nl/instelling/typering_instelling"
"http://resources.huygens.knaw.nl/persoon/functies_link"
"http://resources.huygens.knaw.nl/persoon/biografie"
"http://resources.huygens.knaw.nl/persoon/verw_wetten"
"http://resources.huygens.knaw.nl/persoon/originele_archivalia_deze_link"
"http://resources.huygens.knaw.nl/tekst/annotatie"
"http://resources.huygens.knaw.nl/persoon/naam_archiefvormer"
"http://resources.huygens.knaw.nl/persoon/originele_archivalia_deze"
"http://resources.huygens.knaw.nl/persoon/seriele_bescheiden"
"http://resources.huygens.knaw.nl/persoon/archieven"
"http://resources.huygens.knaw.nl/instelling/organisatie"
"http://resources.huygens.knaw.nl/persoon/statistische_gegevens"
"http://resources.huygens.knaw.nl/persoon/periode_archief"
"http://resources.huygens.knaw.nl/persoon/indices_toegang"
"http://resources.huygens.knaw.nl/persoon/functies"
"http://resources.huygens.knaw.nl/persoon/andere_archiefvormers_link"
"http://resources.huygens.knaw.nl/persoon/verw_wetten_multilateraal"
"http://resources.huygens.knaw.nl/persoon/vindplaats"
"http://resources.huygens.knaw.nl/instelling/opvolger"
"http://resources.huygens.knaw.nl/instelling/taak_link"
"http://resources.huygens.knaw.nl/instelling/taak"
"http://resources.huygens.knaw.nl/persoon/vernietigd"
"http://resources.huygens.knaw.nl/persoon/kerk"
"http://resources.huygens.knaw.nl/persoon/typering_persoon"
"http://resources.huygens.knaw.nl/persoon/seriele_bescheiden_link"
"http://resources.huygens.knaw.nl/persoon/inhoud_overig_link"
"http://resources.huygens.knaw.nl/persoon/openbaarheid"
"http://resources.huygens.knaw.nl/persoon/opmerkingen_link"
"http://resources.huygens.knaw.nl/instelling/typering_taken"
"http://resources.huygens.knaw.nl/persoon/andere_archiefvormers"
"http://resources.huygens.knaw.nl/persoon/doelgroepen"
"http://resources.huygens.knaw.nl/persoon/periode"
"http://resources.huygens.knaw.nl/persoon/verw_wetten_bilateraal"
"http://resources.huygens.knaw.nl/persoon/land_herkomst"
"http://resources.huygens.knaw.nl/persoon/originele_archivalia_ander_link"
"http://resources.huygens.knaw.nl/persoon/literatuur"
"http://resources.huygens.knaw.nl/persoon/inhoud_overig"
"http://resources.huygens.knaw.nl/persoon/bestemmings_landen"
"http://resources.huygens.knaw.nl/persoon/opmerkingen_archief_link"
"http://resources.huygens.knaw.nl/instelling/voorloper"
"http://resources.huygens.knaw.nl/persoon/verw_wetten_ned"
```

na nieuwe verschillende
Na een iets langere analyse en een frisse blik van Jauco komen er toch nog wat punten naar boven.

Er zijn nog een aantal properties werden genegeerd. Deze hebben we zichtbaar gemaakt "@vocab": "http://example.org/unknown/" toe te voegen aan het grote JSON-LDbestand.
Het gaat om:

aantekeningen in http://resource.huygens.knaw.nl/ingforms/migratiegids/migratiegids/text
datum_laatste_verandering in http://resources.huygens.knaw.nl/ingforms/migratiegids/persoon
aantekeningen in http://resources.huygens.knaw.nl/ingforms/migratiegids/instelling
datum_laatste_verandering in http://resources.huygens.knaw.nl/ingforms/migratiegids/instelling
anno in een onbekend type
Verder vonden we nog een aantal properties van een onbekende typen:
http://resources.huygens.knaw.nl/tekstannotatie/ankernaam
http://resources.huygens.knaw.nl/tekstannotatie/annotatie_tekst
Ik hoop dat je hier nog iets mee kan.

[marijke]
Het veld aantekeningen moet wel meegenomen worden, hier staan vaak verdere verwijzingen voor de gebruiker in, of een verantwoording hoe een 'lemma' geinterpreteerd moet worden.

[rik]
Ok, duidelijk. De laatst gewijzigd property ook meenemen? AL is dat niet meer echt ‘waar’ natuurlijk, behlave inhoudelijk.

Die ankers zijn van de toelichtende teksten (verwijzen nl naar noten). Zullen we die maar laten vervallen in de doorzoekbare timbuctooversie van de  gids?

[rik]

Hoi Martijn,

Ik heb

	•	aantekeningen in http://resource.huygens.knaw.nl/ingforms/migratiegids/migratiegids/text
	•	datum_laatste_verandering in http://resources.huygens.knaw.nl/ingforms/migratiegids/persoon
	•	aantekeningen in http://resources.huygens.knaw.nl/ingforms/migratiegids/instelling
	•	datum_laatste_verandering in http://resources.huygens.knaw.nl/ingforms/migratiegids/instelling
toegevoegd; die maakten geen deel uit van de ingforms schemas, maar waren default velden

	•	http://resources.huygens.knaw.nl/tekstannotatie/ankernaam
	•	http://resources.huygens.knaw.nl/tekstannotatie/annotatie_tekst
	•
kwamen voor in de inleidende  teksten en bijlagen; die heb ik er nu uit de geconverteerde bestanden gefilterd omdat ze niet bij de dataset zelf horen.

Hopelijk zijn dan nu ook deze problemen eruit

[martijn]
Deze gaan nu goed
aantekeningen in http://resource.huygens.knaw.nl/ingforms/migratiegids/migratiegids/text
datum_laatste_verandering in http://resources.huygens.knaw.nl/ingforms/migratiegids/persoon
aantekeningen in http://resources.huygens.knaw.nl/ingforms/migratiegids/instelling
datum_laatste_verandering in http://resources.huygens.knaw.nl/ingforms/migratiegids/instelling
Ik zie nog ongeveer 600 entiteiten (na toevoeging van "@vocab" aan de context. Ze hebben de volgende properties:
ankernaam: http://resources.huygens.knaw.nl/tekstannotatie/ankernaam
annotatie_tekst: http://resources.huygens.knaw.nl/tekstannotatie/annotatie_tekst
anno: <geen uri>



[conversiecode niet identiek voor afzonderlijke files en afzonderlijke bestanden, daarom nog een stap nodig

nu wel bijlagen en inleidingen verwijderd]
