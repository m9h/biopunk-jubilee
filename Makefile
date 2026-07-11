RINF ?= /home/mhough/dev/research-infra/.venv/bin/rinf
OUT  := manuscript/output

.PHONY: all manuscript slides check clean

all: manuscript slides

manuscript:
	$(RINF) build manuscript

slides:
	$(RINF) build slides

## Verify the built PDFs: resolved citations, real glyphs, no overflowing frames.
check: all
	@echo "== citations =="
	@n=$$(pdftotext $(OUT)/jubilee-tandem.pdf - | grep -c '\[@' || true); \
	  echo "   unresolved: $$n"; [ "$$n" -eq 0 ] || exit 1
	@echo "== glyphs (tofu / missing chars) =="
	@for f in $(OUT)/jubilee-tandem.pdf $(OUT)/jubilee-tandem_slides.pdf; do \
	   n=$$(pdftotext $$f - | grep -c '�' || true); \
	   echo "   $$(basename $$f): $$n"; [ "$$n" -eq 0 ] || exit 1; \
	 done
	@echo "== literal \$$math\$$ leaking into text =="
	@n=$$(pdftotext $(OUT)/jubilee-tandem.pdf - | grep -cE '\$$[^ ]*\$$' || true); \
	  echo "   leaks: $$n"; [ "$$n" -eq 0 ] || exit 1
	@echo "== frame overflow =="
	@tmp=$$(mktemp -d); cp $(OUT)/slides.md $$tmp/; \
	 (cd $$tmp && pandoc slides.md --from markdown --to beamer --slide-level=2 \
	    -V aspectratio=169 -s -o s.tex 2>/dev/null && \
	  xelatex -interaction=nonstopmode s.tex >/dev/null 2>&1; \
	  grep -oE 'Overfull .vbox \([0-9.]+pt too high\)' s.log | sed 's/^/   /' || echo "   none"); \
	 rm -rf $$tmp
	@echo "OK"

clean:
	rm -rf $(OUT)
