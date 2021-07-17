#!@shell@

SSHOPTS="allow_other,reconnect,ServerAliveInterval=15,ServerAliveCountMax=3"
USERNAME="${USERNAME-@defaultuser@}"
SERVER="${SERVER-@defaultserver@}"
ADDR="$USERNAME@$SERVER"
if [ "x$1" != "x-d" ]; then
    mkdir -p $HOME/kl
    @sshfs@ -o "$SSHOPTS" "$ADDR:/home/$USERNAME/Projects/Kaspersky" $HOME/kl -C
else
    umount $HOME/kl
fi
