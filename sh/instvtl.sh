#!/bin/zsh

# 0) Some useful configuration
echo "Setting up variables"
export DEVNUM=08
export PASS=mase58yu
#export CASTORPACKAGESROOT="/afs/cern.ch/project/castor/www/DIST/intReleases/2.1.12-0"
export CASTORPACKAGESROOT="/afs/cern.ch/project/castor/www/DIST/CERN/savannah/CASTOR.pkg/2.1.11-\*/2.1.11-0/"

export DEVNAME=dev${DEVNUM}
export DEVHEADNODES=lxcastordev${DEVNUM}
export ONEHEADNODE=`echo ${DEVHEADNODES} | sed 's/^\([^ ]*\).*$/\1/'`
export DEVDISKSERVERS="`wassh -c castordev/dev${DEVNUM} -e "$DEVHEADNODES" --list | xargs`"
export CUPVDBACCOUNT=cupv_dev${DEVNUM}
export VMGRDBACCOUNT=vmgr_dev${DEVNUM}
export VDQMDBACCOUNT=vdqm_dev${DEVNUM}
export DEVDISKSERVERNUMS="`echo ${DEVDISKSERVERS} | sed 's/\b\w*\(\w\w\)\b/\1/g' | xargs`"
DEVDISKSERVERSARRAY=( `echo ${DEVDISKSERVERS}`)
DEVDISKSERVERNUMSARRAY=( `echo ${DEVDISKSERVERNUMS}`)
export DEVPOOLNAME="stager_dev${DEVNUM}"
export CUPVPASS=${PASS}
export VMGRPASS=${PASS}
export VDQMPASS=${PASS}

export DEVNAME=castorcert5
export DEVHEADNODES="lxbrl2708 lxbrl2709"
export ONEHEADNODE=`echo ${DEVHEADNODES} | sed 's/^\([^ ]*\).*$/\1/'`
export DEVDISKSERVERS="`wassh -c castordev/castorcert5 -e "$DEVHEADNODES" --list | xargs`"
export CUPVDBACCOUNT=castorcupv
export VMGRDBACCOUNT=castorvmgr
export VDQMDBACCOUNT=castorvdqm
export DEVDISKSERVERNUMS="`echo $DEVDISKSERVERS | wc -w | xargs seq -f '%02g' | xargs`"
DEVDISKSERVERSARRAY=( `echo ${DEVDISKSERVERS}`)
DEVDISKSERVERNUMSARRAY=( `echo ${DEVDISKSERVERNUMS}`)
export DEVPOOLNAME="virtual_default"
export CUPVPASS="Mapu3aX2"
export VMGRPASS="Mapu3aX4"
export VDQMPASS="Mapu3aX3"

# 1) Sindes
echo "Dealing with Sindes"
export BASEDIR=/tmp/${DEVNAME}-virtual
mkdir -p ${BASEDIR}
echo "  Getting headnodes's tar files"
for headnode in ${DEVHEADNODES}; do mkdir ${BASEDIR}/${headnode}; scp root@sindes-server:/home/sindes/rfiles/castordev/${headnode}/castor-ora-config.tar.gz ${BASEDIR}/${headnode}/castor-ora-config.tar.gz; done
echo "  Modifying headnodes's tar files and sending them back"
for headnode in ${DEVHEADNODES}; do
  cd ${BASEDIR}/$headnode;
  tar xvfz castor-ora-config.tar.gz;
  scp root@lxcastordev01:/etc/castor/ORAVDQMCONFIG castor-ora-config;
  sed -i -e "s/\(passwd  *\)[^ ]*/\1${VDQMPASS}/" -e "s/\(user  *\)vdqm_dev../\1${VDQMDBACCOUNT}/" castor-ora-config/ORAVDQMCONFIG;
  scp root@lxcastordev01:/etc/castor/CUPVCONFIG castor-ora-config;
  sed -i "s/^cupv_dev..\/[^@]*/${CUPVDBACCOUNT}\/${CUPVPASS}/" castor-ora-config/CUPVCONFIG;
  scp root@lxcastordev01:/etc/castor/VMGRCONFIG castor-ora-config;
  sed -i "s/^vmgr_dev..\/[^@]*/${VMGRDBACCOUNT}\/${VMGRPASS}/" castor-ora-config/VMGRCONFIG;
  tar cvfz castor-ora-config.tar.gz castor-ora-config/;
  sindes-upload-file -s node -m file -f castor-ora-config.tar.gz -i castor-ora-config -S sindes-server -t ${headnode};
done;

# 2) DBs
echo "Creating DBs"
echo "  cupv"
CUPVDBINPUT="connect ${CUPVDBACCOUNT}/${CUPVPASS}@c2castordevdb\n@${CASTORPACKAGESROOT}/dbcreation/cupv_oracle_create.sql\nexit\n"
echo $CUPVDBINPUT | sqlplus -S /NOLOG
echo "  vmgr"
VMGRDBINPUT="connect ${VMGRDBACCOUNT}/${VMGRPASS}@c2castordevdb\n@${CASTORPACKAGESROOT}/dbcreation/vmgr_oracle_create.sql\nexit\n"
echo $VMGRDBINPUT | sqlplus -S /NOLOG
echo "  vdqm"
VDQMDBINPUT="connect ${VDQMDBACCOUNT}/${VDQMPASS}@c2castordevdb\n@${CASTORPACKAGESROOT}/dbcreation/vdqm_oracle_create.sql\nexit\n"
echo $VDQMDBINPUT | sqlplus -S /NOLOG

# 3) CDB
echo "Dealing with CDB profiles"
echo "  getting all profiles"
mkdir ${BASEDIR}/cdb
cd ${BASEDIR}/cdb
export PROFILES="`echo ${DEVHEADNODES} ${DEVDISKSERVERS} | sed 's/\b\(\w\w*\)\b/profiles\/profile_\1.tpl/g'` prod/cluster/castordev/config.tpl"
rm -f ${PROFILES}
cdbop --command "get ${PROFILES}"
echo "  modifying head node profiles"
for headnode in ${DEVHEADNODES}; do
  profile="profiles/profile_${headnode}.tpl";
  sed -i "s/roles\/redirector' };/roles\/redirector' };\n  include { 'cluster\/' + ELFMS_SVCCLASS + '\/roles\/cupv' };\n  include { 'cluster\/' + ELFMS_SVCCLASS + '\/roles\/vdqm' };\n  include { 'cluster\/' + ELFMS_SVCCLASS + '\/roles\/vmgr' };/" ${profile};
done
echo "  modifying disk server profiles"
for diskserver in ${DEVDISKSERVERS}; do
  profile="profiles/profile_${diskserver}.tpl";
  sed -i "s/roles\/diskserver' };/roles\/diskserver' };\n  include { 'cluster\/' + ELFMS_SVCCLASS + '\/roles\/tapeserver' };/" ${profile};
done
echo "  modifying config profile"
sed -i "s/ELFMS_CUSTOMIZATION == 'dev01'/ELFMS_CUSTOMIZATION == '${DEVNAME}' || ELFMS_CUSTOMIZATION == 'dev01'/" prod/cluster/castordev/config.tpl
echo "  updating CDB"
cdbop --command "update ${PROFILES}; commit -c \"Deploying virtual tape server on ${DEVNAME}\""


# 4) Stop the daemons and run spma/ncm, then restart
echo "Running SPMA on all nodes"
wassh -l root -h "${DEVHEADNODES}" "service rhd stop; service stagerd stop; service transfermanagerd stop; service rmmasterd stop; service tapegatewayd stop; service mighunterd stop; service rechandlerd stop; service rtcpclientd stop; service expertd stop"
wassh -l root -h "${DEVDISKSERVERS}" "service diskmanagerd stop; service gcd stop; service rmnoded stop"
wassh -l root -h "${DEVHEADNODES} ${DEVDISKSERVERS}" spma_ncm_wrapper.sh

# 4.5) Renumber properly the libraries (can be skipped for "standard" dev setup)
echo "Renumbering libraries"
for i in `seq ${#DEVDISKSERVERNUMSARRAY[@]}`; do ssh root@${DEVDISKSERVERSARRAY[${i}]} "sed -i \"s/^VD..STK\(.\) V..STK/VD${DEVDISKSERVERNUMSARRAY[${i}]}STK\1 V${DEVDISKSERVERNUMSARRAY[${i}]}STK/\" /etc/castor/TPCONFIG; sed -i \"s/V..00/V${DEVDISKSERVERNUMSARRAY[${i}]}00/\" /etc/mhvtl/library_contents.10; sed -i \"s/VL..STK/VL${DEVDISKSERVERNUMSARRAY[${i}]}STK/\" /etc/mhvtl/device.conf"; done

# 5) start essential demons
echo "Restart essential daemons"
wassh -l root -h "${DEVHEADNODES}" "service vmgrd start; service cupvd start"
wassh -l root -h "${DEVDISKSERVERS}" "service mhvtl start"
wassh -l root -h "${DEVDISKSERVERS}" "service taped start;service rmcd start;service rtcpd start;service tapebridged start"

# 6) setup tape system
echo "Setting up tape system"
echo "  creating library, dgn and tape pool"
ssh -l root ${ONEHEADNODE} "unset VMGR_HOST; vmgrentermodel --mo T10000 --ml V --mc 1;vmgrenterdenmap -d 20G --ml V --mo T10000 --nc 20G;for i in ${DEVDISKSERVERNUMS}; do vmgrenterlibrary --name VL\${i}STK1 --capacity 8; done;for i in ${DEVDISKSERVERNUMS}; do vmgrenterdgnmap -g V\${i}STK --mo T10000 --library VL\${i}STK1; done;vmgrenterpool --group st --name ${DEVPOOLNAME} --user stage"
echo "  filling tape pool with tapes"
ssh -l root ${ONEHEADNODE} "for lib in ${DEVDISKSERVERNUMS}; do for tape in 1 2 3 4 5; do vmgrentertape -V V\${lib}00\${tape}  --mo T10000 --ml V --li VL\${lib}STK1 -d 20G -l aul --po ${DEVPOOLNAME}; done ; done"
echo "  dealing with Cupv"
ssh -l root ${ONEHEADNODE} "for headnode in ${DEVHEADNODES}; do for diskserver in ${DEVDISKSERVERS}; do Cupvadd --user root --group root --src \"^\${diskserver}.cern.ch\$\"  --tgt \"^\${headnode}.cern.ch\$\" --priv 'TP_SYSTEM'; done;done; for headnode in ${DEVHEADNODES}; do for headnode2 in ${DEVHEADNODES}; do Cupvadd --user stage --group st --src \"^\${headnode}.cern.ch\$\"  --tgt \"^\${headnode2}.cern.ch\$\" --priv 'TP_OPER';for luser in canoc3 sponcec3 murrayc3 itglp esindril; do Cupvadd --user \${luser} --group c3 --src \"^\${headnode}.cern.ch\$\"  --tgt \"^\${headnode2}.cern.ch\$\" --priv 'TP_OPER|UPV_ADMIN|ADMIN';done;done;done"
echo "  starting vdqm"
ssh -l root ${ONEHEADNODE} "vdqmDBInit"
wassh -l root -h "${DEVHEADNODES}" "service vdqmd start"
echo "  setting drives up"
for i in `seq ${#DEVDISKSERVERNUMSARRAY[@]}`; do ssh root@${DEVDISKSERVERSARRAY[${i}]} "for drive in 0 1; do tpconfig VD${DEVDISKSERVERNUMSARRAY[${i}]}STK\${drive} up; done"; done
echo "  labeling tapes"
for i in `seq ${#DEVDISKSERVERNUMSARRAY[@]}`; do ssh root@${DEVDISKSERVERSARRAY[${i}]} "for tape in 1 2 3 4 5; do tplabel -D VD${DEVDISKSERVERNUMSARRAY[${i}]}STK0 -d 20G -g V${DEVDISKSERVERNUMSARRAY[${i}]}STK -l aul -V V${DEVDISKSERVERNUMSARRAY[${i}]}00\${tape} -v V${DEVDISKSERVERNUMSARRAY[${i}]}00\${tape} -f; done"; done
echo "restarting services"
wassh -l root -h "${DEVHEADNODES}" "service rhd start; service stagerd start; service transfermanagerd start; service rmmasterd start; service tapegatewayd start; service mighunterd start; service rechandlerd start; service rtcpclientd start; service expertd start"
wassh -l root -h "${DEVDISKSERVERS}" "service diskmanagerd start; service gcd start; service rmnoded start"

echo "DONE !!!"



### Changing model VSTK to T10000 for badly configured setups

# update TPCONFIG
wassh -l root -h "${DEVDISKSERVERS}" "ncm-ncd --configure filecopy"
# Renumber properly the libraries (can be skipped for "standard" dev setup)
echo "Renumbering libraries"
for i in `seq ${#DEVDISKSERVERNUMSARRAY[@]}`; do ssh root@${DEVDISKSERVERSARRAY[${i}]} "sed -i \"s/^VD..STK\(.\) V..STK/VD${DEVDISKSERVERNUMSARRAY[${i}]}STK\1 V${DEVDISKSERVERNUMSARRAY[${i}]}STK/\" /etc/castor/TPCONFIG; sed -i \"s/V..00/V${DEVDISKSERVERNUMSARRAY[${i}]}00/\" /etc/mhvtl/library_contents.10; sed -i \"s/VL..STK/VL${DEVDISKSERVERNUMSARRAY[${i}]}STK/\" /etc/mhvtl/device.conf"; done
# stop services
wassh -l root -h "${DEVDISKSERVERS}" "service mhvtl stop; service taped stop;service rmcd stop;service rtcpd stop;service tapebridged stop; rm -rf /opt/mhvtl"
wassh -l root -h "${DEVHEADNODES}" "service tapegatewayd stop"
# cleanup tapes
ssh -l root ${ONEHEADNODE} "for lib in ${DEVDISKSERVERNUMS}; do for tape in 1 2 3 4 5; do for file in \`nslisttape -V V\${lib}00\${tape} | awk '{print \$NF}'\`; do nsrm \${file}; done; done; done"
# drop them
ssh -l root ${ONEHEADNODE} "for lib in ${DEVDISKSERVERNUMS}; do for tape in 1 2 3 4 5; do vmgrmodifytape -V V\${lib}00\${tape} --st \"FULL\"; reclaim -V V\${lib}00\${tape}; vmgrdeletetape -V V\${lib}00\${tape}; done; done"
# delete and recreate model everywhere
ssh -l root ${ONEHEADNODE} "unset VMGR_HOST; vmgrdeletemodel --mo VSTK;vmgrdeletedenmap -d 20G --mo VSTK --ml V;for i in ${DEVDISKSERVERNUMS}; do vmgrdeletedgnmap --mo VSTK --library VL\${i}STK1; done;vmgrentermodel --mo T10000 --ml T --mc 1;vmgrenterdenmap -d 20G --ml T --mo T10000 --nc 20G;for i in ${DEVDISKSERVERNUMS}; do vmgrenterdgnmap -g V\${i}STK --mo T10000 --library VL\${i}STK1; done"
# enter new tapes
ssh -l root ${ONEHEADNODE} "for lib in ${DEVDISKSERVERNUMS}; do for tape in 1 2 3 4 5; do vmgrentertape -V V\${lib}00\${tape}  --mo T10000 --ml T --li VL\${lib}STK1 -d 20G -l aul --po ${DEVPOOLNAME}; done ; done"
# update VDQM
ssh -l root ${ONEHEADNODE} "vdqmDBInit"
# restart services
wassh -l root -h "${DEVDISKSERVERS}" "service mhvtl start"
wassh -l root -h "${DEVDISKSERVERS}" "service taped start;service rmcd start;service rtcpd start;service tapebridged start"
# set drives up
for i in `seq ${#DEVDISKSERVERNUMSARRAY[@]}`; do ssh root@${DEVDISKSERVERSARRAY[${i}]} "for drive in 0 1; do tpconfig VD${DEVDISKSERVERNUMSARRAY[${i}]}STK\${drive} up; done"; done
# label tapes
for i in `seq ${#DEVDISKSERVERNUMSARRAY[@]}`; do ssh root@${DEVDISKSERVERSARRAY[${i}]} "for tape in 1 2 3 4 5; do tplabel -D VD${DEVDISKSERVERNUMSARRAY[${i}]}STK0 -d 20G -g V${DEVDISKSERVERNUMSARRAY[${i}]}STK -l aul -V V${DEVDISKSERVERNUMSARRAY[${i}]}00\${tape} -v V${DEVDISKSERVERNUMSARRAY[${i}]}00\${tape} -f; done"; done
# restart services
wassh -l root -h "${DEVHEADNODES}" "service tapegatewayd start"


### moving around tapes in cert5 to create the proper pools
ssh -l root ${ONEHEADNODE} "for lib in 24 25 26 05 06 07 08 09; do for tape in 1 2 3 4 5; do vmgrmodifytape -V V\${lib}00\${tape} --po virtual_replic; done ; done"
ssh -l root ${ONEHEADNODE} "for lib in 01 02 03 04 12; do for tape in 1 2 3 4 5; do vmgrmodifytape -V V\${lib}00\${tape} --po virtual_disk; done ; done"
ssh -l root ${ONEHEADNODE} "for lib in 10 11 13 14 15; do for tape in 1 2 3 4 5; do vmgrmodifytape -V V\${lib}00\${tape} --po virtual_ldisk1; done ; done"
ssh -l root ${ONEHEADNODE} "for lib in 16 17 18 19 20 21 22 23; do for tape in 1 2 3 4 5; do vmgrmodifytape -V V\${lib}00\${tape} --po virtual_ldisk2; done ; done"

