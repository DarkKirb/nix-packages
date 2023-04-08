{
  prsJSON,
  nixpkgs,
}: let
  pkgs = import nixpkgs {};
  prs = builtins.fromJSON (builtins.readFile prsJSON);
  systems = ["x86_64-linux" "aarch64-linux"];
  nixpkgs_version = ["master"];
  mkJobsets = system: version:
    (builtins.listToAttrs (
      map (
        info: {
          name = "${system}-${version}-pr${toString info.number}";
          value = {
            enabled = info.state == "open";
            hidden = info.state != "open";
            description = "PR ${toString info.number} (${system}-${version}): ${info.title}";
            nixexprinput = "nix-packages";
            nixexprpath = "hydra/default.nix";
            checkinterval = 3600;
            schedulingshares = 100;
            enableemail = false;
            emailoverride = "";
            keepnr = 1;
            inputs = {
              nix-packages = {
                type = "git";
                value = "${info.head.repo.clone_url} ${info.head.ref}";
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
              gitea_status_repo = {
                type = "string";
                value = "nix-packages";
                emailresponsible = false;
              };
              gitea_repo_owner = {
                type = "string";
                value = "${info.head.repo.owner.login}";
                emailresponsible = false;
              };
              gitea_repo_name = {
                type = "string";
                value = "${info.head.repo.name}";
                emailresponsible = false;
              };
            };
          };
        }
      )
      prs
    ))
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
            value = "https://git.chir.rs/darkkirb/nix-packages main";
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
          gitea_status_repo = {
            type = "string";
            value = "nix-packages";
            emailresponsible = false;
          };
          gitea_repo_owner = {
            type = "string";
            value = "darkkirb";
            emailresponsible = false;
          };
          gitea_repo_name = {
            type = "string";
            value = "nix-packages";
            emailresponsible = false;
          };
        };
      };
    };
  concatAttrs = pkgs.lib.foldr (a: b: a // b) {};

  jobsets =
    concatAttrs (pkgs.lib.concatMap (system: map (version: mkJobsets system version) nixpkgs_version) systems);
in {jobsets = pkgs.writeText "jobsets.json" (builtins.toJSON jobsets);}
