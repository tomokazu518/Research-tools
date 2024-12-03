set -e

BASENAME=${1%.*}

printf "set terminal pdf \n\
set output '$BASENAME-master.pdf' \n" > temp-master.plt
cat $1 >> "temp-master.plt"

printf "set terminal pdf \n\
set output '$BASENAME-blank.pdf' \n" > temp-blank.plt
cat $1 >> "temp-blank.plt"

sed -i '/\#plot-blank\#/{n;d;}' temp-master.plt  # gnuplotの空欄スライド用描画コマンドを削除
sed -i '/\#plot-master\#/{n;d;}' temp-blank.plt  # gnuplotのマスタースライド用描画コマンドを削除

gnuplot temp-master.plt
gnuplot temp-blank.plt

rm temp-master.plt 
rm temp-blank.plt
