while getopts dbf: OPT
do
  case $OPT in
    "d" ) DEBUGMODE="TRUE" ;;
    "b" ) BLANKMODE="TRUE" ;;
    "f" ) FILENAME="$OPTARG" ;;
  esac
done

BASENAME=${FILENAME%.*}

cp $FILENAME $BASENAME-temp.md

mkdir -p temp
cp plots_figures/*.* temp/

# 図・グラフの参照先フォルダをtempに変更
sed -i 's/plots_figures\//temp\//g' $BASENAME-temp.md

# texの図などの強調を太字から空欄または赤字に変更
if [ "$BLANKMODE" = "TRUE" ]; then
  sed -i  's/\\textbf/\\phantom/g' temp/*.tex
else
  sed -i 's/\\textbf/\\textcolor{red}/g' temp/*.tex
fi

# gnuplotの空欄スライド用描画コマンドを削除
sed -i '/\#plot-blank\#/{n;d;}' temp/*.plt


# -bが指定された場合，tikzの赤字・青字や塗りを透明に
if [ "$BLANKMODE" = "TRUE" ]; then
sed -i   \
            -e 's/\[red/\[transparent/g' \
            -e 's/text=red/text=white/g' \
            -e 's/\[blue/\[transparent/g' \
            -e 's/text=blue/text=white/g'  \
            -e 's/opacity=0.1/opacity=0/g' \
        temp/*.tex
fi

# Pandocでマークダウンをtexに変換
pandoc \
--template=/home/rstudio/pandoc/templates/lecture_beamer.latex \
--pdf-engine=xelatex \
-f markdown-auto_identifiers \
-F pandoc-crossref \
-t beamer \
-o $BASENAME.tex \
$BASENAME-temp.md

# texソースの強調を太字から空欄または赤字に変更
if [ "$BLANKMODE" = "TRUE" ]; then
  sed -i 's/\\textbf/\\phantom/g' $BASENAME.tex 
else
  sed -i 's/\\textbf/\\textcolor{red}/g' $BASENAME.tex
fi

# texのコンパイル
R -e "tinytex::latexmk(file=\"$BASENAME.tex\",engine=\"xelatex\",engine_args=\"-shell-escape\")"

# PDFファイルのリネーム
if [ "$BLANKMODE" = "TRUE" ]; then
  mv $BASENAME.pdf $BASENAME-blank.pdf
else
    mv $BASENAME.pdf $BASENAME-master.pdf
fi

# 一時ファイルのクリーンアップ
if [ "$DEBUGMODE" = "TRUE" ]; then
  exit 0
fi
rm $BASENAME-temp.md
rm $BASENAME-gnuplottex-fig*.gnuplot
rm $BASENAME-gnuplottex-fig*.tex
rm $BASENAME.gnuploterrors
rm $BASENAME.tex
rm -r temp



