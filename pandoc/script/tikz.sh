set -e

BASENAME=${1%.*}

printf "\\documentclass{standalone} \n\
\\\usepackage{zxjatype} \n\
\\\usepackage[ipa]{zxjafont} \n\
\\\usepackage{tikz} \n\
\\\usetikzlibrary{intersections,calc,arrows.meta,positioning,angles} \n\
\\\begin{document} \n" > "$BASENAME-master.tex"
cat $1 >> "$BASENAME-master.tex"
printf "\n \\\end{document}" >> "$BASENAME-master.tex"

cp $BASENAME-master.tex $BASENAME-blank.tex

sed -i -e 's/\[red/\[transparent/g' \
        -e 's/text=red/text=white/g' \
        -e 's/\[blue/\[transparent/g' \
        -e 's/text=blue/text=white/g'  \
        -e 's/opacity=0.1/opacity=0/g' \
    $BASENAME-blank.tex

latexmk -pdfxe $BASENAME-master.tex
latexmk -pdfxe $BASENAME-blank.tex

latexmk -c $BASENAME-master.tex
latexmk -c $BASENAME-blank.tex

rm $BASENAME-master.tex
rm $BASENAME-blank.tex