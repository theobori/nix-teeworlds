{ inputs, ... }: _final: prev: { inherit (inputs.self.packages.${prev.system}) fixed-ddnet-server; }
