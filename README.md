# Dotfiles for WSL (Ubuntu)

Windows の WSL (Ubuntu) 開発環境を自動セットアップするための dotfiles です。
WSL のディストリビューションを作り直したあとに、ワンコマンドで同じ環境に戻せるようにすることが目的です。

Mac 版 ([YFurusawa727/dotfiles](https://github.com/YFurusawa727/dotfiles)) をもとに、GUI アプリなど WSL に不要なものを省いています。

## 前提条件

- Windows 11 + WSL2 + Ubuntu (26.04 で動作確認)
- Windows 側にインストール済みのもの (任意)
  - **Git for Windows**: Git Credential Manager を WSL から使い、認証情報を Windows と共有します
  - **Docker Desktop**: `Settings > Resources > WSL integration` で対象のディストリビューションを有効にしてください
  - **VS Code**: Remote - WSL で接続します
  - **ターミナル / フォント**: Windows Terminal と JetBrainsMono Nerd Font (starship のアイコン表示に必要)

## インストール

新しい WSL を立ち上げて、ユーザー作成が終わったら次のコマンドを実行します。

```bash
curl -fsSL https://raw.githubusercontent.com/YFurusawa727/dotfiles-wsl/main/install | bash
```

または:

```bash
git clone https://github.com/YFurusawa727/dotfiles-wsl.git ~/dotfiles-wsl
~/dotfiles-wsl/install
```

途中で sudo のパスワードと、git の名前・メールアドレスを聞かれます。
`GIT_USER_NAME` / `GIT_USER_EMAIL` を export してから実行すると、名前とメールアドレスの入力を省略できます。

完了したらターミナルを開き直してください (デフォルトシェルが zsh に変わります)。

### セットアップの流れ

1. `apt update && apt upgrade`
2. リポジトリを `~/dotfiles-wsl` に clone
3. `apt-packages.txt` に書かれたパッケージをインストール
4. `ja_JP.UTF-8` ロケールを生成
5. 公式 apt リポジトリを追加して `gh` と `google-cloud-cli` をインストール
6. asdf (最新リリースのバイナリ) を `~/.local/bin` に配置
7. `.env` を作成し、`.gitconfig` を生成 (Git Credential Manager があれば設定)
8. 既存の設定ファイルを `~/.dotfiles-backup/<日時>/` に退避してから stow でシンボリックリンクを作成
9. asdf で `.tool-versions` のランタイムをインストール
10. `.default-npm-packages` の npm パッケージ (Codex CLI, Copilot CLI) をインストール
11. Claude Code (ネイティブ版) をインストール
12. デフォルトシェルを zsh に変更

`install` は何度実行しても大丈夫です (インストール済みのものはスキップします)。

## インストールされるもの

| 種類 | 内容 |
|------|------|
| apt | build-essential, curl, wget, git, gnupg, unzip, zip, vim, locales, bash-completion, stow, zsh, zsh-autosuggestions, zsh-syntax-highlighting, starship, fzf |
| apt (公式リポジトリ) | gh (GitHub CLI), google-cloud-cli |
| バイナリ | asdf (`~/.local/bin`) |
| asdf | Node.js 24.21.0 |
| npm (global) | `@openai/codex`, `@github/copilot` |
| その他 | Claude Code (`curl https://claude.ai/install.sh`) |

## ファイル構造

```
dotfiles-wsl/
├── install               # インストールスクリプト
├── apt-packages.txt      # apt パッケージ一覧 (Mac 版の Brewfile 相当)
├── validate.sh           # 事前検証
├── test_install.sh       # インストール後テスト
├── .env.example          # 環境変数のテンプレート
└── packages/             # stow パッケージ (ホームディレクトリと同じ構造)
    ├── shell/.commonrc            # bash / zsh 共通の環境変数・エイリアス・WSL 用関数
    ├── bash/.bashrc
    ├── zsh/.zshrc
    ├── git/.gitconfig.example     # .gitconfig のテンプレート
    ├── asdf/.tool-versions
    ├── asdf/.default-npm-packages # Node インストール時に入れる npm パッケージ
    └── starship/.config/starship.toml
```

## 使い方

### エイリアス

```bash
..  ..2  ..3        # cd ..  /  cd ../..  /  cd ../../..
g                   # git
ll                  # clear && ls -alF

dotinstall          # install の再実行
dotcheck            # 事前検証 (結果のみ)
dotvalidate         # 事前検証 (詳細)
dottest             # インストール後テスト (サマリー)
dottest-full        # インストール後テスト (詳細)
dottest-summary     # 各テストの成功/失敗一覧
```

### WSL 用コマンド (Mac と同じ感覚で使うためのもの)

| コマンド | 動作 |
|---------|------|
| `open <パス\|URL>` | Windows の既定アプリ / エクスプローラーで開く (`open .` でカレントディレクトリ) |
| `pbcopy` | 標準入力を Windows のクリップボードにコピー (`clip.exe`) |
| `pbpaste` | Windows のクリップボードの内容を出力 |

### キーボードショートカット (zsh + fzf)

| ショートカット | 動作 |
|--------------|------|
| `Ctrl+R` | コマンド履歴を fzf で検索 (重複なし) |
| `Ctrl+E` | 最近移動したディレクトリを fzf で選んで移動 |
| `Ctrl+T` | カレントディレクトリ以下のファイルを fzf で選んでコマンドラインに挿入 |
| `Alt+C` | カレントディレクトリ以下のディレクトリを fzf で選んで cd |

### Git エイリアス

Mac 版と同じです (`g s`, `g d`, `g a`, `g aa`, `g b`, `g co`, `g cob`, `g cm`, `g pso`, `g pl`, `g l` など)。
WSL 向けに `core.autocrlf = input` と `init.defaultBranch = main` を追加しています。

## カスタマイズ

- **apt パッケージの追加**: `apt-packages.txt` に1行ずつ追加して `dotinstall`
- **ランタイムの追加**: `packages/asdf/.tool-versions` に追加して `dotinstall` (プラグインは自動で追加されます)
- **npm グローバルパッケージの追加**: `packages/asdf/.default-npm-packages` に追加して `dotinstall`
- **設定ファイルの追加**: `packages/<名前>/` にホームディレクトリと同じ構造で置き、`install` の `STOW_PACKAGES` に追加

## Mac 版との違い

- Homebrew / Brewfile の代わりに apt (`apt-packages.txt`) を使用
- GUI アプリ、Alacritty、フォントは Windows 側で管理するため含めていません
- Docker は Docker Desktop の WSL 連携を使うので、WSL 側には何もインストールしません
- `stow --adopt` の代わりに、既存ファイルを `~/.dotfiles-backup/` に退避してからリンクします
  (新しい WSL には Ubuntu 標準の `~/.bashrc` があり、`--adopt` を使うとリポジトリの `.bashrc` がそれで上書きされてしまうため)
- bash / zsh 共通の設定は `~/.commonrc` にまとめています

## トラブルシューティング

**docker が見つからない**: Docker Desktop を起動して、`Settings > Resources > WSL integration` でこのディストリビューションを有効にしてください。

**git push で認証を求められる**: Git for Windows をインストールして `dotinstall` を再実行するか、`gh auth login && gh auth setup-git` を実行してください。

**退避した設定を戻したい**: `~/.dotfiles-backup/<日時>/` に元のファイルがあります。

## セキュリティ

- `.env` と `packages/git/.gitconfig` は git 管理外です。個人情報はコミットしないでください
- `validate.sh` で機密情報らしき文字列をチェックしています
