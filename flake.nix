{
  description = "Tokyo Night SDDM theme as a Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        f pkgs
      );
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.stdenvNoCC.mkDerivation rec {
          pname = "tokyo-night-sddm";
          version = "1.0";

          src = self;

          dontWrapQtApps = true;
          buildInputs = with pkgs.libsForQt5.qt5; [ qtgraphicaleffects ];

          installPhase =
            let
              iniFormat = pkgs.formats.ini { };
              # Optionally allow overriding config via flake input
              themeConfig = null;
              configFile = iniFormat.generate "" { General = themeConfig; };

              basePath = "$out/share/sddm/themes/tokyo-night";
            in
            ''
              mkdir -p ${basePath}
              cp -r $src/* ${basePath}
            ''
            + pkgs.lib.optionalString (themeConfig != null) ''
              ln -sf ${configFile} ${basePath}/theme.conf.user
            '';

          meta = with pkgs.lib; {
            description = "Tokyo Night SDDM theme";
            homepage = "https://github.com/deephack1982/tokyo-night-sddm";
            license = licenses.gpl3;
            platforms = platforms.linux;
            maintainers = with pkgs.lib.maintainers; [ deephack1982 ];
          };
        };
      });

      overlays.default = final: prev: {
        tokyo-night-sddm = self.packages.${prev.system}.default;
      };
    };
}
