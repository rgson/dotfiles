$key_id = 'B26C2ED3732462219C3D1DFE293A3C91D188369C';
$clean_source = 0;
$build_source = 1;
$source_only_changes = 1;
#$build_env_cmnd = '/usr/local/bin/build-entrypoint';
$external_commands = {
#	'chroot-setup-commands' => [
#		'printf "#!/bin/sh\nset -e\nset -x\nfaketime \"2025-03-31 12:00:00\" \$@\n" >/usr/local/bin/build-entrypoint',
#		'chmod +x /usr/local/bin/build-entrypoint',
#		'cat /usr/local/bin/build-entrypoint',
#		'apt-get install -y faketime',
#	],
	'starting-build-commands' => [
		'cd %SBUILD_PKGBUILD_DIR && find . | sort | while read x; do stat --printf "%n  %F  " "$x"; if [ -f "$x" ]; then md5sum "$x" | cut -d\  -f1; else echo; fi; done >/tmp/file-list.pre-build',
	],
	'chroot-cleanup-commands' => [
		'cd %SBUILD_PKGBUILD_DIR && ./debian/rules clean',
		'cd %SBUILD_PKGBUILD_DIR && find . | sort | while read x; do stat --printf "%n  %F  " "$x"; if [ -f "$x" ]; then md5sum "$x" | cut -d\  -f1; else echo; fi; done >/tmp/file-list.post-build',
		'diff -U0 /tmp/file-list.pre-build /tmp/file-list.post-build',
	]
};

1;
