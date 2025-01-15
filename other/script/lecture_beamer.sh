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

if [ -d plots_figures ]; then
    mkdir -p temp
    cp plots_figures/*.* temp/

    # 図・グラフの参照先フォルダをtempに変更
    sed -i 's/plots_figures\//temp\//g' $BASENAME-temp.md

    # -bが指定された場合，tikzの赤字・青字や塗りを透明に
    if [ "$BLANKMODE" = "TRUE" ]; then
      sed -i  's/\\textbf/\\phantom/g' temp/*.tex  # texの図などの強調を太字から空欄に変更
      sed -i '/\#plot-master\#/{n;d;}' temp/*.plt  # gnuplotのマスタースライド用描画コマンドを削除
      sed -i -e 's/\[red/\[transparent/g' \
             -e 's/text=red/text=white/g' \
             -e 's/\[blue/\[transparent/g' \
             -e 's/text=blue/text=white/g'  \
             -e 's/opacity=0.1/opacity=0/g' \
            temp/*.tex
    else
      sed -i 's/\\textbf/\\textcolor{red}/g' temp/*.tex  # texの図などの強調を太字から赤字に変更
      sed -i '/\#plot-blank\#/{n;d;}' temp/*.plt  # gnuplotの空欄スライド用描画コマンドを削除
    fi
fi

# Pandocでマークダウンをtexに変換
pandoc \
--template=/home/rstudio/other/templates/lecture_beamer.latex \
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
rm $BASENAME.tex

if [ ! -d temp ]; then
  exit 0
fi

rm -r temp

if [ -e $BASENAME.gnuploterrors ]; then
  rm -f $BASENAME.gnuploterrors
  rm -f $BASENAME-gnuplottex-fig*.gnuplot
  rm -f $BASENAME-gnuplottex-fig*.tex
  rm -f $BASENAME-gnuplottex-fig*.pdf
fi



