{
  description = "Flake with a custom schema where the derivation has no `outputs` attribute, using flake-schema 0.3.0's behavior";

  inputs = { };

  outputs =
    _:
    let
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);

      stubFor =
        system:
        name:
        {
          default =
            derivation {
              inherit name system;

              builder = "/bin/sh";
              args = [
                "-c"
                ''
                  echo "out: $name/$system" >$out
                ''
              ];
            };
        };

      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      forEachSystem = f: genAttrs systems (system: f (stubFor system));
    in
    {
      packages = forEachSystem (stub: stub "simple");
    };
}
