<a href="https://nixos.org" target="_blank" rel="noreferrer"> <img src="https://upload.wikimedia.org/wikipedia/commons/c/c4/NixOS_logo.svg" alt="nixos" height="40"/> </a>
[![Author](https://img.shields.io/badge/author-@FelixLusseau-blue)](https://github.com/FelixLusseau)

# NixFlakes

## My NixOS modules used for my personal setups !

> <picture>
>   <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/light-theme/note.svg">
>   <img alt="Note" src="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/dark-theme/note.svg">
> </picture><br>
>
> This is a module repository. You have to import it into your main Flake like in the example below to use it.

```nix
{
  description = "FL's NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flModules.url = "github:FelixLusseau/NixFlakes"; 
  };

  outputs = { self, nixpkgs, flModules }@inputs:
    let
    in {
      nixosConfigurations = {
        flnix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            flModules.nixosModules.modules
            ./hosts/flnix.nix
          ];
          specialArgs = { inherit inputs; };
        };
      };
    };
}
```

This is my configuration for the GUI, Shell and System.  
A lot of things can be enabled or disabled with the NixOS Options defined in the `modules/default.nix` file following this architecture :
```
options.flcraft
  \_users 
  \_shell
    \_zsh
  \_system
  \_  ssh.enable
    \_hardware
  \_gui
    \_enable
    \_pkgs
      \_messages.enable
      \_programming.enable
      \_art.enable
```
You have to fill the options into your `configuration.nix` equivalent file, dedicated for the current installation.
