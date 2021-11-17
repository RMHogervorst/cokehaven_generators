## data generator voor cokehaven


in 2000 0.25 * 160.000 kilo cocaine per jaar voor rotterdam. 40.000kg
(het past in principe in 2 zeecontainers)  (maar in 2021 werd al 62.000kg gevonden en jaar nog niet voorbij)
assumpties:
* Maar mensen moeten het uithalen, dus ze kunnen niet meer dan 10 kilo per persoon.
* max 3 mensen ma 30 kg per lading? en een paar cases van meer die op andere manier uit lading moet worden gehaald.
* politie en justitie overdrijven graag, dus eigenlijke getal 30.000kg
* op straat 50 euro / gram. minstens 50.000 euro per kilo (want versnijden)
* laten we zeggen 4 miljoen containers invoer per jaar. 
* fruit specifiek 5% van invoer.
* fruit hoger risico (want sneller en zelfde landen)
* gemiddeld 10 kg in een container, dan heb je 3000 containers op de 4 miljoen (0.075 %) min 2 kg - max 40, meeste 5, increment van .5
(handiger om dit als norm distr, of beta te doen)
zoeiets mean(round((rbeta(1000, 31,4) * 10) + (rnorm(1000, 1,3))) )

wat als ik een proability opbouw adhv 

* random baseline getal (het kan in elke container zitten)
* fruit hoger
* zuid america hoger (
Argentinië, Bolivia, Brazilië, Chili, Colombia,Ecuador, Guyana, Paraguay, Peru, Suriname, Uruguay, Venezuela)
* time of year? na maart meeste oogst, april binne, mei klaar voor verkoop? piek in mei?
* maandag ietsje meer. 

## Proces
1. genereer eerst het land van herkomst, datum (1 van de data tussen januari -december), lading voor 4 miljoen records
2. geneer probabiilties random, fruit, zuid america, time of year

Politie/justie/douane/KMar kiezen 0.5% van de containers voor een scan, daarvan 16% open gemaakt. 
assumpties:
* als gescanned dan 90% kans op vinden coke als het er is.
(we geven ze hier beboorlijk benefit of doubt, want controle op uitgaand is ernauwelijks volgens rapproten. )

# vergelijk met 
* profiling methode: Peru, Bolivia, Colombia. 
* vergelijk met willekeurige steekproef van containers: 0.075


of generatie volgens 3 methoden:

- ladingscript worden de drugs tussen of ‘onder’ de lading verstopt. Vooral 
fruit en bevroren vis lenen zich hiervoor. ook bulk. (maar we bespreken alleen continaers. )
-  containerscript worden de drugs verborgen in de container
- scheepsscript: worden drugs verstopt op het schip (bijvoorbeeld in het ruim 
of de ontluchtingspijp) of aan de buitenkant van het schip


----
De twee meest voorkomende internationaal gestandaardiseerde containertypes zijn 20 voet en 40 voet (20ft en 40ft respectievelijk).


# Wat zit er in de containers:
koel en vries:
Fruit
Vlees en vleeswaren
Vis
Niet-voedsel
Overig voedsel
Groente

machines
overige
landbouwen levensmiddelen
chemie
bouwmaterialen
olieproducten
hout en textiel
afval

?elektronica?

# waar komt het vandaan?
Ik bepaal, met natte vinger dat 100% van de containers bestaan uit:

* 5% VS, Canada, Mexico
* 3% midden america 
* 11% vanuit zuid america

* 4% uit Noorwegen, UK, Zuid Afrika, Kenia, Tanzania, Nigeria, Egypte, Namibie

* 77 % komt uit azie.
** China 51%
** 11% India, Vietnam, Indonesie Banglasheds
** Japan 9 % (vooral elektronica)
** Zuid Korea 6% (vooral elektronia)

## API

API die je beoordeeld op hoeveel kilo je hebt gepakt.
Je mag maar 1000 cases kiezen uit je testset? (een x uit zoveel) daarna krijg je
te horen hoeveel kilo je hebt gepakt en hoeeel de straatwaarde is.
je geeft dus de container ids op die je wilt controleren, dan is 90% kans dat je
daadwerklijk vind als het er is. dan keer 50.000 voor straatwaarde.


>  De havenpolitie, {team naam}  HARC team (Hit and Run Cargoteam) en Doane in de haven van Rotterdam hebben dit weekend een partij van maar liefst {kilo} gevonden
met een straatwaarde van een slordige {kilo * 50.000} De drugs, die zoals altijd direct werden vernietigd, zaten onder andere verstopt tussen {iets uit 1 van de containers}




Van der Chijs spreekt van ‘dweilen met de kraan open’. De grootste partij van 2021, én vele jaren daarvoor, dook afgelopen weekend op en woog maar liefst 4178 kilo. De vangst had een straatwaarde van een slordige 313 miljoen euro. De drugs, die zoals altijd direct werden vernietigd, zaten verstopt tussen zakken met soja.

> opnieuw is een grote lading drugs gevonden in een container


als onderozhct door welke hond, laika, luna, loeki,loki, luther, lummel
tussenstop ergens? 1 grotere kans , tussenstop op côte d'ivoir, côte d'azur, côte de coke
welke schepen
gekoeld nog toevoegen
eigenaar goederen R. Taghi, P. Haas, R. Kapje, GV. Reus, 
van wie is de container (3 grote partijen, geen effect)
wie is de ontvanger (s. klaas en k. erstman groter risico)
vlag waaronder schip vaart
zegel verbroken
kleur van container
