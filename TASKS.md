# セットアップ改善タスク

dotfiles の設計・実装レビュー（2026-07-02 実施）の結果と進捗。
レビューは5観点（正確性 / べき等性・移植性 / セキュリティ / shellイディオム / 設計・CI・ドキュメント）で行い、
各指摘はサンドボックス再現または反証検証を通過したもののみ採録。

## 進捗サマリ

| フェーズ | 状態 |
|---|---|
| Phase 0: セットアップ復旧（ブロッカー） | ✅ 完了（9コミット、`make brew` 完走・CI green 確認済み） |
| Phase 1: High（新規マシンで壊れる） | ⬜ 未着手 0/4 |
| Phase 2: Medium（安全性・品質） | ⬜ 未着手 0/6 |
| Phase 3: Low / Brewfile 整備 | ⬜ 未着手 |

---

## ✅ Phase 0: 完了済み（branch `fix/dotfiles-setup`）

- [x] Makefile: 未定義 `anyenv` ターゲット削除（`make` が常に失敗していた） — `4990e79`
- [x] init.sh: Homebrew インストーラを実行（`/dev/null` に捨てていた） — `4990e79`
- [x] Brewfile: 廃止 tap（cask-fonts / cask-versions / weaveworks）削除、eksctl を core から、存在しない `claude-in-powerpoint` 削除、helm 重複解消 — `4990e79`
- [x] brew.sh: Homebrew 6 の tap-trust 対応（`brew trust` で bagonyi / my/casks を信頼登録） — `4990e79`
- [x] fish: `eval (mise activate fish)` → `| source`（起動毎の `set: -gx: invalid variable name` エラー解消）、mise 二重 activate 解消、起動ノイズ除去 — `4990e79`
- [x] link.sh: `~/.config` 丸ごと symlink を廃止、管理サブディレクトリ（brew/fish/jgit/mise）のみリンク。レガシー symlink は実ディレクトリへ移行し資格情報を repo 外へ退避（実機で gcloud 17 エントリ無傷を確認） — `8628187`
- [x] .bash_profile: `/usr/local` 固定 → `$(brew --prefix)`、`git-completion.bash` 名修正、VS Code PATH 修正、`npm bin -g` 削除 — `8628187`
- [x] CI: フル `make` 実行をやめ lint（shellcheck + `fish --no-execute`）に、checkout v4、PR でも実行 — `8628187`
- [x] README を実態に合わせ更新 — `eabab36`
- [x] fish をログインシェルに（brew 導入後に chsh） — `3e9787e`
- [x] init.sh をべき等化（CLT / Rosetta / brew の導入済み判定） — `eb79ed7`
- [x] mise バージョン整合（java 18→17、node 18.5.0→20 LTS） — `c8fa6c7`
- [x] mitmproxy を cask として追加（formula には存在しない） — `e6c088e`
- [x] tools/check_intel.sh に shebang 追加（CI shellcheck SC2148） — `69871b6`

---

## 🔴 Phase 1: High — 新規マシンでセットアップが壊れる

- [ ] **H1. fish 起動で PATH が完全消滅する（conda 不在マシン）** — `.bin/.config/fish/conf.d/mise.fish`
  - 原因: conda が無いと `(dirname (dirname (which conda)))` が空リストになるが `set -q FORGE_PATH` は空リストでも真。`remove_path` が引数ゼロで走り `test $dir !=` が全滅 → `set -gx PATH $new_path` で PATH が 0 個に（サンドボックスで再現済み）。
  - 修正案: `set -q FORGE_PATH[1]` でガード、または冒頭で `type -q conda; or exit 0` 相当の早期 return。
- [ ] **H2. `ln -fns` が既存の実ディレクトリ内に入れ子 symlink を作る** — `.bin/link.sh` `link()`
  - 原因: リンク先（例 `~/.config/fish`）が実ディレクトリだと BSD ln は置換できず `fish/fish → repo` を作り exit 0。fish は初回起動で `~/.config/fish` を自動生成するため新規マシンの通常経路（再現済み）。
  - 修正案: リンク先が実ディレクトリなら退避（`mv dest dest.bak`）または明示エラーにしてから `ln`。
- [ ] **H3. `my/casks` tap の中身が未バージョン管理で他マシン再現不能** — `.bin/.Brewfile` / `.bin/.config/brew`
  - 原因: `genspark-ai-browser` の cask 定義はローカル tap にのみ存在し、repo は絶対パス symlink を追跡しているだけ。新規マシンでは `tap-new` が空 tap を作り `brew bundle` が失敗、`set -euo` で brew.sh 全体が中断。
  - 修正案: cask の .rb を repo にコミットし、brew.sh で tap 作成＋配置を自動化。または my/casks 依存を Brewfile から外す。
- [ ] **H4. README の手順順序が矛盾（brew が無い段階で `brew tap-new`）** — `README.md`
  - 修正案: tap 手順を `make init` 後に移動（H3 を自動化するなら手順ごと削除）。

## 🟠 Phase 2: Medium — 安全性・品質

- [ ] **M1. `~/.config` 移行が途中失敗すると資格情報が repo 内に無警告で取り残される** — `.bin/link.sh`
  - 原因: `rm`(symlink) が先・`mv` ループが後。mv 1 つの失敗で `set -e` 中断 → 次回は `[[ -L ]]` が偽で移行ブロックを丸ごと silent skip（サンドボックスで再現済み）。
  - 修正案: mv を全て終えてから symlink を外す順序に変更＋失敗時に警告。
- [ ] **M2. `.gitignore` の資格情報ルール削除がレガシー機で commit 窓を開ける** — `.gitignore`
  - 原因: 旧レイアウトのマシンでこのブランチを checkout した瞬間〜`make link` 実行までの間、`.bin/.config/gcloud` 等が untracked で見え `git add -A` で stage 可能。
  - 修正案: `.bin/.config/gcloud|configstore|expressvpn` の 3 行を defense-in-depth として復活（コストゼロ）。
- [ ] **M3. git-secrets が実際には機能していない** — `.bin/.gitconfig`
  - 原因: `init.templatedir = ~/.git-templates/git-secrets` を作る手順がどこにも無い。git は警告のみで hooks 無しの init を続行（サンドボックス実証）。
  - 修正案: brew.sh に `git secrets --install ~/.git-templates/git-secrets && git secrets --register-aws --global` を追加。
- [ ] **M4. PATH 順序 regression＋重複増殖** — `.bin/.config/fish/config.fish`
  - 原因: mise activate を conf.d に移した結果、config.fish の `/usr/local` 生 prepend が mise tool dirs より前に。生 `set -x PATH` は重複除去せず nested shell で増殖。
  - 修正案: config.fish 冒頭 3 行の prepend を削除し 00-path.fish（`fish_add_path`）に集約。
- [ ] **M5. 他所由来の `~/.config` symlink も無条件に rm** — `.bin/link.sh`
  - 修正案: `readlink` が自 repo の `.bin/.config` を指す場合のみ移行を実行。
- [ ] **M6. 毎プロンプト `mise current` 実行で約 100ms/Enter の遅延** — `.bin/.config/fish/config.fish` `check_and_update_conda_version`
  - 修正案: `--on-event fish_prompt` を `--on-variable PWD` に変更。

## 🟡 Phase 3: Low / 整備

- [ ] L1. CI shellcheck の対象に `.bin/.bash_profile` を追加（`-s bash` 指定）
- [ ] L2. init.sh の Rosetta インストールに sudo（現状 silent fail、brew.sh 側で救済されるため実害小）
- [ ] L3. link.sh 末尾の `[[ -e ]] && link` が最終要素欠落時に `set -e` で誤爆する形を修正
- [ ] L4. config.fish の conda ブロックと mise.fish の conda_not_found の論理矛盾を解消（main 由来・実害小）

### Brewfile 整備

- [ ] B1. インストール済みだが未記載のものを追加（新マシンで消える）: `gh`（PR 作成・CI 監視に必須）, `shellcheck`（CI が依存）, `kubernetes-cli`, `ripgrep`
- [ ] B2. 新規候補の選定・追加: `fzf` / `yq` / `k9s` / `kubectx` / `git-delta` / `dive` / `bat` / `fd` / `eza` / `lazygit` / `htop` / `tldr`（全て formula 実在確認済み）
- [ ] B3. `expressvpn` の残骸を削除（nordvpn に置換済み、アプリ実体は未アンインストール）

---

## ❌ 棄却済みの指摘（再検討不要）

| 指摘 | 棄却理由 |
|---|---|
| brew.sh の sudo keepalive がセキュリティリスク | main から不変・by design。SIGINT/SIGTERM/SIGHUP で trap が keepalive を kill することをサンドボックスで確認（SIGKILL のみ例外で、これは対処不能な一般則） |
| CI workflow に `permissions:` ブロックが無い | 現 CI は静的 lint のみで repo コードを実行せず、到達可能な障害シナリオ無し。`permissions: contents: read` は任意の hardening としては可 |

## 検証メモ

- 各 High 指摘はサンドボックス（fake $HOME / fish サブシェル）で再現済み。実 $HOME・実 repo は不変のまま検証。
- 実機（この Mac）は移行完了済み: `~/.config` は実ディレクトリ、gcloud 17 エントリ無傷、`gcloud config list` 正常。
- H1/H2 は「新規マシン」でのみ発火する。現機では顕在化しない点に注意。
