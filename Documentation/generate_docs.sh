rm -rf docs
mkdir docs
sourcekitten doc --spm --module-name Fluxor > docs/mod1.json
sourcekitten doc --spm --module-name FluxorTestSupport > docs/mod2.json
jazzy --sourcekitten-sourcefile docs/mod1.json,docs/mod2.json --head '<link rel="stylesheet" type="text/css" href="css/fluxor.css">'
cp Documentation/fluxor.css docs/css/fluxor.css
open docs/index.html
