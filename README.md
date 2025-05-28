# RStudioとLatexの研究環境

RStudioとLatex環境 (tinytex)のDockerコンテナ。ベースイメージはrocker/rstudio。rockerプロジェクトには，tidyverseやLatex環境導入済みのイメージもあるが，柔軟にカスタマイズできるようにrocker/rstudioをベースにした。


## コンテナの内容

- ベースイメージrocker/rstudioに含まれているもの
  - R本体
  - RStudio Server
  - Pandoc
- 追加したもの
  - tidyverseとsfをインストールするのに必要なパッケージ
  - RStudioでgithub copilotを利用可能に
  - Gnuplot
  - Ghostsctipt
  - IPAフォント，Notoフォント
  - [Pandoc-crosreff](https://github.com/lierdakil/pandoc-crossref)

## 導入の準備

以下，Windowsの場合はWSL，Macの場合はターミナルでの操作



## Dockerでビルドする準備

### Docker Desktopのインストール

Windowsであればwinget
```
winget install Docker.DockerDesktop
```
Macであればhomebrew
```
brew install DockerDesktop
```

- インストール後には再起動が必要

### レポジトリのクローン

レポジトリをクローン (場所はホームフォルダなどわかりやすいところでOk，Windowsの場合wslファイルシステム上に)
```
git clone git@github.com:tomokazu518/Research-tools.git
```
フォルダ構成は以下

<pre>
Research-tools
├── Dockerfile
├── README.md
├── docker-compose.yml
└── other
    ├── init.sh     
    ├── script
    │   ├── gnuplot.sh
    │   ├── lecture_beamer.sh
    │   ├── tikz.sh
    └── templates
         ├── beamer-with-notes.latex
         ├── beamer-without-notes.latex
         └── lecture_beamer.latex
</pre>

## Dockerイメージのビルドと起動

`docker-compose.yml`と`Dockerfile`のあるフォルダ (Research-tools)に入ってdocker composeを実行
```
cd Research-tools
docker compose up -d
```
ビルドにはそこそこの時間がかかるが，終わればコンテナが起動する (再起動後も自動起動する)

## 使い方

### RStudio Serverにアクセス

RStudio Serverにはブラウザからアクセスできる (Chromeなどでアプリ化すると，Desktop版RStudioとほぼ同一の操作感)

http://localhost:8787

### 初期設定

RStudio Serverにアクセスして，ターミナルから`init.sh`を実行すれば以下の設定が行われる

- DVCのインストール
- tinytexのRパッケージと本体のインストール
- 原ノ味フォントのインストール
- TexCountのインストール
- `gnuplot-lua-tikz.sty`のインストール
- .bashrcと.bash_profileの設定 (PATHの処理)
- HackGenフォントのインストール (RStudio Serverインターフェイス用)

### 基本的な使い方

Research-toolsフォルダはホームフォルダ(/home/rstudio)としてマウントされるので，その中に`projects`というサブ・フォルダを作成し，さらにその中でプロジェクトごとのフォルダを作って使うことを想定している

### Python

pipxでpythonのパッケージをインストールできる
- ~/.local/binにインストールされる

### Visual Studio Codeで使う

Latexやquartoのソース編集などは，RStudioよりもVScodeの方が良い場合もある。VScodeをコンテナにアタッチして使うときには，ファイルのパーミションの問題 (とくにWindows)があるので，コンテナにはrstudioユーザーで入る。コンテナ構成ファイルに以下を追加すれば良い。
  ```
	"remoteUser": "rstudio"
  ```

## 参考

- Yanagimotoさんの[VSCode + Dockerでよりミニマルでポータブルな研究環境を](https://zenn.dev/nicetak/articles/vscode-docker-2023)，[VSCode + Docker + Rstudio + DVC でポータブルな研究環境を作る](https://zenn.dev/nicetak/articles/vscode-docker-rstudio?redirected=1)
- yetanothersuさんの[RStudio Serverで好きなフォントを使う](https://qiita.com/yetanothersu/items/18e098989cade90ee687)