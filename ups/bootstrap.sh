#!/bin/bash

# make a mrb ups product


usage()
{
   echo "USAGE: `basename ${0}` <product_dir> <tag>"
   echo "       `basename ${0}` installs mrb as a relocatable ups product"
}

get_my_dir() 
{
    ( cd / ; /bin/pwd -P ) >/dev/null 2>&1
    if (( $? == 0 )); then
      pwd_P_arg="-P"
    fi
    reldir=`dirname ${0}`
    mydir=`cd ${reldir} && /bin/pwd ${pwd_P_arg}`
}


product_dir=${1}
pkgver=${2}

if [ -z ${product_dir} ]
then
   echo "ERROR: please specify the product directory"
   usage
   exit 1
fi
if [ -z ${pkgver} ]
then
   echo "ERROR: please specify a tag"
   usage
   exit 1
fi

package=mrb
pkgdotver=`echo ${pkgver} | sed -e 's/_/./g' | sed -e 's/^v//'`

get_my_dir

pkgdir=${product_dir}/${package}
if [ ! -d ${pkgdir} ]
then
  mkdir -p ${pkgdir} || exit 2;
fi

# cleanup the old directory if necessary
if [ -d ${pkgdir}/${pkgver} ]
then
   set -x
   rm -rf ${pkgdir}/${pkgver} ${pkgdir}/${pkgver}.version ${pkgdir}/current.chain
   set +x
fi

set -x
# pull the tagged release from git
git archive --prefix=mrb-${pkgver}/ \
            --remote ssh://p-${package}@cdcvs.fnal.gov/cvs/projects/${package} \
            -o ${mydir}/${package}-${pkgver}.tar ${pkgver}
mkdir -p ${pkgdir}/${pkgver}/source
cd ${pkgdir}/${pkgver}/source
tar xf ${mydir}/${package}-${pkgver}.tar
set +x

if [ -z ${UPS_DIR} ]
then
   echo "ERROR: please setup ups"
   exit 1
fi
source `${UPS_DIR}/bin/ups setup ${SETUP_UPS}`

# now run cmake
mkdir -p ${pkgdir}/${pkgver}/build
cd ${pkgdir}/${pkgver}/build
setup cmake v3_13_2
cmake -DCMAKE_INSTALL_PREFIX=${product_dir} ${pkgdir}/${pkgver}/source/mrb-${pkgver}
make install
make package

##ups declare -c ${package} ${pkgver} -r ${package}/${pkgver} -0 -m ${package}.table  -z ${product_dir}:${PRODUCTS}

ups list -aK+ ${package} ${pkgver}   -z ${product_dir}

mv ${pkgdir}/${pkgver}/build/${package}-${pkgdotver}-noarch.tar.bz2 ${product_dir}/

# now make the tar ball
# set -x
# cd ${product_dir}
# tar cjf ${package}-${pkgdotver}-noarch.tar.bz2 ${package}/${pkgver}/bin  \
#                                                ${package}/${pkgver}/templates  \
#                                                ${package}/${pkgver}/ups  \
#                                                ${package}/${pkgver}.version \
#                                                ${package}/current.chain
# 
exit 0

