{
  description = "Flake with a custom schema mimicking `formatter`, using flake-schema 0.1.4's behavior";

  inputs = { };

  outputs =
    _:
    let
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);

      stubFor =
        system:
        name:
        derivation {
          inherit name system;

          builder = "/bin/sh";
          args = [
            "-c"
            ''
              echo "out: $name/$system" >$out
              echo "doc: $name/$system" >$doc
            ''
          ];

          outputs = [
            "out"
            "doc"
          ];
        };

      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      forEachSystem = f: genAttrs systems (system: f (stubFor system));
    in
    {
      # A flat schema like formatter.${system}
      schemas.bySystem = {
        version = 1;
        doc = ''
          The `bySystem` flake output defines a per-system output, like a flake's `formatter`.
        '';

        appendSystem = true;
        defaultAttrPath = [ ];

        inventory = output: {
          children = builtins.mapAttrs
            (system: pkg: {
              what = "bySystem";
              forSystems = [ system ];
              shortDescription = pkg.meta.description or "";
              derivation = pkg;
            })
            output;
        };
      };

      bySystem = forEachSystem (stub: stub "simple");
    };
}
