DIST_DIR = ../../quancom_usb-1.3.4
PWD = $(shell pwd)

create_qlib:
	cd ${DIST_DIR}/qlib && make

create_shared_object: create_qlib
	cd ${DIST_DIR}/qlib && gcc -shared **/*.o -o libqlib.so
	cp libqlib.so ../lib

install_module:
	cd ${DIST_DIR}/module && patch -p1 < ${PWD}/module-kernel2.6.32.patch
	cd ${DIST_DIR}/module && make
	sudo cp ${DIST_DIR}/module/quancom_usb.ko /lib/modules/$(uname -r)/kernel/drivers/usb
	sudo depmod -a
	sudo cp 10-quancom.rules /etc/udev/rules.d/

