//
// kernel.cpp — JUNO bare-metal bring-up (boot step)
//
#include "kernel.h"
#include <circle/string.h>
#include <circle/machineinfo.h>

static const char FromJuno[] = "juno";

CKernel::CKernel (void)
:	m_Screen (m_Options.GetWidth (), m_Options.GetHeight ()),
	m_Timer (&m_Interrupt),
	m_Logger (m_Options.GetLogLevel (), &m_Timer)
{
	m_ActLED.Blink (3);	// visible on a real board: we reached our constructor
}

CKernel::~CKernel (void)
{
}

boolean CKernel::Initialize (void)
{
	boolean bOK = TRUE;

	if (bOK) bOK = m_Screen.Initialize ();
	if (bOK) bOK = m_Serial.Initialize (115200);

	if (bOK)
	{
		// Log to the UART: it is the one output both the Pi 3A+ debug header
		// and QEMU raspi3ap expose, so the boot banner is always visible
		// without a display attached. Fall back to the screen only if serial
		// somehow failed.
		CDevice *pTarget = &m_Serial;
		if (pTarget == 0) pTarget = &m_Screen;
		bOK = m_Logger.Initialize (pTarget);
	}

	if (bOK) bOK = m_Interrupt.Initialize ();
	if (bOK) bOK = m_Timer.Initialize ();

	return bOK;
}

TShutdownMode CKernel::Run (void)
{
	// Boot proof: reaching here means the toolchain, Circle, and our glue
	// produced a kernel8.img that boots to metal and runs. Print who and where.
	m_Logger.Write (FromJuno, LogNotice,
			"JUNO bare-metal bring-up — BOOT OK");
	m_Logger.Write (FromJuno, LogNotice,
			"Circle on %s", CMachineInfo::Get ()->GetMachineName ());

	unsigned nRAM = CMachineInfo::Get ()->GetRAMSize ();
	m_Logger.Write (FromJuno, LogNotice,
			"SoC %s, %u MB RAM, %u cores",
			CMachineInfo::Get ()->GetSoCName (),
			nRAM, CMachineInfo::Get ()->GetModelMajor () >= 2 ? 4 : 1);

	m_Logger.Write (FromJuno, LogNotice, "Compiled: " __DATE__ " " __TIME__);
	m_Logger.Write (FromJuno, LogNotice,
			"Next: I2S DAC out + the bit-exact render callback.");

	// Heartbeat so a live board / QEMU run visibly keeps running (not hung).
	unsigned nBeat = 0;
	unsigned nTime = m_Timer.GetTime ();
	while (nBeat < 5)
	{
		while (nTime == m_Timer.GetTime ())
		{
			// wait one second
		}
		nTime = m_Timer.GetTime ();
		m_Logger.Write (FromJuno, LogNotice, "alive t=%u", nTime);
		nBeat++;
	}

	m_Logger.Write (FromJuno, LogNotice, "BOOT PROOF COMPLETE — halting.");
	return ShutdownHalt;
}
