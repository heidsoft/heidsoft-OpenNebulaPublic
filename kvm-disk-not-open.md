error: internal error process exited while connecting to monitor: kvm: -drive file=/home/oneadmin/var//datastores/0/6/disk.0,if=none,media=cdrom,id=drive-ide0-0-0,readonly=on,format=raw,cache=none: could not open disk image /home/oneadmin/var//datastores/0/6/disk.0: Permission denied

//virsh  managedsave-remove one-6 

error: internal error process exited while connecting to monitor: kvm: 该错误由于security_driver引起，配置security_driver="none"就可
vnc_listen = "0.0.0.0"
spice_listen = "0.0.0.0"
security_driver = "none"