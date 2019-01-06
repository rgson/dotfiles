#!/bin/zsh

windows_reboot() {
	label=$(awk -F\' '/menuentry / {print $2}' /boot/grub/grub.cfg | grep Windows | head -n 1)
	if [[ -z $label ]]; then
		echo 'No Windows boot entry found.' >&2
		return 1
	fi
	sudo -- sh -c "grub-reboot '$label' && reboot"
}
