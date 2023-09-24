qp4 to mp4 konverter howto:

1. Töltsd le a fájlokat, és csomagold ki az ffmpeg.exe-t!

2. Tedd az animációt matrix.qp4 és a hozzá való hangfájlt matrix.mp3 néven ebbe a mappába. Ha még nem futtattál PowerShell scriptet a gépen, nyiss egy PowerShell ablakot rendszergazdai jogosultsággal, és futtasd a következő parancsot:

set-executionpolicy remotesigned

Ez enegdélyezni fogja a scriptek futtatsát.



3. Futtasd a scriptet úgy, hogy jobb klikkelsz a QP4toMP4.ps1 scriptre, és Futtatás PowerShell-ben. Ez csillagászati sebességgel, qp4 frame-enként kb 1 másodpercnyi idő alatt legenerálja a matrix.mp4 videót.

Ha az audio nem mp3-ban van, szerkeszd az utolsó ffmpeg parancsot, hogy ne matrix.mp3 szerepeljen argumentumként!
Ha random hibákat kapsz, próbáld a mappát mondjuk az asztalra tenni, hogy az elérési útban ne legyen mindenféle random karakter, szóköz, meg ne legyen végtelenül hosszú.



4. Miután végeztél a konverzióval, a géped biztonsága érdekében állítsd vissza az execution policy-t az alapértelmezettre a következő paranccsal egy adminisztrátori joggal indított PowersHell abalkból:

set-executionpolicy restricted