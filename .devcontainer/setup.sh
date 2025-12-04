#!/bin/bash
set -e

git config --global url."https://x-access-token:${GITHUB_TOKEN}@github.com/".insteadOf "git@github.com:"
git submodule update --init --recursive
export DYNAMIC_REPO_PATH=${DYNAMIC_REPO_PATH}
git clone https://x-access-token:${GITHUB_TOKEN}@github.com/${DYNAMIC_REPO_PATH}.git data/project-repository

if [ ! -d "data/project-repository" ]; then
    echo "Error: Failed to clone repository into data/project-repository."
    exit 1
fi

cd data/project-repository
git checkout ${PARENT_COMMIT}

yarn install
export NODE_OPTIONS=--openssl-legacy-providerexport NODE_OPTIONS=--openssl-legacy-provider
yarn lerna run build --scope netlify-cms-app --include-dependencies
unset NODE_OPTIONS

sudo bash -c 'cat << EOF > /usr/local/bin/sprout-run
#!/bin/bash
# Open the test file in the current VS Code window (-r = reuse window)
code -r /workspaces/sprout-user-decapCMS/data/project-repository/dev-test/index.html
EOF'

sudo chmod +x /usr/local/bin/sprout-run