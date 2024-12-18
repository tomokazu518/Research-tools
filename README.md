# RStudioとLatexの研究環境

## コンテナの内容

- ベースイメージはrocker/rstudio
  - R本体
  - RStudio Server
  - Pandoc
- 追加したもの
  - tidyverseとsfをインストールするのに必要なパッケージ   
  - Gnuplot
  - Ghostsctipt
  - IPAフォント，Notoフォント
  - Rのrenvパッケージ
  - RStudioでgithub copilotを利用可能に
  - [Pandoc-crosreff](https://github.com/lierdakil/pandoc-crossref)

## 導入の準備

以下，Windowsの場合はWSL，Macの場合はターミナルでの操作

### gitの初期設定

ユーザー名，メールアドレスを設定する。

```{shell}
git config --global user.name "ユーザー名"
git config --global user.email メールアドレス
```

### 秘密鍵を作成してGithubに登録

githubのアカウントがあることが前提
 - だれでも作成可能
 - アカデミック申請すれば，Proの機能も無料で使える
 - とくにgithub copilotは便利

githubにアクセスするための秘密鍵を作成
```{shell}
ssh-keygen -t ed25519
```
- 保存場所とパスフレーズを聞かれる
  - 保存場所はデフォルト(~/.ssh)でOkなので何も入力せずにEnter
  - パスフレーズも必要なければそのままEnter
- ~/.sshフォルダにid_ed255119とid_ed25519.pubという2つのファイルができる
  - 公開鍵 (id_ed25519.pubの方)をテキスト・エディタなどで開いて，内容をコピー
  - Githubのアカウント設定 (画面右上)からSSH and GPG keysを選び，New SSH keyボタンを押す。Titleは適当に，Keyにはコピーした公開鍵を追加

接続できることを確認
```
ssh git@github.com
```
次のように表示されればOk
```
Hi tomokazu518! You've successfully authenticated, but GitHub does not provide shell access.
Connection to github.com closed.
```
SSH Agentに秘密鍵を登録 (これでコンテナからも設定不要でssh可能)
```
ssh-add
```

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
├── init.sh
└── pandoc
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