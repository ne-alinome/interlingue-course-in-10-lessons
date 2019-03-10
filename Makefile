# Makefile of _Interlingue Course in 10 Lessons_

# By Marcos Cruz (programandala.net)

# Last modified 201903101323
# See change log at the end of the file

# ==============================================================
# Requirements

# - asciidoctor
# - asciidoctor-pdf
# - dbtoepub
# - pandoc 2.6
# - xsltproc

# ==============================================================
# Config

VPATH=./src:./target

book_basename=interlingue_course_in_10_lessons
title="Interlingue Course in 10 Lessons"
lang="en"
editor="Marcos Cruz (programandala.net)"
publisher="ne.alinome"
description=

# ==============================================================
# Interface

.PHONY: all
all: epub html odt pdf xml

.PHONY: epub
epub: epubd epubp epubx

.PHONY: epubd
epubd: target/$(book_basename).adoc.xml.dbtoepub.epub

.PHONY: epubp
epubp: target/$(book_basename).adoc.xml.pandoc.epub

.PHONY: epubx
epubx: target/$(book_basename).adoc.xml.xsltproc.epub

.PHONY: html
html: htmlap htmlas htmlpb htmlpc

.PHONY: htmlap
htmlap: target/$(book_basename).adoc.plain.html

.PHONY: htmlas
htmlas: target/$(book_basename).adoc.stylish.html

.PHONY: htmlpb
htmlpb: target/$(book_basename).adoc.xml.pandoc.body.html

.PHONY: htmlpc
htmlpc: target/$(book_basename).adoc.xml.pandoc.complete.html

.PHONY: odt
odt: target/$(book_basename).adoc.xml.pandoc.odt

.PHONY: pdf
pdf: pdfa4 pdfletter

.PHONY: pdfa4
pdfa4: target/$(book_basename).adoc.a4.pdf

.PHONY: pdfletter
pdfletter: target/$(book_basename).adoc.letter.pdf

.PHONY: xml
xml: target/$(book_basename).adoc.xml

.PHONY: it
it: epubd pdfa4

.PHONY: clean
clean:
	rm -fr target/* tmp/*

# ==============================================================
# Convert Asciidoctor to PDF

target/%.adoc.a4.pdf: src/%.adoc
	asciidoctor-pdf \
		--out-file=$@ $<

target/%.adoc.letter.pdf: src/%.adoc
	asciidoctor-pdf \
		--attribute pdf-page-size=letter \
		--out-file=$@ $<

# ==============================================================
# Convert Asciidoctor to DocBook

target/%.adoc.xml: src/%.adoc
	asciidoctor --backend=docbook5 --out-file=$@ $<

# ==============================================================
# Convert Asciidoctor to HTML

# ----------------------------------------------
# With styles included

target/%.adoc.stylish.html: src/%.adoc
	asciidoctor --backend=html --out-file=$@ $<

# ----------------------------------------------
# Plain, without styles included

target/%.adoc.plain.html: src/%.adoc
	asciidoctor \
		--backend=html \
		--attribute stylesheet=unexistent.css \
		--out-file=$@ $<

# ==============================================================
# Convert DocBook to HTML

# ----------------------------------------------
# Body only

target/$(book_basename).adoc.xml.pandoc.body.html: \
	target/$(book_basename).adoc.xml \
	src/$(book_basename)-docinfo.xml \
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
# Complete

target/$(book_basename).adoc.xml.pandoc.complete.html: \
	target/$(book_basename).adoc.xml \
	src/$(book_basename)-docinfo.xml \
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
# Convert DocBook to EPUB

# ------------------------------------------------
# With dbtoepub

target/$(book_basename).adoc.xml.dbtoepub.epub: \
	target/$(book_basename).adoc.xml \
	src/$(book_basename)-docinfo.xml
	dbtoepub \
		--output $@ $<

# ------------------------------------------------
# With pandoc

target/$(book_basename).adoc.xml.pandoc.epub: \
	target/$(book_basename).adoc.xml \
	src/$(book_basename)-docinfo.xml \
	src/pandoc_epub_template.txt \
	src/pandoc_epub_stylesheet.css
	pandoc \
		--from docbook \
		--to epub3 \
		--template=src/pandoc_epub_template.txt \
		--css=src/pandoc_epub_stylesheet.css \
		--variable=lang:$(lang) \
		--variable=editor:$(editor) \
		--variable=publisher:$(publisher) \
		--variable=description:$(description) \
		--output $@ $<

# ------------------------------------------------
# With xsltproc

target/%.adoc.xml.xsltproc.epub: target/%.adoc.xml
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
# Convert DocBook to OpenDocument

target/$(book_basename).adoc.xml.pandoc.odt: \
	target/$(book_basename).adoc.xml \
	src/$(book_basename)-docinfo.xml \
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
# Change log

# 2019-02-18: Start.
#
# 2019-02-19: Add "it" rule for the development.
#
# 2019-03-01: Fix the rule that builds the OpenDocument. Simplify the
# interface: Make all lformats with "all".
#
# 2019-03-10: Add HTML output (several variants built with Asciidoctor and
# pandoc). Fix metadata options in pandoc commands.
