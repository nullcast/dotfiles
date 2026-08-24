/opt/homebrew/bin/mise activate fish | source

set -e FORGE_PATH
set -l conda_path (command -s conda)
if set -q conda_path[1]
  set -g FORGE_PATH (dirname (dirname $conda_path))
end

function remove_path
  if not set -q argv[1]
    return 0
  end

  set -l target_path $argv[1]
  set -l new_path

  for dir in $PATH
    if test $dir != $target_path
      set new_path $new_path $dir
    end
  end

  set -gx PATH $new_path
end

function conda_not_found
  # Conda の実行ファイルパスを取得してクリア
  if set -q FORGE_PATH[1]
    remove_path $FORGE_PATH/bin
    remove_path $FORGE_PATH/condabin
    set -e FORGE_PATH
  end
  functions -e conda
end

# mise current の出力から Conda ベースの Python バージョンを抽出
set conda_version (mise current | grep 'python' | string match -r '.*anaconda.*|.*miniforge.*' | awk '{print $2}')

if not set -q conda_version[1]
  conda_not_found
end
