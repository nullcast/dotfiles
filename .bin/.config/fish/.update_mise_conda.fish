#!/usr/bin/env fish

function remove_path
    set -l target_path $argv[1]
    set -l new_path

    for dir in $PATH
        if test $dir != $target_path
        set new_path $new_path $dir
        end
    end

    set -gx PATH $new_path
end

function update_mise_conda
    # mise current の出力から Conda ベースの Python バージョンを抽出
    set conda_version (mise current | grep 'python' | string match -r '.*anaconda.*|.*miniforge.*' | awk '{print $2}')

    # Conda ベースの Python バージョンが見つかった場合の処理
    if set -q conda_version[1]
        set conda_dir "$HOME/.conda_$conda_version[1]"

        # Conda ディレクトリが存在しなければ作成
        if not test -d $conda_dir
            mkdir -p $conda_dir
        end

        # 現在の .conda ディレクトリのシンボリックリンクを更新
        rm -rf ~/.conda
        ln -s $conda_dir ~/.conda

        # 必要に応じて conda の環境変数を設定
        set -x CONDA_ENVS_PATH $conda_dir/envs
        echo "Conda version" $conda_version[1]
        fish_add_path $HOME/.local/share/mise/installs/python/$conda_version[1]/bin
        fish_add_path $HOME/.local/share/mise/installs/python/$conda_version[1]/condabin

        conda init fish
        source ~/.config/fish/config.fish

        set -gx FORGE_PATH (dirname (dirname (which conda)))
        echo "Conda found" $FORGE_PATH
    else
        conda deactivate

        # Conda の実行ファイルパスを取得してクリア
        if set -q FORGE_PATH
            remove_path $FORGE_PATH/bin
            remove_path $FORGE_PATH/condabin
            set -e FORGE_PATH
        end
        functions -e conda

        # Conda ベースの Python がない場合は、シンボリックリンクを削除
        set conda_link ~/.conda

        if test -L $conda_link
            rm $conda_link
        end

        # Conda 関連の環境変数をクリア
        set -e CONDA_ENVS_PATH
    end
end
