DEMO_MANIFEST="manifests/demo.yaml"
if [[ -e $DEMO_MANIFEST ]]; then
  echo "Regenerating the concatenated manifest file located at $DEMO_MANIFEST"
  rm $DEMO_MANIFEST
fi;
for MANIFEST in $(ls manifests/**/*.yaml)
do
  cat $MANIFEST >> $DEMO_MANIFEST
  echo "" >> $DEMO_MANIFEST
done
