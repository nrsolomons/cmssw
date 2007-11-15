#!/bin/tcsh

if ( $1 < 10 ) then 
    set Run = "00000$1"
else if ( $1 < 100 ) then
    set Run = "0000$1"
else if ( $1 < 1000 ) then
    set Run = "000$1"
else if ( $1 < 10000 ) then
    set Run = "00$1"
else if ( $1 < 100000 ) then
    set Run = "0$1"
else if ( $1 < 1000000 ) then
    set Run = "$1"
endif

echo "Run: $Run"

set InputDir = "."
set files = `ls $InputDir/LS_"$Run"_??????.root`

if( `echo $files` != '' ) then

set TreeName = "LumiTree"
set ChainName = "LumiChain"
set ScriptName = "LumiCat.C"
set DictName = "/uscms/home/ahunt/CMSSW_1_6_6/lib/slc4_ia32_gcc345/libRecoLuminosityROOTSchema.so"
set OutputFile = "Run/Lumi_$Run.root"
set FileTitle = "Luminosity - Run Number $Run"

cat >> $ScriptName <<EOF
{
    gSystem->Load("$DictName");

    TFile *OutputFile;
    TTree *OutputTree;

    TChain $ChainName("$TreeName");
EOF

if ( `ls $OutputFile` == `echo $OutputFile` ) then
cat >> $ScriptName <<EOF
    $ChainName.Add("$OutputFile");
EOF

endif

foreach file ($files) 

cat >> $ScriptName <<EOF
    $ChainName.Add("$file");
EOF

end

cat >> $ScriptName <<EOF

    OutputFile = new TFile("Temp.root","RECREATE","$FileTitle",1);
    OutputTree = $TreeName->CloneTree();

    OutputFile->Write();
    OutputFile->Close();
    delete OutputFile;
}
EOF

root -b -q .x $ScriptName
rm $ScriptName

mkdir -p $Run

foreach file ($files)
  mv $file $Run/
end

mv Temp.root $OutputFile

else

echo "No files to concatenate for run $1"

endif
