# Deck generator (code ↔ formula slides)

`python3 -c "import build, slides; build.build(slides.S); build.pptx(slides.S, 'out/deck.pptx')"`

Needs: `npm i katex` (math), `pip install pygments python-pptx playwright` and a Chrome binary.
Code panels read line numbers live from the repo (`REPO` in build.py), so after a code change
re-run and check the `lines=[...]` of each group in slides.py. Plots go in `assets/`.
