## Coke haven
In deze opdracht probeer je de autoriteiten te helpen hun scanner op de haven zo goed mogelijk te gebruiken.

## Waar komt de data vandaan?
Na encrochat, ennetcom en andere PgP providers te hebben gehacked in het verleden
kan de Landelijke Eenheid van de politie eindelijk toegeven dat er inderdaad weer
een berichtenservice is gekraakt. Een jaar lang kon de politie meelezen met criminelen. In deze berichtenservice werden verschillende excel^1 bestanden rond gestuurd waarin werd aangegeven in welke container drugs wordt vervoerd.
Team High Tech Crime heeft in samenwerking met het havenbedrijf
Rotterdam de verschillende excelbestanden samengegevoegd met alle containerdata die we wisten voor containers die aankwamen op Haven Rotterdam^2 tussen 1 januari 2019 en 31 december 2019. Hiermee zijn we eindelijk in staat om onze algoritmen
te testen op een 'ground truth'.  

De data is gesplitst in een trainingset en een testset. Gebruik het trainingset om je model te trainen. Van het testset (random gekozen uit alle data) weet je niet 
welke containers cocaine bevatten. 

## De opdracht
De haven kan maar 0.05% can de containers checken. Dat betekent in dit geval dat er maar 400 containers getest kunnen worden. De opdracht is dus:

* **geef de 400 containers uit het testset op die volgens jouw model de meeste kans hebben op cocaine.** 

In tegenstelling tot kaggle competities geef je niet alle regels uit het 
testset terug, maar alleen de containers waarvan jij denkt dat de kans het hoogst is op cocaine. 

De beoordeling is ook niet eerlijk, je wordt beoordeeld op de totale hoeveelheid cocaine gevonden. 

Het antwoordformaat ziet er zo uit (een csv van 1 kolom met kolomnaam 'containerid' en in totaal 401 regels lang:

```csv
containerid
gcn79000020
gcn79000028
etc...
```
upload je csv met de top 400 containers en je team naam naar [webadres nog in te vullen op dag zelf]

## Aanwijzingen
Je kunt deze opdracht op verschillende manieren benaderen: 
* een binaire classificatie probleem; wel of geen cocaine in de lading verstopt. 
* of een regressie aanpak: hoeveel cocaine is verstopt in de lading.
* een 'anomaly detection' probleem, welke container wijkt af?

Dit is een ontzettend 'unbalanced' dataset, het loont waarschijnlijk om de dominante categorie (geen verborgen drugs) te downsamplen.

Er is een starter script voor R en python bijgesloten. 




# Notities
^1: Excel 2003 natuurlijk
^2: Dit hele verhaal is een leugen, dit dataset is gesimuleerd op basis van openbare beschikbare cijfers over haven Rotterdam, CBS, politie rapporten en natte vinger werk. 
