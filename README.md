# SnellerDanJeBuren

![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/rink-turksma/SnellerDanJeBuren/total)


SnellerDanJeBuren is een Windows-applicatie waarmee je laadpalen in jouw buurt kunt selecteren.  
Op basis van een door jou ingesteld interval controleert de app of er een laadpaal vrij is en toont een pop-up zodra dat zo is.

<img width="879" height="285" alt="image" src="https://github.com/user-attachments/assets/583db29d-ceb5-4dd5-bd4c-a7e3823daa03" />

---

## Installatie

1. Ga naar de **Releases**-pagina en download de laatste release (MSI-bestand):  
   https://github.com/rink-turksma/SnellerDanJeBuren/releases

2. Klik met de **rechtermuisknop** op het MSI-bestand en kies **Eigenschappen** (*Properties*).

3. Als onderaan in het tabblad **Algemeen** (*General*) de optie **Blokkering opheffen** (*Unblock*) zichtbaar is, vink deze aan en klik op **OK**.

4. Installeer nu de applicatie door het MSI-bestand uit te voeren.

Na de installatie vind je **SnellerDanJeBuren** in het **Startmenu**.

---

## Eerste setup (TomTom Developer account)

Open eerst het **Setup-menu**. Daar zie je de instructies om een gratis **TomTom Developer account** aan te maken en een API-sleutel te verkrijgen.

<img width="869" height="297" alt="image" src="https://github.com/user-attachments/assets/40d68630-19fe-4915-be33-ce70e7586cfd" />

Als je dit hebt gedaan, klik je op **‘Zoek en voeg laadpaal toe’**.

<img width="877" height="287" alt="image" src="https://github.com/user-attachments/assets/d92f16d3-1c00-409d-aa66-4314ed66516e" />

Vul de **plaatsnaam** en de **straatnaam** in.

<img width="876" height="279" alt="image" src="https://github.com/user-attachments/assets/915d01e4-a190-45d5-ad18-809badd6e5dd" />

---

## Laadpalen beheren

Als je een laadpaal uit de lijst wilt verwijderen:

1. Selecteer de laadpaal in de lijst.
2. Klik op **Verwijderen**.

<img width="879" height="285" alt="image" src="https://github.com/user-attachments/assets/313f38e1-2d6d-401a-92f7-7d1dc2a0fc31" />

---

## Testen

Gebruik de knop **Test** om te controleren of alles werkt.  
De testfunctie toont altijd output – ook als er géén laadpaal vrij is.

<img width="292" height="159" alt="image" src="https://github.com/user-attachments/assets/4a7b922d-9696-4f80-923d-a65df2ee8bb3" />

In dit voorbeeld is er wél een paal vrij, daarom toont het systeem alleen de vrije laadpaal:

<img width="879" height="285" alt="image" src="https://github.com/user-attachments/assets/13cff447-da58-49cf-b15b-35371715a426" />

---

## Automatisch controleren (taak aanmaken)

1. Kies een **interval in minuten**.
2. Klik op **Start**.

<img width="879" height="285" alt="image" src="https://github.com/user-attachments/assets/a18a55eb-a35b-4b84-95a8-3b5627b71fd7" />

Als de taak actief is, zie je de melding **“Taak actief!”**.  
Vanaf dat moment controleert het systeem iedere X aantal minuten of er een laadpaal vrij is, totdat je op **Stop** klikt.

Je kunt de applicatie gerust minimaliseren of sluiten:  
de taak blijft actief totdat je expliciet op **Stop** hebt gedrukt.
