/**********************************
 * header - 1551-rePico board support
 *
 * GPIO0: 2 MHz PHI0 (50% PWM), isolated from /PHI0 by JP2 until bridged
 * GPIO3: DEVNUM on TCBM cable (default jumpers JP5/JP6), or IRQ experiment
***********************************/
#ifndef BOARD1551_H
#define BOARD1551_H

#include "board_config.h"

#if REPICO1551

#define REPICO1551_PHI0_HZ      2000000u
#define REPICO1551_IRQ_HZ       100u
#define REPICO1551_IRQ_LOW_US   10u

/*
 * GPIO3 /DEVNUM_3V3 (default solder jumpers JP5+JP6):
 *   Drive the TCBM DEV line so the Plus/4 paddle maps this drive as device #8
 *   (TIA at FEE0/FEF0 on the computer). DEV=0 selects device 8; DEV=1 is #9 (FEC0).
 *   Matches JP7=GND when JP5/JP6 are swapped to the IRQ experiment layout.
 *
 * Optional: 100 Hz active-low IRQ pulses on GPIO3 for 6510 IRQ bring-up.
 *   Enable ONLY after swapping BOTH JP5 and JP6 (GPIO3 -> /~IRQ, DEVNUM from JP7).
 *   Do NOT enable while GPIO3 is wired to /DEVNUM_3V3 — toggling DEV breaks TCBM.
 *
 *   #define REPICO1551_GPIO3_IRQ_PWM
 */
#define REPICO1551_GPIO3_IRQ_PWM

#define REPICO1551_DEVNUM_DEVICE8_LEVEL   0u
#define REPICO1551_DEVNUM_DEVICE9_LEVEL   1u

void init_board1551(void);

#endif

#endif
