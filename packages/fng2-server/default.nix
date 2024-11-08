{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  python311,
  gtest,
  zlib,
  wavpack,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "fng2-server";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "Jupeyy";
    repo = "teeworlds-fng2-mod";
    rev = finalAttrs.version;
    hash = "sha256-kJdh8jiKY2VO95szv75NPyebOO8JuuxW3jKL5qmKpcs=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  nativeCheckInputs = [ gtest ];

  buildInputs = [
    python311
    zlib
    wavpack
  ];

  postPatch = ''
    substituteInPlace src/engine/shared/storage.cpp \
      --replace-fail /usr/ $out/ \
      --replace-fail teeworlds/ fng/

    substituteInPlace src/game/server/gamecontext.cpp \
      --replace-fail intptr_t "int"

    rm -rf src/engine/external/wavpack
    rm -rf src/engine/external/zlib
  '';

  cmakeFlags = [ "-DCLIENT=OFF" ];

  meta = {
    description = "FNG mod for teeworlds, that advances the original FNG idea by golden spikes and other features";
    homepage = "https://github.com/Jupeyy/teeworlds-fng2-mod/tree/fng_06";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ theobori ];
    mainProgram = "fng2_srv";
    platforms = lib.platforms.unix;
  };
})
