ASSET_SERVER_URL=http://sensu-asset-server
for FILE in $(ls assets/*.tar.gz)
do
  ASSET_FILE=$(echo $FILE | sed -e 's/assets\///')
  ASSET_NAME=$(echo $ASSET_FILE | sed -e 's/-x86_64//' | sed -e 's/-linux//' | sed -e 's/.tar.gz//')
  MANIFEST_FILE=manifests/assets/local-$(echo $ASSET_FILE | sed -e 's/.tar.gz/.yaml/')
  SHASUM=$(shasum -a 512 $FILE | awk '{ print $1 }')
  echo "---
type: Asset
api_version: core/v2
metadata:
  name: $ASSET_NAME
  namespace: default
spec:
  url: $ASSET_SERVER_URL/assets/$ASSET_FILE
  sha512: $SHASUM " | tee $MANIFEST_FILE
done
