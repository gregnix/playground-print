poppler
https://poppler.freedesktop.org/
```
Poppler is a PDF rendering library based on the xpdf-3.0 code base.

https://www.mankier.com/package/poppler-utils
General Commands
pdfattach 	Portable Document Format (PDF) document embedded file creator (version 3.03)
pdfdetach 	Portable Document Format (PDF) document embedded file extractor (version 3.03)
pdffonts 	Portable Document Format (PDF) font analyzer (version 3.03)
pdfimages 	Portable Document Format (PDF) image extractor (version 3.03)
pdfinfo 	Portable Document Format (PDF) document information extractor (version 3.03)
pdfseparate 	Portable Document Format (PDF) page extractor
pdfsig 	Portable Document Format (PDF) digital signatures tool
pdftocairo 	Portable Document Format (PDF) to PNG/JPEG/TIFF/PDF/PS/EPS/SVG using cairo
pdftohtml 	program to convert PDF files into HTML, XML and PNG images
pdftoppm 	Portable Document Format (PDF) to Portable Pixmap (PPM) converter (version 3.03)
pdftops 	Portable Document Format (PDF) to PostScript converter (version 3.03)
pdftotext 	Portable Document Format (PDF) to text converter (version 3.03)
pdfunite 	Portable Document Format (PDF) page merger
```

+ https://manpages.ubuntu.com/manpages/trusty/man1/pdftocairo.1.html

+ "upper" (DMBIN_UPPER): Bezieht sich in der Regel auf die oberste Papierzuführung oder das oberste Papierfach eines Druckers. Wenn ein Drucker über mehrere Papierfächer verfügt, ist dies das am höchsten gelegene.
+ "lower" (DMBIN_LOWER): Bezeichnet die untere Papierzuführung oder das untere Papierfach. In einem System mit mehreren Papierfächern wäre dies das unterste Fach.
+ "middle" (DMBIN_MIDDLE): Für Drucker, die über drei oder mehr Papierfächer verfügen, bezieht sich dies auf das oder die in der Mitte befindlichen Fächer.
* "manual" (DMBIN_MANUAL): Manuelle Papierzuführung, oft verwendet für spezielle Medien oder Einzelblatteinzug.
* "envelope" (DMBIN_ENVELOPE): Spezielles Fach oder Zuführung für Umschläge.
* "envmanual" (DMBIN_ENVMANUAL): Manuelle Zuführung speziell für Umschläge.
+ "auto" (DMBIN_AUTO): Automatische Auswahl der Papierquelle durch den Drucker oder das Treibersystem.

 'source': Choose the paper source. 
 
 The value is one of: 'upper', 'onlyone', 'lower', 'middle', 'manual', 'envelope', 'envmanual', 'auto', 'tractor', 'smallfmt', 'largefmt', 'largecapacity', 'formsource' or an integer constant for printer specific sources.

* 'duplex': Set the duplex mode. One of: 'simplex', 'horizontal', 'vertical'.

```
pdftocairo output.pdf -print -printer "laserdrucker" -printopt "source"="upper"
pdftocairo output.pdf -print -printer "laserdrucker" -printopt "source"="lower"
pdftocairo output.pdf -print -printer "laserdrucker" -printopt "source"="middle"
pdftocairo output.pdf -print -printer "laserdrucker" -printopt "source"="manual
```


```
set pdfPrint [file join $libdir bin pdftocairo.exe]
exec $::pdfPrint $pdffile -q -noshrink -print -printer $printer
```
