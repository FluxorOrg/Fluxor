rm -rf docs
sourcekitten doc --spm --module-name Fluxor > mod1.json
sourcekitten doc --spm --module-name FluxorTestSupport > mod2.json
sourcekitten doc --spm --module-name FluxorSwiftUI > mod3.json
jazzy --sourcekitten-sourcefile mod1.json,mod2.json,mod3.json
open docs/index.html
