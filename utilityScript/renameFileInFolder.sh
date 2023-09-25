for d in ../sessions/* ; do
 if [ -d "$d" ]; then
        # $f is a directory
        folderName=${d##*/} # print the file name

        for f in $d/* ; do
            if [ -f "$f" ]; then
                # $f is a file
                nome_file=${f##*/} # print the file name
                echo "FolderPath: $d"
                echo "FilePath: $f"
                echo "File: $nome_file"
                echo "foldername: $folderName"

                echo "cmd: $d/$folderName.jpeg"
                mv $f $"$d/$folderName.jpeg"
            fi
        done
    fi
done