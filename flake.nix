{
  inputs.flake.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*";
  outputs = inputs:
    let
      getFlakeOutputs = flake: includeOutputPaths:
        let

          # Helper functions.

          mapAttrsToList = f: attrs: map (name: f name attrs.${name}) (builtins.attrNames attrs);

          try = e: default:
            let res = builtins.tryEval e;
            in if res.success then res.value else default;

          mkChildren = children: { inherit children; };

          flakeSchemasFlakePinned = "https://api.flakehub.com/f/pinned/DeterminateSystems/flake-schemas/0.1.4/0190e653-dd76-70bd-ba6e-a3f5eaf3d415/source.tar.gz?narHash=sha256-efoDF3VaZHpcwFd2Y1axGLqNX/ou9kDL7z9mWNqzv9w%3D";
        in

        rec {

          allSchemas = (flake.outputs.schemas or defaultSchemas) // schemaOverrides;

          # FIXME: make this configurable
          defaultSchemas = (builtins.getFlake flakeSchemasFlakePinned).schemas;

          # Ignore legacyPackages for now, since it's very big and throws uncatchable errors.
          schemaOverrides.legacyPackages = {
            version = 1;
            doc = ''
              The `legacyPackages` flake output is similar to `packages`, but it can be nested (i.e. contain attribute sets that contain more packages).
              Since enumerating the packages in nested attribute sets is inefficient, `legacyPackages` should be avoided in favor of `packages`.

              Note: the contents of `legacyPackages` are not shown in FlakeHub.
            '';
            inventory = output: mkChildren { };
          };

          schemas =
            builtins.listToAttrs (builtins.concatLists (mapAttrsToList
              (outputName: output:
                if allSchemas ? ${outputName} then
                  [{ name = outputName; value = allSchemas.${outputName}; }]
                else
                  [ ])
              flake.outputs));

          docs =
            builtins.mapAttrs (outputName: schema: schema.doc or "<no docs>") schemas;

          uncheckedOutputs =
            builtins.filter (outputName: ! schemas ? ${outputName}) (builtins.attrNames flake.outputs);

          inventoryFor = filterFun:
            builtins.mapAttrs
              (outputName: schema:
                let
                  doFilter = attrs:
                    if filterFun attrs
                    then
                      if attrs ? children
                      then
                        mkChildren (builtins.mapAttrs (childName: child: doFilter child) attrs.children)
                      else
                        {
                          forSystems = attrs.forSystems or null;
                          shortDescription = attrs.shortDescription or null;
                          what = attrs.what or null;
                          #evalChecks = attrs.evalChecks or {};
                        } // (
                          if includeOutputPaths then
                            {
                              derivation =
                                if attrs ? derivation
                                then builtins.unsafeDiscardStringContext attrs.derivation.drvPath
                                else null;
                              outputs =
                                if attrs ? derivation
                                then
                                  builtins.listToAttrs
                                    (
                                      builtins.map
                                        (outputName:
                                          {
                                            name = outputName;
                                            value = attrs.derivation.${outputName}.outPath;
                                          }
                                        )
                                        attrs.derivation.outputs
                                    )
                                else
                                  null;
                            }
                          else
                            { }
                        )
                    else
                      { };
                in
                doFilter ((schema.inventory or (output: { })) flake.outputs.${outputName})
              )
              schemas;

          inventoryForSystem = system: inventoryFor (itemSet:
            !itemSet ? forSystems
            || builtins.any (x: x == system) itemSet.forSystems);

          inventory = inventoryFor (x: true);

          contents = {
            version = 1;
            inherit docs;
            inherit inventory;
          };

        };
    in
    {
      contents.includingOutputPaths =
        (getFlakeOutputs inputs.flake true).contents;
      contents.excludingOutputPaths =
        (getFlakeOutputs inputs.flake false).contents;


      schemas.contents = {
        version = 1;
        doc = ''
          The `contents` flake output exposes the discovered outputs of a flake, using flake schemas.
          See: https://determinate.systems/posts/flake-schemas/
        '';
        inventory = _output:
          {
            children = {
              includingOutputPaths = {
                shortDescription = "Discovered flake outputs which include metadata about derivations, outputs, and derivation output paths.";
              };
              excludingOutputPaths = {
                shortDescription = "Discovered flake outputs which evaluates more quickly because it doesn't include metadata about derivations, outputs, and derivation output paths.";
              };
            };
          };
      };
    };
}
