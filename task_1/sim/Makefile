#------------------------------------------------------------

COMPILE_BIN				=	xvlog
ELAB_BIN				=	xelab
SIM_BIN					=	xsim
VIVADO_BIN				=	vivado

ELAB_OPTIONS			=	--debug all

TB_ROOT_DIR				=	$(shell pwd)
TB_SCR_DIR				=	${TB_ROOT_DIR}/scr
TB_SRC_DIR				=	${TB_ROOT_DIR}/src
TB_WAVE_DIR				=	${TB_ROOT_DIR}/wave

IP_ROOT_DIR				=	${TB_ROOT_DIR}/..
IP_SRC_DIR				=	${IP_ROOT_DIR}/src

IP_TOP					=	timer
TB_TOP					=	tb

IP_LIB					=	lib_${IP_TOP}
TB_LIB					=	tb_lib

OUTPUT_DIR				=	work

export SIM_SNAPSHOT		=	sim_snapshot

TB_RLX_FILE				=	${OUTPUT_DIR}/${TB_LIB}/${TB_LIB}.rlx
IP_RLX_FILE				=	${OUTPUT_DIR}/${IP_LIB}/${IP_LIB}.rlx

ELAB_FILE				=	${OUTPUT_DIR}/xsim.dir/${SIM_SNAPSHOT}/xsimk
WDB_FILE				=	${OUTPUT_DIR}/${SIM_SNAPSHOT}.wdb
export WAVE_FILE		=	${TB_WAVE_DIR}/wave.wcfg

#------------------------------------------------------------

.PHONY: all com_ip com_tb com elab sim_gui sim_cli

all: com elab sim_cli

com: com_ip com_tb

com_ip:	${IP_RLX_FILE}

com_tb: ${TB_RLX_FILE}

elab : ${ELAB_FILE}

#-------------------------------------------------------------------------------

${IP_RLX_FILE}: ${IP_SRC_DIR}/*.v

		@( mkdir -p ${OUTPUT_DIR} &&	cd ${OUTPUT_DIR}					&&	\
		${COMPILE_BIN} -work ${IP_LIB}=${IP_LIB} ${IP_SRC_DIR}/*.v			)


#-------------------------------------------------------------------------------

${TB_RLX_FILE}: ${TB_SRC_DIR}/*.sv

		@( mkdir -p ${OUTPUT_DIR} &&	cd ${OUTPUT_DIR}					&&	\
		${COMPILE_BIN} -sv -work ${TB_LIB}=${TB_LIB} ${TB_SRC_DIR}/*.sv		)

#-------------------------------------------------------------------------------

${ELAB_FILE}: ${IP_RLX_FILE} ${TB_RLX_FILE}

		@( mkdir -p ${OUTPUT_DIR} &&	cd ${OUTPUT_DIR}					&&	\
		${ELAB_BIN} ${ELAB_OPTIONS} -L ${IP_LIB}=${IP_LIB} -L ${TB_LIB}=${TB_LIB} -s ${SIM_SNAPSHOT} ${TB_LIB}.tb_timer_top )


#-------------------------------------------------------------------------------

sim_cli: ${ELAB_FILE}

		@( cd ${OUTPUT_DIR}														&&	\
		${SIM_BIN} ${SIM_SNAPSHOT} -t ${TB_SCR_DIR}/run_sim.tcl					)


#-------------------------------------------------------------------------------

sim_gui: ${ELAB_FILE}


		@( cd ${OUTPUT_DIR}													&&	\
		${SIM_BIN} -gui ${SIM_SNAPSHOT} -t ${TB_SCR_DIR}/run_sim.tcl		)

#-------------------------------------------------------------------------------

view_wave:	${WDB_FILE}

		@( cd ${OUTPUT_DIR}													&&	\
		${VIVADO_BIN} -source ${TB_SCR_DIR}/open_wdb.tcl					)

#-------------------------------------------------------------------------------

clean:

		rm -rf work
