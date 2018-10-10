for FILE in $(ls assets/*.tar.gz)
do
  NEWFILE=$(echo $FILE | sed -e 's/.tar.gz/.sha512.txt/')
  shasum -a 512 $FILE > $NEWFILE 
done
