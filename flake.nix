{
  outputs = {self, nixpkgs, ... }: let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    pythonEnv = pkgs.python3.withPackages (ps: with ps; [
      mkdocs
      mkdocs-material
      pillow
      cairosvg
    ]);
  in {
    packages.${system} = {
      website = pkgs.runCommand "website"
        {
          buildInputs = [
            pythonEnv
          ];
        }
        ''
          cp -r ${./.} ./source
          chmod -R +w ./source
          cd ./source
          mkdocs build
          mv site $out
        '';
      deploy = pkgs.writeScriptBin "deploy" ''
        #!${pkgs.bash}/bin/bash
        set -Eeuo pipefail
        export PATH="${lib.makeBinPath [
          pkgs.coreutils
          pkgs.gitMinimal
          pkgs.rsync
          pkgs.openssh
        ]}"
        export TMPDIR=$(${pkgs.coreutils}/bin/mktemp -d)
        trap "${pkgs.coreutils}/bin/chmod -R +w '$TMPDIR'; ${pkgs.coreutils}/bin/rm -rf '$TMPDIR'" EXIT

        set -x
        cd $TMPDIR
        git clone --depth 1 --branch gh-pages git@github.com:oceansprint/thaigersprint.org ./site
        cd ./site
        rm -rf $(ls .)
        rsync -r ${self.packages.${system}.website}/ .
        git checkout gh-pages CNAME
        chmod +w -R .
        git add .
        git commit -m "deploy website - $(date --rfc-3339=seconds)" || :
        git push
      '';
    };
  };
}
