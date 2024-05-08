{ config, pkgs, ... }:

let
  hotlistDirs = [
    "/"
    config.home.homeDirectory
    config.xdg.dataHome
    "/run/media/${config.home.username}" # TODO: is there a canonical repr?
    "/nfs/nas"
  ];
in
{
  home.packages = [ pkgs.mc ];

  xdg = {
    enable = true;
    configFile = {
      "mc/hotlist".text = builtins.concatStringsSep "\n" (
        map (x: ''ENTRY "${x}" URL "${x}"'') hotlistDirs
      );
      "mc/mc.ext.ini".text = builtins.concatStringsSep "\n" [ ''
         #### Custom associations ###

         [wmf]
         Type=^Windows\ metafile
         Include=image

         [emf]
         Type=^Windows\ Enhanced\ Metafile
         Include=image

        ''
        (builtins.readFile (pkgs.mc.outPath + "/etc/mc/mc.ext.ini"))
      ];
      # See `$(nix path-info nixpkgs#mc)/etc/mc/mc.menu` for explanation
      "mc/menu".text = ''
        shell_patterns=0

        + ! t t
        @       Do something on the current file
                CMD=%{Enter command}
                $CMD %f

        + t t
        @       Do something on the tagged files
                CMD=%{Enter command}
                for i in %t ; do
                    $CMD "$i"
                done

        = t d
        1       Compress the current subdirectory (tar.gz)
                Pwd=`basename %d /`
                echo -n "Name of the compressed file (without extension) [$Pwd]: "
                read tar
                [ "$tar"x = x ] && tar="$Pwd"
                cd .. && \
                tar cf - "$Pwd" | gzip -f9 > "$tar.tar.gz" && \
                echo "../$tar.tar.gz created."

        2       Compress the current subdirectory (tar.zst)
                Pwd=`basename %d /`
                echo -n "Name of the compressed file (without extension) [$Pwd]: "
                read tar
                [ "$tar"x = x ] && tar="$Pwd"
                cd .. && \
                tar cf - "$Pwd" | zstd -f > "$tar.tar.zst" && \
                echo "../$tar.tar.zst created."

        + t r & ! t t
        a       Append file to opposite
                cat %f >> %D/%f

        + t t
        A       Append files to opposite files
                for i in %t ; do
                    cat "$i" >> %D/"$i"
                done

        + t r & ! t t
        d       Delete file if a copy exists in the other directory.
                if [ %d = %D ]; then
                    echo "The two directories must be different."
                    exit 1
                fi
                if [ -f %D/%f ]; then        # if two of them, then
                    if cmp -s %D/%f %f; then
                        rm %f && echo %f": DELETED."
                    else
                        echo %f" and "%D/%f" differ: NOT deleted."
                        echo -n "Press RETURN "
                        read key
                    fi
                else
                    echo %f": No copy in "%D/%f": NOT deleted."
                fi

        + t t
        D       Delete tagged files if a copy exists in the other directory.
                if [ %d = %D ]; then
                    echo "The two directories must be different."
                    exit 1
                fi
                for i in %t ; do
                    if [ -f %D/"$i" ]; then
                        SUM1=`sum "$i"`
                        SUM2=`sum %D/"$i"`
                        if [ "$SUM1" = "$SUM2" ]; then
                            rm "$i" && echo "''${i}: DELETED."
                        else
                            echo "$i and "%D"/$i differ: NOT deleted."
                        fi
                    else
                        echo "$i has no copy in "%D": NOT deleted."
                    fi
                done

        m       View manual page
                MAN=%{Enter manual name}
                %view{ascii,nroff} MANROFFOPT="" MAN_KEEP_FORMATTING=1 man -P cat "$MAN"

        = t r
        + ! t t
        s       SCP file to remote host
                echo -n "To which host?: "
                read Host
                echo -n "To which directory on $Host?: "
                read Dir
                scp -p %f "''${Host}:''${Dir}"

        + t t
        S       SCP files to remote host (no error checking)
                echo -n "Copy files to which host?: "
                read Host
                echo -n "To which directory on $Host? :"
                read Dir
                scp -pr %u "''${Host}:''${Dir}"

        =+ f \.tar\.gz$ | f \.tar\.z$ | f \.tgz$ | f \.tpz$ | f \.tar\.lz$ | f \.tar\.lz4$ | f \.tar\.lzma$ | f \.tar\.7z$ | f \.tar\.xz$ | f \.tar\.zst | f \.tar\.Z$ | f \.tar\.bz2$ & t rl
        x       Extract the contents of a compressed tar file
                unset PRG
                case %f in
                    *.tar.7z)   PRG="7za e -so";;
                    *.tar.bz2)  PRG="bunzip2 -c";;
                    *.tar.gz|*.tar.z|*.tgz|*.tpz|*.tar.Z) PRG="gzip -dc";;
                    *.tar.lz)   PRG="lzip -dc";;
                    *.tar.lz4)  PRG="lz4 -dc";;
                    *.tar.lzma) PRG="lzma -dc";;
                    *.tar.xz)   PRG="xz -dc";;
                    *.tar.zst)  PRG="zstd -dc";;
                    *)          exit 1;;
                esac
                $PRG %f | tar xvf -

        = t r
        + ! t t
        y       Gzip or gunzip current file
                unset DECOMP
                case %f in
                    *.gz|*.[zZ]) DECOMP=-d;;
                esac
                # Do *not* add quotes around $DECOMP!
                gzip $DECOMP -v %f

        + t t
        Y       Gzip or gunzip tagged files
                for i in %t ; do
                    unset DECOMP
                    case "$i" in
                        *.gz|*.[zZ]) DECOMP=-d;;
                    esac
                    gzip $DECOMP -v "$i"
                done

        + f \.tar.gz$ | f \.tgz$ | f \.tpz$ | f \.tar.Z$ | f \.tar.z$ | f \.tar.bz2$ | f \.tar.F$ & t r & ! t t
        z       Extract compressed tar file to subdirectory
                unset D
                set gzip -cd
                case %f in
                    *.tar.F)   D=`basename %f .tar.F`; set freeze -dc;;
                    *.tar.Z)   D=`basename %f .tar.Z`;;
                    *.tar.bz2) D=`basename %f .tar.bz2`; set bunzip2 -c;;
                    *.tar.gz)  D=`basename %f .tar.gz`;;
                    *.tar.z)   D=`basename %f .tar.z`;;
                    *.tgz)     D=`basename %f .tgz`;;
                    *.tpz)     D=`basename %f .tpz`;;
                esac
                mkdir "$D"; cd "$D" && ("$1" "$2" ../%f | tar xvf -)

        + t t
        Z       Extract compressed tar files to subdirectories
                for i in %t ; do
                    set gzip -dc
                    unset D
                    case "$i" in
                        *.tar.F)   D=`basename "$i" .tar.F`; set freeze -dc;;
                        *.tar.Z)   D=`basename "$i" .tar.Z`;;
                        *.tar.bz2) D=`basename "$i" .tar.bz2`; set bunzip2 -c;;
                        *.tar.gz)  D=`basename "$i" .tar.gz`;;
                        *.tar.z)   D=`basename "$i" .tar.z`;;
                        *.tgz)     D=`basename "$i" .tgz`;;
                        *.tpz)     D=`basename "$i" .tpz`;;
                  esac
                  mkdir "$D"; (cd "$D" && "$1" "$2" "../$i" | tar xvf -)
                done
      '';
    };
  };
}
