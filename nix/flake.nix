{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # ghostty (until it comes to nixpkgs)
    ghostty.url = "github:ghostty-org/ghostty";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ghostty,
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
