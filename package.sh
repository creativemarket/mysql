
#!/bin/bash -e
#
# Create a system package
#

#
# Prerequisites:
# sudo apt-get install ruby-dev gcc
# sudo gem install fpm
#

if [ "$#" != "1" ]; then
	echo "Usage: ./package.sh <VERSION>"
	exit 1
fi

VERSION=$1

TMP_WORK_DIR=`mktemp -d`
INSTALL_ROOT_DIR=/opt/mysqlconnector
CONFIG_ROOT_DIR=/etc/mysqlconnector
LOG_ROOT_DIR=/var/log/mysqlconnector
ARCH=`uname -i`
MAINTAINER=someone@creativemarket.com
VENDOR="Creative Market"
PACKAGE_NAME="mysqlconnector"
DESCRIPTION="Segment.io MySQL Connector"
PACKAGE_FILE="mysqlconnector_${VERSION}_amd64.deb"

POST_INSTALL_PATH=`mktemp`
POST_UNINSTALL_PATH=`mktemp`

cat <<EOF >$POST_INSTALL_PATH
#!/bin/sh
rm -f $INSTALL_ROOT_DIR/mysqlconnector
ln -s $INSTALL_ROOT_DIR/versions/$VERSION $INSTALL_ROOT_DIR/mysqlconnector
EOF

cat <<EOF >$POST_UNINSTALL_PATH
#!/bin/sh
EOF

go build -o mysqlconnector

mkdir -p $TMP_WORK_DIR/$INSTALL_ROOT_DIR/versions/$VERSION/
cp mysqlconnector $TMP_WORK_DIR/$INSTALL_ROOT_DIR/versions/$VERSION/mysqlconnector

mkdir -p $TMP_WORK_DIR/$CONFIG_ROOT_DIR/

mkdir -p $TMP_WORK_DIR/$LOG_ROOT_DIR/

if [ -f $PACKAGE_FILE ]; then
	rm $PACKAGE_FILE
fi

FPM_ARGS="\
--log error \
-C $TMP_WORK_DIR \
--maintainer $MAINTAINER \
--after-install $POST_INSTALL_PATH \
--after-remove $POST_UNINSTALL_PATH \
--name $PACKAGE_NAME \
--config-files $CONFIG_ROOT_DIR"

fpm -s dir -t deb --vendor "$VENDOR" --description "$DESCRIPTION" $FPM_ARGS --version $VERSION .

rm -r $TMP_WORK_DIR
rm $POST_INSTALL_PATH
rm $POST_UNINSTALL_PATH

# Leave with a smile!
exit 0