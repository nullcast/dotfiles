#!/usr/bin/env fish
# mise の Python が conda 系（anaconda / miniforge）かどうかで conda 環境を切り替える。
# config.fish の PWD ハンドラから呼ばれる。remove_path は conf.d/mise.fish で定義。

function update_mise_conda
    # mise current の出力から Conda ベースの Python バージョンを抽出
    set -l conda_version (mise current | grep 'python' | string match -r '.*anaconda.*|.*miniforge.*' | awk '{print $2}')

    # Conda ベースの Python バージョンが見つかった場合の処理
    if set -q conda_version[1]
        set -l conda_dir "$HOME/.conda_$conda_version[1]"

        # Conda ディレクトリが存在しなければ作成
        if not test -d $conda_dir
            mkdir -p $conda_dir
        end

        # ~/.conda をバージョン別ディレクトリへの symlink に張り替える。
        # 実ディレクトリの場合は中身を消さないよう何もしない。
        if test -L ~/.conda; or not test -e ~/.conda
            ln -sfn $conda_dir ~/.conda
        else
            echo "WARNING: ~/.conda is a real directory; leaving it untouched" >&2
        end

        # conda の環境変数を設定（関数外でも有効になるよう -gx）
        set -gx CONDA_ENVS_PATH $conda_dir/envs
        echo "Conda version" $conda_version[1]
        # -P: universal な fish_user_paths ではなく、このシェルの PATH だけを変える
        fish_add_path -P $HOME/.local/share/mise/installs/python/$conda_version[1]/bin
        fish_add_path -P $HOME/.local/share/mise/installs/python/$conda_version[1]/condabin

        set -l conda_bin (command -s conda)
        if set -q conda_bin[1]
            set -gx FORGE_PATH (dirname (dirname $conda_bin[1]))
            echo "Conda found" $FORGE_PATH
        end
    else
        if functions -q conda
            conda deactivate 2>/dev/null
        end

        # Conda の実行ファイルパスを取得してクリア
        if set -q FORGE_PATH[1]
            remove_path $FORGE_PATH/bin
            remove_path $FORGE_PATH/condabin
            set -e FORGE_PATH
        end
        functions -e conda

        # Conda ベースの Python がない場合は、シンボリックリンクを削除
        if test -L ~/.conda
            rm ~/.conda
        end

        # Conda 関連の環境変数をクリア
        set -e CONDA_ENVS_PATH
    end

    # Python が変わったので gcloud が使う Python も追従させる
    refresh_cloudsdk_python
end
