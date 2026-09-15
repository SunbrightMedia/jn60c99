//
// main.cpp — JUNO bare-metal entry (Circle startup)
//
#include "kernel.h"
#include <circle/startup.h>

int main (void)
{
	// No return: some CKernel destructors are not implemented on bare metal.
	CKernel Kernel;
	if (!Kernel.Initialize ())
	{
		halt ();
		return EXIT_HALT;
	}

	TShutdownMode ShutdownMode = Kernel.Run ();

	switch (ShutdownMode)
	{
	case ShutdownReboot:
		reboot ();
		return EXIT_REBOOT;

	case ShutdownHalt:
	default:
		halt ();
		return EXIT_HALT;
	}
}
