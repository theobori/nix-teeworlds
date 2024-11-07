{ inputs, ... }: _final: prev: { inherit (inputs.self.packages.${prev.system}) fng2-server; }
