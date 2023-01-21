{
  prsJSON,
  nixpkgs,
}: let
  pkgs = import nixpkgs {};
  prs = builtins.fromJSON (builtins.readFile prsJSON);
  systems = ["x86_64-linux" "aarch64-linux" "riscv64-linux"];
  nixpkgs_version = ["master" "nixos-22.05"];
  mkJobsets = system: version:
    (pkgs.lib.mapAttrs (
        num: info: {
          enabled = 1;
          hidden = false;
          description = "PR ${num} (${system}-${version}): ${info.title}";
          nixexprinput = "nix-packages";
          nixexprpath = "hydra/default.nix";
          checkinterval = 60;
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
        }
      )
      prs)
    // {
      main = {
        enabled = 1;
        hidden = false;
        description = "nix-packages ${system}-${version}";
        nixexprinput = "nix-packages";
        nixexprpath = "hydra/default.nix";
        checkinterval = 60;
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

  mapToAttrs = f: list: pkgs.lib.listToAttrs (map f list);

  jobsets =
    mapToAttrs (system: {
      name = system;
      value =
        mapToAttrs (version: {
          name = version;
          value = mkJobsets system version;
        })
        nixpkgs_version;
    })
    systems;
in {jobsets = pkgs.writeText "jobsets.json" (builtins.toJSON jobsets);}
