cv.pdf: cv.dvi
	dvipdfm -o $@ $<

cv.dvi: cv.tex cv.bib cv.bst
	latex cv
	bibtex bu1
	bibtex bu2
	latex cv
	latex cv
	latex cv

clobber: clean
	rm -rf cv.pdf *~

clean:
	rm -rf bu* *.aux *.bbl *.blg *.lof *.log *.lot *.out *.toc *.dvi
