rm -rf docs
mkdir docs
sourcekitten doc --spm --module-name Fluxor > docs/mod1.json
sourcekitten doc --spm --module-name FluxorTestSupport > docs/mod2.json
sourcekitten doc --spm --module-name FluxorSwiftUI > docs/mod3.json
jazzy --sourcekitten-sourcefile docs/mod1.json,docs/mod2.json,docs/mod3.json
open docs/index.html
