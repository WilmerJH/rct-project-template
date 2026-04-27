RSCRIPT := Rscript --vanilla
QUARTO := quarto

DATA := data/external/10k_word_counts.csv
ANALYSIS := code/R/10k_word_counts_figure.R
SOURCE := doc/10k_word_counts_figure.qmd

FIG1 := output/word_counts_figure_1996_2013.png
FIG2 := output/word_counts_figure_1996_2025.png
FIG3 := output/word_counts_boxplot_1996_2025.png

PAPER_BASENAME := 10k_word_counts_figure.pdf
PAPER := output/$(PAPER_BASENAME)

.PHONY: all clean figures paper

all: $(PAPER)

figures: $(FIG1) $(FIG2) $(FIG3)

$(FIG1) $(FIG2) $(FIG3): $(ANALYSIS) $(DATA)
	mkdir -p output
	$(RSCRIPT) $(ANALYSIS)

$(PAPER): $(SOURCE) $(FIG1) $(FIG2) $(FIG3)
	mkdir -p output
	rm -rf .quarto doc/.quarto
	cd doc && $(QUARTO) render 10k_word_counts_figure.qmd --to pdf --output $(PAPER_BASENAME)
	mv doc/$(PAPER_BASENAME) output/$(PAPER_BASENAME)
	rm -f paper.tex paper.log paper.aux paper.out paper.knit.md
	rm -f texput.log doc/texput.log
	rm -f doc/*.tex doc/*.log doc/*.aux doc/*.out doc/*.knit.md doc/*.fff doc/*.ttt

clean:
	rm -rf .quarto doc/.quarto
	rm -f $(FIG1) $(FIG2) $(FIG3) $(PAPER)
	rm -f paper.tex paper.log paper.aux paper.out paper.knit.md
	rm -f texput.log doc/texput.log
	rm -f doc/*.tex doc/*.log doc/*.aux doc/*.out doc/*.knit.md doc/*.fff doc/*.ttt