#!/bin/sh

if [ "`whoami`" != "root" ]; then
	# check if sudo is available, if not error out
	if command -v sudo >/dev/null 2>&1; then
		echo This script needs root privileges to run.
		echo Press enter to attempt to run under sudo.
		echo Press ctrl-C to quit.
		read dummyvar
		exec sudo $0
	else
		echo This script needs root privileges to run.
		exit 1
	fi
fi

CHROOT_DIR=chroot
MIRROR_URL=http://localhost:3142/ftp.us.debian.org/debian/

# create basic chroot
debootstrap wheezy $CHROOT_DIR $MIRROR_URL

# set up policy-rc.d so no daemons start in chroot
cat > $CHROOT_DIR/etc/policy-rc.d <<EOF
#!/bin/sh
exit 101
EOF
chmod +x $CHROOT_DIR/etc/policy-rc.d

# mount filesystems in the chroot
mount -t proc proc $CHROOT_DIR/proc
mount -t sysfs sysfs $CHROOT_DIR/sys

# run setup script inside chroot
cp chroot_tasks.sh $CHROOT_DIR/
chmod +x $CHROOT_DIR/chroot_tasks.sh
chroot $CHROOT_DIR /chroot_tasks.sh

# unmount pseudo-filesystems
umount chroot/proc
umount chroot/sys

# delete temporary files created in chroot
rm $CHROOT_DIR/etc/policy-rc.d
rm $CHROOT_DIR/chroot_tasks.sh
