{
  prsJSON,
  nixpkgs,
}: let
  pkgs = import nixpkgs {};
  prs = builtins.fromJSON (builtins.readFile prsJSON);
  systems = ["x86_64-linux" "aarch64-linux"];
  nixpkgs_version = ["master"];
  mkJobsets = system: version:
    (pkgs.lib.mapAttrs' (
        num: info: {
          name = "${system}-${version}-pr${num}";
          value = {
            enabled = 1;
            hidden = false;
            description = "PR ${num} (${system}-${version}): ${info.title}";
            nixexprinput = "nix-packages";
            nixexprpath = "hydra/default.nix";
            checkinterval =
              if info.head.repo.owner.login == "darkkirb" && info.head.repo.name == "nix-packages" # Don’t need to manually check
              then 0
              else 300;
            schedulingshares = 100;
            enableemail = false;
            emailoverride = "";
            keepnr = 1;
            inputs = {
              nix-packages = {
                type = "git";
                value = "https://github.com/${info.head.repo.owner.login}/${info.head.repo.name}.git ${info.head.ref}";
                emailresponsible = false;
              };
              nixpkgs = {
                type = "git";
                value = "https://github.com/NixOS/nixpkgs.git ${version}";
                emailresponsible = false;
              };
              system = {
                type = "string";
                value = system;
              };
            };
          };
        }
      )
      prs)
    // {
      "${system}-${version}" = {
        enabled = 1;
        hidden = false;
        description = "nix-packages ${system}-${version}";
        nixexprinput = "nix-packages";
        nixexprpath = "hydra/default.nix";
        checkinterval = 0;
        schedulingshares = 100;
        enableemail = false;
        emailoverride = "";
        keepnr = 1;
        inputs = {
          nix-packages = {
            type = "git";
            value = "https://github.com/DarkKirb/nix-packages.git main";
            emailresponsible = false;
          };
          nixpkgs = {
            type = "git";
            value = "https://github.com/NixOS/nixpkgs.git ${version}";
            emailresponsible = false;
          };
          system = {
            type = "string";
            value = system;
          };
        };
      };
    };

  concatAttrs = pkgs.lib.foldr (a: b: a // b) {};

  jobsets =
    (concatAttrs (pkgs.lib.concatMap (system: map (version: mkJobsets system version) nixpkgs_version) systems))
    // {
      nix-packages-flake = {
        enabled = 1;
        hidden = false;
        description = "nix-packages flake";
        nixexprinput = "nix-packages";
        nixexprpath = "hydra/parse-flake.nix";
        checkinterval = 0;
        schedulingshares = 100;
        enableemail = false;
        emailoverride = "";
        keepnr = 1;
        inputs = {
          flake = {
            type = "git";
            value = "https://github.com/DarkKirb/nix-packages.git main";
            emailresponsible = false;
          };
        };
      };
    };
in {jobsets = pkgs.writeText "jobsets.json" (builtins.toJSON jobsets);}
