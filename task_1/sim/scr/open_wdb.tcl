
set SIM_SNAPSHOT	$::env(SIM_SNAPSHOT)
set WAVE_FILE		$::env(WAVE_FILE)

current_fileset
open_wave_database	${SIM_SNAPSHOT}.wdb
open_wave_config	${WAVE_FILE}
