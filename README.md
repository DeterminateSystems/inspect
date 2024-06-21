```nix
nix eval --json --no-write-lock-file \
    --override-input flake "your flake URL" \
    'https://flakehub.com/f/DeterminateSystems/inspect/*#contents'
```
