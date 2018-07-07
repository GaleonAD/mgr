#!/bin/bash

################################################################################
# Reading the name and cleaning last build
################################################################################

set -e

texname=$1
texlen=${#texname}-4
texname=${texname:0:$texlen}
#texname="input"
outtexname="output"

if [ ! -e $texname".tex" ]; then
    echo "$texname.tex doesn't exist. Exiting..."
    exit 1
fi

echo -n "Cleaning last build... "
rm -rf .build
echo "OK"

set +e

################################################################################
# generate all plots
################################################################################
# comented becouse can slow generating a lot...

#cd gnuScripts
#if ls *.gnuplot &>/dev/null; then
#    for f in  *.gnuplot; do
#        echo -n "Generating $f... "
#        chmod u+x $f
#        ./$f &>/dev/null
#        echo "OK"
#    done
#fi
#cd ..

################################################################################
# Copying everything into building directory
################################################################################
echo -n "Recreating build directory and copying files... "
mkdir -p .build
for file in *.tex *.plt *.data *.eps *.png *jpg *.sty *.pdf *.bib images/*; do
    if [ -f $file ]; then
        cp -r $file .build
        if [ $? -ne 0 ]; then
            exit 1
        fi
    fi
done
echo "OK"

cd .build


################################################################################
# compile texfile for the first time
################################################################################
echo -n "Generating $outtexname... "
pdflatex -interaction=nonstopmode $texname.tex 1>/dev/null


if [ $? -ne 0 ]; then
    echo ""
    rm -f $texname.aux
    pdflatex $texname.tex
    exit 1
else
    echo "OK"
fi


################################################################################
# generating bibliography
################################################################################
echo -n "Generating bibliography... "
bibtex $texname.aux > /dev/null 
echo "OK"


################################################################################
# compile texfile two more times, to be sure
################################################################################
echo -n "Generating to more times to set up bibliography... "
pdflatex -interaction=nonstopmode $texname.tex 1>/dev/null
pdflatex -interaction=nonstopmode $texname.tex 1>/dev/null
echo "OK"

set -e

################################################################################
# copy output name to main directory
################################################################################
cd ..
cp .build/$texname.pdf ./$outtexname.pdf
echo "Output copied to "`pwd`"/$outtexname.pdf"

