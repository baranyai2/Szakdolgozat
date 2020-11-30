Játék rövid leírása

Az OpenTTD játék fő célja egy szállító cég felépítése, ami a lehető legnagyobb profitot képes generálni.
Ezt különböző áruk, anyagok elszállításával a különböző fuvarozási lehetőségek (buszok, vonatok, repülők, hajók stb.) segítségének optimális alkalmazásával tudunk elérni.
Ezeket az erőforrásokat általában egyik pontból a másikba kell eljuttatni, a játék térképén a megfelelő infrastruktúra megépítésével.
Különböző ipari épületek találhatóak meg szétszórva a pályán melyek mindannyian különböző erőforrásokat termelnek és/vagy fogadnak el.
Ezek mellett megtalálhatóak városok is, amik között pedig utasokat vagy levelet tudunk szállítani.

Egy új játék elején a játékos egy bizonyos összegű banki kölcsönnel kezd, amit befektethet az ideális cég megalapozásába, azonban ha túl hamar elkölti azt, 
vagy nem sikerül elegendő profitot generálni a cég csődbe mehet így elveszítheti a játékot. Ez elég könnyen előfordulhat,
mivel a megépített utak vagy síneknek a fenntartásáért és a megvásárolt járművek üzemben tartásáért is folyamatosan fizetni kell,
valamint a kölcsönt is részletesen vissza kell fizetnie a játékosnak.

Egyjátékos módban lehetőség van gépi ellenféllel együtt játszani. Ez jelenti azt, hogy miközben mi tudjuk építeni a saját kereskedelmi infrastruktúránkat, 
a gép egy másik cég neve alatt, ugyan azon a térképen egyidejűleg építi a sajátját. A játékot lehetőség van többjátékos módban is játszani, 
akár gépi ellenfelek hozzáadásával is ahol a játékosok a gépi ellenfeles játékhoz hasonlóan egyidejűleg férnek hozzá a játék rendszereihez.
Minden játékos egy saját céget tud kezelni, de akár arra is van lehetőség, hogy egy céget több játékos is tudjon kezelni.
A cégek közötti versengésből következhet, hogy egy cég részesedést tud vásárolni egy másikból, vagy akár teljesen fel is vásárolhatja azt.

A játékban vannak véletlenszerű események, változások a játékmenet során. Ilyenek például az erőforrások árfolyamának, elfogadásának változása, balesetek,
a különböző járművek elöregedései, újabb, gyorsabbak behozatala. Emellett vannak a játékban támogatások is, ezek is véletlenszerű események, amelyek következménye,
hogyha a bizonyos időn belül kiépítjük az adott hálózatot amire a támogatást meghirdették plusz jövedelemhez juthatunk. 
A játékban minden településnek van önkormányzata, és minden gyár/feldolgozó üzem egy adott önkormányzathoz tartozik. 
Az önkormányzatoknak lehetősége van arra, hogy megtiltsák az építkezést a területükön belül.
Ezt úgy érhetjük el, hogy a már meglévő úthálózatokat túlságosan átépítettük, leromboltunk erdőket a környéken, túlságosan átalakítottuk a környező területet stb. 
Ugyanakkor lehetőség van a városokon belül reklámozni is  a cégünket, amivel több utast vonzhatunk a vasútállomásinkra vagy buszmegállóinkba.

Ha nagyon le szeretnénk egyszerűsíteni a játék modelljét, a cél az, hogy minél kevesebb pénz befektetésével a legnagyobb profitot tudjuk generálni.
Minden árunak van megadott értéke, hogy mennyit ér a leszállítása után. Ez az érték annál nagyobb, minél kevesebb időt töltött szállításban.
Ilyenkor természetesen érdemes figyelembe venni, hogy milyen távolságon szállítjuk az adott árut és milyen eszközzel.
Például egy vasútvonal kiépítése költségesebb lesz mint egy úthálózaté, azonban a vonatok gyorsabban képesek egyszerre több árut elszállítani,
mint a teherautók ugyan azon a távolságon.

Létező implementációk összehasonlítása

Az OpenTTD játék alapvető verziójában nem található előre beépített gépi ellenfél, minden hasonló implementációt a játék közössége hozott létre.
Ezek többsége a játék fórumán elérhető, letölthető és követhető. Az évek során elég sok implementáció készült a játékhoz,
ezek közül csak a kettő legáltalánosabbat emelném ki leginkább.

Az egyik legelterjedtebb és talán legáltalánosabb AI az „AdmiralAI” nevezetű. Ahogy a fórumon megtalálható rövid összefoglalója is mondja:
„Az AdmiralAI az API lehető legtöbb funkcióját próbálja implementálni. Jelenleg a közúti járműveket, vonatokat és repülőket támogatja.
Az egyik fő cél egy olyan AI készítése, ami ellen szórakoztató a játék. Ezt elérve azáltal, hogy minél többféle szállítási módszert alkalmaz.” 
Emellett az AI támogat különböző kiegészítő script-eket is, amit szintén a közösség készített a játékhoz.
A játékban kipróbálva a rövid összefoglalót csak megerősíteni tudom. 
Az AI teszi a dolgát a pálya több területén különböző iparágakban sikeresen épít, figyelembe veszi a játékos terjeszkedéseit is.

Egy másik szintén gyakorian használt AI az ún. „AIAI”. Az AdmiralAI-hoz hasonlóan ez is képes a hajókon kívül minden más szállítási módszert támogat.
A készítő leírása szerint, a cél egy olyan AI készítése volt, ami ellen kihívó játszani, ugyanakkor, szépen kinéző infrastruktúrákat épít.
Valamint ez az AI is támogat különböző scripteket, amikkel érdekesebbé tehető a játékmenet.

A játék saját wiki oldalán található egy összehasonlítás több a közösség által fejlesztett AI-ok összehasonlításáról
(Többnyire csak a szállítási módszerek valamint a játékmentés támogatásának szempontjából.)

Az említett felsorolás és összehasonlítás elérhető itt:
https://wiki.openttd.org/en/Community/AI/Comparison%20of%20AIs

OpenTTD kiterjesztési lehetőségei


Az OpenTTD nyílt forráskódúságából kifolyólag, a játék minden fájlja elérhető és módosítató. Ez megtalálható a játék saját github repositoryjában.
Maga a játék leginkább a C, C++ nyelveken van írva. A játékhoz lehetőség van scripteket írni, amik leginkább a játék szabályrendszerét változtatják meg,
új iparágakat adnak hozzá meglévő értékeken változtatnak stb. Ami számunkra fontosabb jelen helyzetben az a gépi ellenfelek írásához szükséges információk.
Hasonló módon lehetőség van AI-okat is készíteni a játékhoz. Ennek segítségére a játékhoz készült egy API ami az ún. NoAI keretrendszerben található meg.
Ennek a keretrendszernek és API-nak a segítségével érhetjük el a játék elemeit aminek a segítségével el tudjuk készíteni a saját gépi ellenfelünket. 

Ajátékhoz a kiegészítő kódokat a Squirrel nyelven kell megírni. A squirrel nyelv szintaktikailag sokban hasonlít a C++-hoz.
A nyelv kifejezetten videójátékokhoz készült mint kiegészítő script, magában egy magasszintű imperatív, objektum orientált nyelv.

Az OpenTTD saját wiki oldalán elérhető egy rövidebb segítő dokumentum az AI írás elkezdéséhez.
Itt természetesen szükségünk van arra hogy a Squirrel-el írt scripteket le tudjuk fordítani és futtatni. 
Ugyanezen az oldalon megtalálható egy nagyon minimális AI is, ami önmagában nem is csinál sok mindent azon kívül hogy létrehoz egy céget,
de ebből már könnyebben elkezdhető az AI fejlesztése, de természetesen teljesen 0-ról is lehet kezdeni a folyamatot.

OpenTTD github: https://github.com/OpenTTD/OpenTTD
API dokumentáció: https://docs.openttd.org/ai-api/
Squirrel nyelv: http://squirrel-lang.org/
Wiki oldal: https://wiki.openttd.org/en/Development/Script/Introduction
