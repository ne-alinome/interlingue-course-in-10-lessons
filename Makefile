# Makefile of _Interlingue Course in 10 Lessons_

# By Marcos Cruz (programandala.net)

# Last modified 202008281724
# See change log at the end of the file

# ==============================================================
# Requirements {{{1

# Asciidoctor (by Dan Allen, Sarah White et al.)
#   http://asciidoctor.org

# Asciidoctor EPUB3 (by Dan Allen and Sarah White)
#   http://github.com/asciidoctor/asciidoctor-epub3

# Asciidoctor PDF (by Dan Allen and Sarah White)
#   http://github.com/asciidoctor/asciidoctor-pdf

# dbtoepub
#   http://docbook.sourceforge.net/release/xsl/current/epub/README

# ImageMagick (by ImageMagick Studio LCC)
#   http://imagemagick.org

# img2pdf (by Johannes 'josch' Schauer)
#   https://gitlab.mister-muffin.de/josch/img2pdf

# Pandoc (by John MaFarlane)
#   http://pandoc.org

# xsltproc
#   http://xmlsoft.org/xslt/xsltproc.html

# ==============================================================
# Config {{{1

VPATH=./src:./target

book=interlingue_course_in_10_lessons
cover=$(book)_cover
cover_author="A. Z. Ramstedt\nDave MacLeod"
cover_title="Interlingue\nCourse\nin 10 Lessons"
lang="en"
editor="Marcos Cruz (programandala.net)"
publisher="ne alinome"
description="Course of the Interlingue international auxiliary language"

# ==============================================================
# Interface {{{1

.PHONY: default
default: epuba pdf thumb

.PHONY: all
all: dbk epub html odt pdf thumb

.PHONY: epub
epub: epuba epubd epubp epubx

.PHONY: epuba
epuba: target/$(book).adoc.epub

.PHONY: epubd
epubd: target/$(book).adoc.dbk.dbtoepub.epub

.PHONY: epubp
epubp: target/$(book).adoc.dbk.pandoc.epub

.PHONY: epubx
epubx: target/$(book).adoc.dbk.xsltproc.epub

.PHONY: html
html: htmlap htmlas htmlpb htmlpc

.PHONY: htmlap
htmlap: target/$(book).adoc._plain.html

.PHONY: htmlas
htmlas: target/$(book).adoc._stylish.html

.PHONY: htmlpb
htmlpb: target/$(book).adoc.dbk.pandoc._body.html

.PHONY: htmlpc
htmlpc: target/$(book).adoc.dbk.pandoc._complete.html

.PHONY: odt
odt: target/$(book).adoc.dbk.pandoc.odt

.PHONY: pdf
pdf: pdfa4 pdfl

.PHONY: pdfa4
pdfa4: target/$(book).adoc._a4.pdf

.PHONY: pdfl
pdfl: target/$(book).adoc._letter.pdf

.PHONY: dbk
dbk: target/$(book).adoc.dbk

.PHONY: cover
cover: target/$(cover).jpg

.PHONY: thumb
thumb: target/$(cover)_thumb.jpg

.PHONY: clean
clean:
	rm -fr target/* tmp/*

.PHONY: cleancover
cleancover:
	rm -f target/*.jpg tmp/*.png

# ==============================================================
# Convert Asciidoctor to EPUB {{{1

target/%.adoc.epub: src/%.adoc target/$(cover).jpg
	asciidoctor-epub3 \
		--out-file=$@ $<

# ==============================================================
# Convert Asciidoctor to DocBook {{{1

target/%.adoc.dbk: src/%.adoc
	asciidoctor --backend=docbook5 --out-file=$@ $<

# ==============================================================
# Convert Asciidoctor to HTML {{{1

# ----------------------------------------------
# With styles included {{{2

target/%.adoc._stylish.html: src/%.adoc
	asciidoctor --backend=html --out-file=$@ $<

# ----------------------------------------------
# Plain, without styles included {{{2

target/%.adoc._plain.html: src/%.adoc
	asciidoctor \
		--backend=html \
		--attribute stylesheet=unexistent.css \
		--out-file=$@ $<

# ==============================================================
# Convert Asciidoctor to PDF {{{1

target/%.adoc._a4.pdf: src/%.adoc tmp/$(cover).pdf
	asciidoctor-pdf \
		--out-file=$@ $<

target/%.adoc._letter.pdf: src/%.adoc tmp/$(cover).pdf
	asciidoctor-pdf \
		--attribute pdf-page-size=letter \
		--out-file=$@ $<

# ==============================================================
# Convert DocBook to EPUB {{{1

# ------------------------------------------------
# With dbtoepub {{{2

target/$(book).adoc.dbk.dbtoepub.epub: \
	target/$(book).adoc.dbk \
	src/$(book)-docinfo.xml
	dbtoepub \
		--output $@ $<

# ------------------------------------------------
# With pandoc {{{2

target/$(book).adoc.dbk.pandoc.epub: \
	target/$(book).adoc.dbk \
	src/$(book)-docinfo.xml \
	src/pandoc_epub_template.txt \
	src/pandoc_epub_stylesheet.css \
	target/$(cover).jpg
	pandoc \
		--from docbook \
		--to epub3 \
		--template=src/pandoc_epub_template.txt \
		--css=src/pandoc_epub_stylesheet.css \
		--variable=lang:$(lang) \
		--variable=editor:$(editor) \
		--variable=publisher:$(publisher) \
		--variable=description:$(description) \
		--epub-cover-image=target/$(cover).jpg \
		--output $@ $<

# ------------------------------------------------
# With xsltproc {{{2

target/%.adoc.dbk.xsltproc.epub: target/%.adoc.dbk
	rm -fr tmp/xsltproc/* && \
	xsltproc \
		--output tmp/xsltproc/ \
		/usr/share/xml/docbook/stylesheet/docbook-xsl/epub/docbook.xsl \
		$< && \
	echo -n application/epub+zip > tmp/xsltproc/mimetype && \
	cd tmp/xsltproc/ && \
	zip -0 -X ../../$@.zip mimetype && \
	zip -rg9 ../../$@.zip META-INF && \
	zip -rg9 ../../$@.zip OEBPS && \
	cd - && \
	mv $@.zip $@

# XXX TODO -- Find out how to pass parameters and their names, from the XLS:
#    --param epub.ncx.filename testing.ncx \

# XXX TODO -- Add the stylesheet. The XLS must be modified first,
# or the resulting XHTML must be modified at the end.
#  cp -f src/xsltproc/stylesheet.css tmp/xsltproc/OEBPS/ && \

# ==============================================================
# Convert DocBook to HTML {{{1

# ----------------------------------------------
# Body only {{{2

target/$(book).adoc.dbk.pandoc._body.html: \
	target/$(book).adoc.dbk \
	src/$(book)-docinfo.xml \
	src/pandoc_html_body_template.txt
	pandoc \
		--from docbook \
		--to html5 \
		--template=src/pandoc_html_body_template.txt \
		--variable=lang:$(lang) \
		--variable=editor:$(editor) \
		--variable=publisher:$(publisher) \
		--variable=description:$(description) \
		--output $@ $<

# ----------------------------------------------
# Complete {{{2

target/$(book).adoc.dbk.pandoc._complete.html: \
	target/$(book).adoc.dbk \
	src/$(book)-docinfo.xml \
	src/pandoc_html_complete_template.txt
	pandoc \
		--from docbook \
		--to html5 \
		--template=src/pandoc_html_complete_template.txt \
		--standalone \
		--variable=lang:$(lang) \
		--variable=editor:$(editor) \
		--variable=publisher:$(publisher) \
		--variable=description:$(description) \
		--output $@ $<

# ==============================================================
# Convert DocBook to OpenDocument {{{1

target/$(book).adoc.dbk.pandoc.odt: \
	target/$(book).adoc.dbk \
	src/$(book)-docinfo.xml \
	src/pandoc_odt_template.txt
	pandoc \
		--from docbook \
		--to odt \
		--template=src/pandoc_odt_template.txt \
		--variable=lang:$(lang) \
		--variable=editor:$(editor) \
		--variable=publisher:$(publisher) \
		--variable=description:$(description) \
		--output $@ $<

# ==============================================================
# Create the cover image {{{1

include Makefile.cover_image
# Change log {{{1

# 2019-02-18: Start.
#
# 2019-02-19: Add "it" rule for the development.
#
# 2019-03-01: Fix the rule that builds the OpenDocument. Simplify the
# interface: Make all lformats with "all".
#
# 2019-03-10: Add HTML output (several variants built with Asciidoctor and
# pandoc). Fix metadata options in pandoc commands.
#
# 2020-04-02: Replace DocBook extension "xml" with "dbk". Change the file
# naming convention: add "_" before the variant names. Create an EPUB also with
# Asciidoctor EPUB3. Update/improve the requirements list. Make only the
# recommended formats by default. Update the publisher. Add a cover image.
#
# 2020-04-06: Adjust the size and layout of the cover texts.
#
# 2020-08-28: Move the cover image rules to an independent file.
