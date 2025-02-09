{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @inputs: let
    inherit (self) outputs;
    system = "x86_64-linux";
    host = "nixos";
    username = "trevorj";
  in {
    nixosConfigurations."${host}" = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit system; inherit inputs; inherit username; inherit host; };
      modules = [
        ./nixos/configuration.nix 

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./home-manager/home.nix;
          home-manager.extraSpecialArgs = {inherit inputs outputs; };
        }
      ];
    };
  };
}
