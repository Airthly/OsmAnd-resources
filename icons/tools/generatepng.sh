#!/bin/bash

pushd . > /dev/null
cd `dirname $BASH_SOURCE` > /dev/null
BASEFOLDER=`pwd`;
popd  > /dev/null
BASEFOLDER=`dirname $BASEFOLDER`

FOLDERS=(big-xxhdpi big-xhdpi big-hdpi big-mdpi xxhdpi xhdpi hdpi mdpi)
FOLDERS_NOMX=(xxhdpi xhdpi hdpi mdpi) # no icons used in osmand interface (search, poi overlay)
SIZES=(96 64 48 32 48 32 24 16)
SIZESx2=(96 64 48 32 96 64 48 32)
SIZESx4=(96 64 48 32 192 128 96 64)

FOLDERS_ORIG=("${FOLDERS[@]}")
SIZES_ORIG=("${SIZES[@]}")

SVGFOLDER=${BASEFOLDER}/svg/
OUTPUTFOLDER=${BASEFOLDER}/png/

if [ ! -d "${OUTPUTFOLDER}" ]; then
  mkdir ${OUTPUTFOLDER}
fi

for (( i = 0 ; i < ${#FOLDERS[@]} ; i++ )) do
  mkdir -p ${OUTPUTFOLDER}/${FOLDERS[i]}
done

generateElements() {
  TYPE=$1
  for FILE in $SVGFOLDER$1/*.svg; do
      FILENAME=${FILE##/*/}
      if [[ $FILENAME == _* ]]; then
        continue;
      fi
      FILENAME=${FILENAME%.*}
      rsvg -f png ${FILE} -x 1 -y 1 ${OUTPUTFOLDER}mdpi/${FILENAME}.png
      rsvg -f png ${FILE} -x 1.5 -y 1.5 ${OUTPUTFOLDER}hdpi/${FILENAME}.png
      rsvg -f png ${FILE} -x 2 -y 2 ${OUTPUTFOLDER}xhdpi/${FILENAME}.png
      rsvg -f png ${FILE} -x 3 -y 3 ${OUTPUTFOLDER}xxhdpi/${FILENAME}.png
  done
}

generatePngs() {
  TYPE=$1
  COLOR=$2 # color for map icons(mm_*)
  COLOR2=$3 # color for osmand interface icons (poi layer,search) (mx_)
  NEG=$4
  X2_ICONS=$5
  X4_ICONS=$6
  NO_MX=$7
  echo "On : $TYPE : $X2_ICONS $X4_ICONS $NO_MX"
  if [ "$X4_ICONS" = 'x4' ]
    then
     SIZES=("${SIZESx4[@]}")
     echo " x4  ${SIZES[@]}"
    else
     SIZES=("${SIZES_ORIG[@]}")
     echo "     ${SIZES[@]} "
  fi
  if [ "$X2_ICONS" = 'x2' ]
    then
     SIZES=("${SIZESx2[@]}")
     echo " x2  ${SIZES[@]}"
  fi

  if [ "$NO_MX" = 'nomx' ]
    then
	let "SIZES_HALF=${#SIZES[@]} / 2"
	SIZES=("${SIZES[@]:$SIZES_HALF}")
	echo "nomx:"${SIZES[@]}
	FOLDERS=("${FOLDERS_NOMX[@]}")
	echo "     ${FOLDERS[@]}"
    else
	FOLDERS=("${FOLDERS_ORIG[@]}")
 	echo "     ${FOLDERS[@]}"
 fi
  for FILE in $SVGFOLDER$1/*.svg; do
      FILENAME=${FILE##/*/}
      if [[ $FILENAME == _* ]]; then
        continue;
      fi
      FILENAME=${TYPE}_${FILENAME%.*}
      for (( j = 0 ; j < ${SIZES_HALF}; j++ )) do
        OUTF=${OUTPUTFOLDER}${FOLDERS[j]}/
        if [[ -z $NEG ]]; then
          ${BASEFOLDER}/tools/recolourtopng.sh ${FILE} 'none' 'none' $COLOR2 ${SIZES[j]} ${OUTF}${FILENAME} > /dev/null 2>&1
        else
          ${BASEFOLDER}/tools/recolourtopng.sh ${FILE} $COLOR2 $COLOR2 '#ffffff'  ${SIZES[j]} ${OUTF}${FILENAME} > /dev/null 2>&1
        fi
        # convert ${OUTF}${FILENAME}.png \( +clone -background "#ffffff" -shadow 8000x2-0+0 \) +swap -background none -layers merge +repage -trim ${OUTF}${FILENAME}_glow.png
      done
      for (( j = ${SIZES_HALF} ; j < ${#SIZES[@]}; j++ )) do
        OUTF=${OUTPUTFOLDER}${FOLDERS[j]}/
        if [[ -z $NEG ]]; then
          ${BASEFOLDER}/tools/recolourtopng.sh ${FILE} 'none' 'none' $COLOR ${SIZES[j]} ${OUTF}${FILENAME} > /dev/null 2>&1
        else
          ${BASEFOLDER}/tools/recolourtopng.sh ${FILE} $COLOR $COLOR '#ffffff'  ${SIZES[j]} ${OUTF}${FILENAME} > /dev/null 2>&1
        fi
      done

    done
}

      generateElements 'shaders'
      generateElements 'osmc'
      generatePngs 'seamark' '#777777' '#777777' '' x2 '' nomx
      generatePngs 'seamark_small' '#777777' '#777777' '' '' '' nomx
      generatePngs 'seamark_big' '#777777' '#777777' '' '' x4 nomx
      generateElements 'seamark_shields'
      generateElements 'seamark_shields_x4'

      generatePngs 'skimap' '#777777' '#777777' '' x2

      generatePngs 'functional-icons' '#777777' '#777777'
      generatePngs 'water' '#0092DA' '#0092DA'

      generatePngs 'emergency' '#DA0092' '#DA0092'
      generatePngs 'health' '#DA0092' '#DA0092'

      generatePngs 'transport' '#0092DA' '#0092DA'

      generatePngs 'barrier' '#444444' '#777777'

      generatePngs 'accommodation' '#0092DA' '#0092DA'

      generatePngs 'tourist' '#734A08' '#734A08'
      generatePngs 'special_poi' '#a62b00' '#a62b00' '' '' '' nomx

      generatePngs 'sport'  '#39AC39' '#39AC39'

      generatePngs 'amenity' '#777777' '#777777'
      generatePngs 'place_of_worship' '#333333' '#777777'
      generatePngs 'money' '#777777' '#777777'
      generatePngs 'education' '#777777' '#777777'
      generatePngs 'poi' '#3f3f3f' '#777777'
      generatePngs 'power' '#3f3f3f' '#777777'

      generatePngs 'food' '#777777' '#777777'

      generatePngs 'shopping' '#777777' '#777777'

      generatePngs 'landuse' '#777777' '#777777'

      generatePngs 'icons8' '#777777' '#777777' neg

      generatePngs 'overlays' '#777777' '#777777' '' x2 '' nomx