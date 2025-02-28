# =====================================
# The executable name (EXECPREFIX_MODEL)
# =====================================
EXECPREFIX = MG_PICOLA

# ========================================
# Choose the machine you are running on. 
# Set paths to mpicc, FFTW3 and GSL below
# ========================================
#MACHINE = SCIAMA2
#MACHINE = OKEANOS
MACHINE  = NERSC-CORI

# ========================
# Options for optimization
# ========================
OPTIMIZE  = -O3 -Wall -std=c99 

# ==================================
# Fetch any options from commandline
# ==================================
ifndef OPT
  OPTIONS = 
else
  OPTIONS = $(OPT)
endif

# ====================================================================
# Select model. For LCDM sims one can use any of the below, but 
# without scaledependent is faster so use this
# ====================================================================

ifndef MODEL
  # DGP gravity
  MODEL = DGP
  
  # f(R) gravity
  #MODEL = FOFR            
  
  # f(R) gravity with LCDM LPT growth factors
  #MODEL = FOFR_LCDM
  
  # General m(a),beta(a) model
  #MODEL = MBETA
  
  # Jordan-Brans-Dicke model
  #MODEL = BRANSDICKE
  
  # Massive neutrino and f(R) gravity
  #MODEL = FOFRNU
endif

EXEC = $(EXECPREFIX)_$(MODEL)
$(info )
$(info =====================================================)
$(info MODEL = [${MODEL}]  EXEC = [${EXEC}])
$(info External options = [${OPT}])  
$(info =====================================================)
$(info )

ifeq ($(MODEL), FOFR)
  # Hu-Sawicky f(R) model
  MGMODEL  = -DFOFRGRAVITY
  OPTIONS += $(MGMODEL)
  OPTIONS += -DSCALEDEPENDENT
  MODELISDEFINED = TRUE
endif

ifeq ($(MODEL), FOFR_LCDM)
  # f(R) for using non-scaledependent (LCDM) growth-factors
  MGMODEL  = -DFOFRGRAVITY
  OPTIONS += $(MGMODEL)
  MODELISDEFINED = TRUE
endif

ifeq ($(MODEL), DGP)
  # Normal branch DGP model
  MGMODEL         = -DDGPGRAVITY             
  SMOOTHINGFILTER = -DGAUSSIANFILTER          
  OPTIONS        += $(MGMODEL) 
  OPTIONS        += $(SMOOTHINGFILTER) 
  MODELISDEFINED  = TRUE
endif

ifeq ($(MODEL), BRANSDICKE)
  # Brans-Dicke model
  MGMODEL  = -DBRANSDICKE
  OPTIONS += $(MGMODEL) 
  MODELISDEFINED = TRUE
endif

ifeq ($(MODEL), MBETA)
  # General (m,beta) parametrisation
  MGMODEL  = -DMBETAMODEL 
  OPTIONS += $(MGMODEL) 
  OPTIONS += -DSCALEDEPENDENT
  MODELISDEFINED = TRUE
endif

ifeq ($(MODEL), FOFRNU)
  # Massive neutrino and f(R) gravity
  MGMODEL  = -DFOFRGRAVITY
  OPTIONS += $(MGMODEL)
  OPTIONS += -DMASSIVE_NEUTRINOS -DSCALEDEPENDENT
  MODELISDEFINED = TRUE
endif

ifndef MODELISDEFINED
  $(error ERROR: MODEL is not recognized)
endif

# ====================================================================
# Various C preprocessor directives that change the way the code is made
# ====================================================================

GAUSSIAN = -DGAUSSIAN                    # Switch this if you want gaussian initial conditions (fnl otherwise)
OPTIONS += $(GAUSSIAN) 

# ====================================================================

MEMORY_MODE = -DMEMORY_MODE	             # Save memory by making sure to allocate and deallocate arrays only when we need them
OPTIONS += $(MEMORY_MODE)	   	           # and by making the particle data single precision

# ====================================================================

GADGET_STYLE = -DGADGET_STYLE            # If we are running snapshots this writes all the output in Gadget's '1' style format, 
                                         # with the corresponding header
OPTIONS += $(GADGET_STYLE)               # This option is incompatible with LIGHTCONE simulations. 
                                         # For binary outputs with LIGHTCONE simulations use the UNFORMATTED option.

# ====================================================================

#READICFROMFILE = -DREADICFROMFILE       # Read Gadget/Ramses/ascii IC files instead of creating it in the code
#OPTIONS += $(READICFROMFILE)            # Needs extra parameters in the parameterfile

# ====================================================================

#MASSIVE_NEUTRINOS = -DMASSIVE_NEUTRINOS  
#OPTIONS += $(MASSIVE_NEUTRINOS)         # Include support for massive neutrinos
#OPTIONS += -DSCALEDEPENDENT             # Massive neutrinos require scale-dependent version
                                         # Needs extra parameters in the parameterfile

# ====================================================================

#COMPUTE_POFK = -DCOMPUTE_POFK           # Compute P(k) in the code and output
#OPTIONS += $(COMPUTE_POFK)              # Needs extra parameters in the parameterfile

# ====================================================================

#MATCHMAKER = -DMATCHMAKER_HALOFINDER    # Switch this on to do FoF halo-finding on the fly using MatchMaker (David Alonso)
#OPTIONS += $(MATCHMAKER)                # Needs extra parameters in the parameterfile

# ====================================================================

#SINGLE_PRECISION = -DSINGLE_PRECISION	 # Single precision floats and FFTW (else use double precision)
#OPTIONS += $(SINGLE_PRECISION)

# ====================================================================

#PARTICLE_ID = -DPARTICLE_ID             # Assigns unsigned long long ID's to each particle and outputs them. This adds
#OPTIONS += $(PARTICLE_ID)               # an extra 8 bytes to the storage required for each particle

# ====================================================================

#LIGHTCONE = -DLIGHTCONE                 # Builds a lightcone based on the run parameters and only outputs particles
#OPTIONS += $(LIGHTCONE)                 # at a given timestep if they have entered the lightcone 

# ====================================================================

#LOCAL_FNL = -DLOCAL_FNL                 # Switch this if you want only local non-gaussianities
#OPTIONS += $(LOCAL_FNL)                 # NOTE this option is only for invariant inital power spectrum
                                         # for local with ns != 1 use DGENERIC_FNL and input_kernel_local.txt

# ====================================================================

#EQUIL_FNL = -DEQUIL_FNL                 # Switch this if you want equilateral Fnl
#OPTIONS += $(EQUIL_FNL)                 # NOTE this option is only for invariant inital power spectrum
                                         # for local with ns != 1 use DGENERIC_FNL and input_kernel_equil.txt

# ====================================================================

#ORTHO_FNL = -DORTHO_FNL                 # Switch this if you want ortogonal Fnl
#OPTIONS += $(ORTHO_FNL)                 # NOTE this option is only for invariant inital power spectrum
                                         # for local with ns != 1 use DGENERIC_FNL and input_kernel_ortog.txt

# ====================================================================

#GENERIC_FNL += -DGENERIC_FNL            # Switch this if you want generic Fnl implementation
#OPTIONS += $(GENERIC_FNL)               # This option allows for ns != 1 and should include an input_kernel_file.txt 
                                         # containing the coefficients for the generic kernel 
                                         # see README and Manera et al astroph/NNNN.NNNN
                                         # For local, equilateral and orthogonal models you can use the provided files
                                         # input_kernel_local.txt, input_kernel_equil.txt, input_kernel_orthog.txt 

# ====================================================================
																				
#UNFORMATTED = -DUNFORMATTED             # If we are running lightcones this writes all the output in binary. 
                                         # All the particles are output in chunks with each 
#OPTIONS += $(UNFORMATTED)               # chunk preceded by the number of particles in the chunk. With the chunks we output all the data 
                                         # (id, position and velocity) for a given particle contiguously

# ====================================================================

# =================================================================================================================
# Nothing below here should need changing unless you are adding in/modifying libraries for existing or new machines
# =================================================================================================================

# =======================================
# Run some checks on option compatability
# =======================================
ifdef GAUSSIAN
ifdef LOCAL_FNL
  $(error ERROR: GAUSSIAN AND LOCAL_FNL are not compatible, change Makefile)
endif
ifdef EQUIL_FNL
  $(error ERROR: GAUSSIAN AND EQUIL_FNL are not compatible, change Makefile)
endif
ifdef ORTHO_FNL
  $(error ERROR: GAUSSIAN AND ORTHO_FNL are not compatible, change Makefile)
endif
else
ifndef LOCAL_FNL 
ifndef EQUIL_FNL
ifndef ORTHO_FNL 
ifndef GENERIC_FNL
  $(error ERROR: if not using GAUSSIAN then must select some type of non-gaussianity (LOCAL_FNL, EQUIL_FNL, ORTHO_FNL, GENERIC_FNL), change Makefile)
endif
endif
endif
endif
endif

ifdef GENERIC_FNL 
ifdef LOCAL_FNL 
   $(error ERROR: GENERIC_FNL AND LOCAL_FNL are not compatible, choose one in Makefile) 
endif 
ifdef EQUIL_FNL 
   $(error ERROR: GENERIC_FNL AND EQUIL_FNL are not compatible, choose one in Makefile) 
endif 
ifdef ORTHO_FNL 
   $(error ERROR: GENERIC_FNL AND ORTHO_FNL are not compatible, choose one in Makefile) 
endif 
endif 

ifdef LOCAL_FNL
ifdef EQUIL_FNL
   $(error ERROR: LOCAL_FNL AND EQUIL_FNL are not compatible, choose one or the other in Makefile) 
endif
ifdef ORTHO_FNL
   $(error ERROR: LOCAL_FNL AND ORTHO_FNL are not compatible, choose one or the other in Makefile) 
endif
endif

ifdef EQUIL_FNL
ifdef ORTHO_FNL
   $(error ERROR: EQUIL_FNL AND ORTHO_FNL are not compatible, choose one or the other in Makefile) 
endif
endif

ifdef PARTICLE_ID
ifdef LIGHTCONE
   $(warning WARNING: LIGHTCONE output does not output particle IDs)
endif
endif

ifdef GADGET_STYLE
ifdef LIGHTCONE
   $(error ERROR: LIGHTCONE AND GADGET_STYLE are not compatible, for binary output with LIGHTCONE simulations please choose the UNFORMATTED option.)
endif
endif

ifdef UNFORMATTED
ifndef LIGHTCONE 
   $(error ERROR: UNFORMATTED option is incompatible with snapshot simulations, for binary output with snapshot simulations please choose the GADGET_STYLE option.)
endif
endif

ifdef SCALEDEPENDENT
ifdef LIGHTCONE
   $(error ERROR: LIGHTCONE AND SCALEDEPENDENT are not compatible. Use LCDM growth-factors for LIGHTCONE simulations.)
endif
endif

# ====================================
# Setup libraries and compile the code
# ====================================
ifeq ($(MACHINE),NERSC-CORI)
  CC = mpicc
ifdef SINGLE_PRECISION
  FFTW_INCL = -I${FFTW_LIB}/include
  FFTW_LIBS = -L${FFTW_LIB}/lib/ -lfftw3f_mpi -lfftw3f
else
  FFTW_INCL = -I${FFTW_LIB}/include
  FFTW_LIBS = -L${FFTW_LIB}/lib/ -lfftw3_mpi -lfftw3
endif
  GSL_INCL  = -I${GSL_LIB}/include/
  GSL_LIBS  = -L${GSL_LIB}/lib  -lgsl -lgslcblas
  MPI_INCL  = -I${MPILIB}/include
  MPI_LIBS  = -L${MPILIB}/lib/ -lmpi
endif

ifeq ($(MACHINE),SCIAMA2)
  CC = mpicc
ifdef SINGLE_PRECISION
  FFTW_INCL = -I/opt/gridware/pkg/libs/fftw3_float/3.3.3/gcc-4.4.7+openmpi-1.8.1/include/
  FFTW_LIBS = -L/opt/gridware/pkg/libs/fftw3_float/3.3.3/gcc-4.4.7+openmpi-1.8.1/lib/ -lfftw3f_mpi -lfftw3f
else
  FFTW_INCL = -I/opt/gridware/pkg/libs/fftw3_double/3.3.3/gcc-4.4.7+openmpi-1.8.1/include/
  FFTW_LIBS = -L/opt/gridware/pkg/libs/fftw3_double/3.3.3/gcc-4.4.7+openmpi-1.8.1/lib/ -lfftw3_mpi -lfftw3
endif
  GSL_INCL  = -I/opt/apps/libs/gsl/2.1/gcc-4.4.7/include/
  GSL_LIBS  = -L/opt/apps/libs/gsl/2.1/gcc-4.4.7/lib/  -lgsl -lgslcblas
  MPI_INCL  = -I/opt/gridware/pkg/mpi/openmpi/1.8.1/gcc-4.4.7/include
  MPI_LIBS  = -L/opt/gridware/pkg/mpi/openmpi/1.8.1/gcc-4.4.7/lib/ -lmpi
endif

ifeq ($(MACHINE),WINTHERMACBOOK)
  CC = mpicc-openmpi-gcc6                                        # Add your MPI compiler here
ifdef SINGLE_PRECISION
  FFTW_INCL = -I/Users/hans/local/include/
  FFTW_LIBS = -L/Users/hans/local/lib/ -lfftw3f_mpi -lfftw3f
  FFTW_INCL = -I/Users/hans/local/include/
  FFTW_LIBS = -L/Users/hans/local/lib/ -lfftw3f_mpi -lfftw3f
else
  FFTW_INCL = -I/Users/hans/local/include/                       # Add paths to your FFTW3 library here
  FFTW_LIBS = -L/Users/hans/local/lib/ -lfftw3_mpi -lfftw3
endif
  GSL_INCL  = -I/opt/local/include/gsl/                          # Add paths to your GSL library here
  GSL_LIBS  = -L/opt/local/lib/  -lgsl -lgslcblas
  MPI_INCL  = -I/opt/local/include
  MPI_LIBS  = -L/opt/local/lib/ -lmpi
endif

ifeq ($(MACHINE),OKEANOS)
  CC = cc
  GSL_INCL =  -I/lustre/tetyda/home/winther/local/include 
  GSL_LIBS =  -L/lustre/tetyda/home/winther/local/lib -lgsl -lgslcblas 
endif

LIBS   =   -lm $(MPI_LIBs) $(FFTW_LIBS) $(GSL_LIBS)

CFLAGS =   $(OPTIMIZE) $(FFTW_INCL) $(GSL_INCL) $(MPI_INCL) $(OPTIONS)

OBJS  = src/main.o src/cosmo.o src/auxPM.o src/2LPT.o src/power.o src/vars.o src/read_param.o src/timer.o src/msg.o src/wrappers.o src/jbd.o
OBJS += src/compute_pofk.o src/readICfromfile.c
ifdef GENERIC_FNL
  OBJS += src/kernel.o
endif
ifdef LIGHTCONE
OBJS += src/lightcone.o
endif

INCL   = src/vars.h src/proto.h src/mg.h src/user_defined_functions.h src/wrappers.h Makefile
INCL  += src/read_CAMB_data.h
ifdef MATCHMAKER
OBJS += src/mm_main.o src/mm_msg.o src/mm_fof.o src/mm_snap_io.o
INCL += src/mm_common.h
endif

all: $(OBJS) 
	$(CC) $(CFLAGS) $(OBJS) $(LIBS) -o $(EXEC)

$(OBJS): $(INCL) 

clean:
	rm -f src/*.o src/*~ *~ $(EXEC)
