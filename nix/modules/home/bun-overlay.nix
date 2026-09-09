{ ... }:
{
	nixpkgs.overlays = [
		(final: prev: rec {
			bun = prev.bun.overrideAttrs (oldAttrs: rec {
				version = "1.4.2";
				passthru = oldAttrs.passthru // {
					sources = {
						"aarch64-darwin" = prev.fetchurl {
							url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-aarch64.zip";
							hash = "sha256-kJh6OhbX21VtiGrD1VHnttPt8KHPQ6yu1iLoZ2vh0S8=";
						};
						"aarch64-linux" = prev.fetchurl {
							url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-aarch64.zip";
							hash = "sha256-VDKLvC2cjgyfiSxUTWbFeoO4QTnjSQnl7oF1jxrI/ac=";
						};
						"x86_64-darwin" = prev.fetchurl {
							url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-x64-baseline.zip";
							hash = "sha256-utW71s8U0JgNEV9ZVMn/kE32GdXplNLaH/zNPzFjALA=";
						};
						"x86_64-linux" = prev.fetchurl {
							url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64.zip";
							hash = "sha256-NjaPrvdSeHXV/6UuU81IAhdB8qg+tiCKjdZAaNQiqRM=";
						};
					};
				};
				src =
					passthru.sources.${prev.stdenvNoCC.hostPlatform.system}
						or (throw "Unsupported system: ${prev.stdenvNoCC.hostPlatform.system}");
			});
		})
	];
}
