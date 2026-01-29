let
  pkgs = import <nixpkgs> { config.allowUnfree = true; };

in pkgs.mkShell {
  packages = [
    # 1. Use the standard pre-compiled Python 3.10
    pkgs.python312
    pkgs.python312Packages.dbt-snowflake
  ];

  shellHook = ''
    dbt --version
  '';
}

