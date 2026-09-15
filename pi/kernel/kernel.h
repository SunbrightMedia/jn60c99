//
// kernel.h — JUNO bare-metal bring-up (Circle, BCM2837 / Pi 3 family)
//
// This is the ENTIRE platform glue the project owns, replacing the retired
// four-ESP32-S3 chain. For the boot step it does one thing: prove the board
// boots to metal and reaches our code, printing a banner over the PL011 UART
// (the serial the Pi 3A+ debug header and QEMU raspi3ap both expose). The
// audio-render callback, I2S DAC driver and panel input land on top of this
// skeleton in the next steps (docs/pi/PORT_PI.md).
//
#ifndef _kernel_h
#define _kernel_h

#include <circle/actled.h>
#include <circle/koptions.h>
#include <circle/devicenameservice.h>
#include <circle/screen.h>
#include <circle/serial.h>
#include <circle/exceptionhandler.h>
#include <circle/interrupt.h>
#include <circle/timer.h>
#include <circle/logger.h>
#include <circle/types.h>

enum TShutdownMode
{
	ShutdownNone,
	ShutdownHalt,
	ShutdownReboot
};

class CKernel
{
public:
	CKernel (void);
	~CKernel (void);

	boolean Initialize (void);
	TShutdownMode Run (void);

private:
	// Construction order is load-bearing in Circle; do not reorder.
	CActLED			m_ActLED;
	CKernelOptions		m_Options;
	CDeviceNameService	m_DeviceNameService;
	CScreenDevice		m_Screen;
	CSerialDevice		m_Serial;
	CExceptionHandler	m_ExceptionHandler;
	CInterruptSystem	m_Interrupt;
	CTimer			m_Timer;
	CLogger			m_Logger;
};

#endif
