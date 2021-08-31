{
  description = "Personal Wallpapers";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable-small;

  outputs = { self, nixpkgs }:
    let
      inherit (builtins) baseNameOf concatStringsSep;
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      args = { authors = import ./authors.nix { inherit (pkgs.lib) maintainers; }; };

      mkMarkdown = height: images:
        pkgs.writeText "images.md"
          (concatStringsSep "\n"
            (map
              (it:
                if height != null
                then ''<img src="${baseNameOf it.image}" alt="By ${it.author.name}" height="${toString height}"/>''
                else ''<img src="${baseNameOf it.image}" alt="By ${it.author.name}"/>''
              )
              images));
    in
    {

      packages.x86_64-linux = rec {
        wallpapersMd = mkMarkdown null (import ./wallpapers args);

        build-markdown = pkgs.writeScriptBin "build-markdown" ''
          cd $(git rev-parse --show-toplevel)
          cat ${wallpapersMd} > wallpapers/README.md
        '';
      };

    };
}
