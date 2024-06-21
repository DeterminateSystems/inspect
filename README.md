# Inspect a flake's outputs using flake schemas

From the Determinate Systems blog post about [flake schemas](https://determinate.systems/posts/flake-schemas/):

> While there are a number of “well-known” flake output types that are recognized by tools like the nix CLI—nix develop, for example, operates on the devShells output—nothing prevents you from defining your own flake output types.
>
> Unfortunately, such “non-standard” flake output types have a big problem: tools like nix flake show and nix flake check don’t know anything about them, so they can’t display or check anything about those outputs.

## Examples

Get a flake's output structure, without derivation and store path data.
Excluding derivation and store path data means much less Nix evaluation, and a faster result:

```bash
nix eval --json \
    --override-input flake https://flakehub.com/f/DeterminateSystems/magic-nix-cache/0.1.341 \
    --no-write-lock-file 'https://flakehub.com/f/DeterminateSystems/inspect/*#contents.excludingOutputPaths' \
    | nix run nixpkgs#jq -- .

```

Get a flake's output structure, **with** derivation and store path data.
Collecting derivation and store path data means a more extensive Nix evaluation:

```bash
nix eval --json \
    --override-input flake https://flakehub.com/f/DeterminateSystems/magic-nix-cache/0.1.341 \
    --no-write-lock-file 'https://flakehub.com/f/DeterminateSystems/inspect/*#contents.includingOutputPaths' \
    | nix run nixpkgs#jq -- .

```

## Example Output

The data below is representative of the general structure.
It incudes output paths and derivations, which would not be present in the output in the `contents.excludingOutputPaths` evaluation.

```json
{
  "docs": {
    "devShells": "The `devShells` flake output contains derivations that provide a build environment for `nix develop`.\n",
    "packages": "The `packages` flake output contains packages that can be added to a shell using `nix shell`.\n"
  },
  "inventory": {
    "devShells": {
      "children": {
        "aarch64-darwin": {
          "children": {
            "default": {
              "derivation": "/nix/store/lzfbsl05jw3ixbppm11nmfd4xzj81qhs-nix-shell.drv",
              "forSystems": ["aarch64-darwin"],
              "outputs": {
                "out": "/nix/store/bq48b9naj2ihcwvc8vw6i98pj533qqbh-nix-shell"
              },
              "shortDescription": "",
              "what": "development environment"
            }
          }
        },
        "aarch64-linux": {
          "children": {
            "default": {
              "derivation": "/nix/store/d157gs8aqf2dizpk04wacbvwrzax23dq-nix-shell.drv",
              "forSystems": ["aarch64-linux"],
              "outputs": {
                "out": "/nix/store/s05laifrbik2xs4ri7351hzld857garz-nix-shell"
              },
              "shortDescription": "",
              "what": "development environment"
            }
          }
        }
      }
    },
    "packages": {
      "children": {
        "aarch64-darwin": {
          "children": {
            "default": {
              "derivation": "/nix/store/z593dppy4xjmbkkjasmy92blgzgvnapy-magic-nix-cache-0.2.0.drv",
              "forSystems": ["aarch64-darwin"],
              "outputs": {
                "out": "/nix/store/8lsqcz8vpx0s7mgcj33asrz0f99sr9ag-magic-nix-cache-0.2.0"
              },
              "shortDescription": "",
              "what": "package"
            },
            "magic-nix-cache": {
              "derivation": "/nix/store/z593dppy4xjmbkkjasmy92blgzgvnapy-magic-nix-cache-0.2.0.drv",
              "forSystems": ["aarch64-darwin"],
              "outputs": {
                "out": "/nix/store/8lsqcz8vpx0s7mgcj33asrz0f99sr9ag-magic-nix-cache-0.2.0"
              },
              "shortDescription": "",
              "what": "package"
            },
            "veryLongChain": {
              "derivation": "/nix/store/wdgjivv50ks5d48z54wwrw29kpz9hmqh-chain-200.drv",
              "forSystems": ["aarch64-darwin"],
              "outputs": {
                "out": "/nix/store/zjwhc6sj38cx2mms0nrl76cxaz70qd02-chain-200"
              },
              "shortDescription": "",
              "what": "package"
            }
          }
        },
        "aarch64-linux": {
          "children": {
            "default": {
              "derivation": "/nix/store/nl65gdz60cm3j774yqdfqr4hss5zl45b-magic-nix-cache-0.2.0.drv",
              "forSystems": ["aarch64-linux"],
              "outputs": {
                "out": "/nix/store/6nr5b7kqhxw738fplg22dl16fsalx3kq-magic-nix-cache-0.2.0"
              },
              "shortDescription": "",
              "what": "package"
            },
            "magic-nix-cache": {
              "derivation": "/nix/store/nl65gdz60cm3j774yqdfqr4hss5zl45b-magic-nix-cache-0.2.0.drv",
              "forSystems": ["aarch64-linux"],
              "outputs": {
                "out": "/nix/store/6nr5b7kqhxw738fplg22dl16fsalx3kq-magic-nix-cache-0.2.0"
              },
              "shortDescription": "",
              "what": "package"
            },
            "veryLongChain": {
              "derivation": "/nix/store/zk93kmbhk4b192w8176znd8p1g8wikv1-chain-200.drv",
              "forSystems": ["aarch64-linux"],
              "outputs": {
                "out": "/nix/store/k1nvfr1nq7as02ckh4dd6lwvjxcca5ph-chain-200"
              },
              "shortDescription": "",
              "what": "package"
            }
          }
        }
      }
    }
  },
  "version": 1
}
```
