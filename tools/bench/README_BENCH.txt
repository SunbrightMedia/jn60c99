THE UNATTENDED BENCH -- one-time setup (about 3 minutes), then never again.

1. Close ALL miniterm/serial windows. Keep the four boards plugged in
   (COM3=board 1, COM4=2, COM5=3, COM6=4 -- same as always).

2. Make a folder  C:\juno_bench  and put these files in it:
      bench.py
      bench_loop.bat

3. Make a GitHub token (one time, 4 clicks):
      open  https://github.com/settings/personal-access-tokens/new
      Repository access: "Only select repositories" -> jn60c99
      Permissions -> Repository permissions -> Contents: Read and write
      Generate token, COPY it.
   Make a new text file  C:\juno_bench\bench_token.txt  and paste the
   token in it (one line, nothing else). The token never leaves your PC
   except to api.github.com. Do NOT send it to anyone -- not even me.

4. Double-click  bench_loop.bat.  It self-tests first and prints
   ALL PASS. From then on it runs forever:
      - it sees every new build by itself,
      - it flashes all four boards by itself,
      - it runs the test and sends me the log by itself.
   You never flash, capture, or paste again. The boards stay playable
   between cycles. To stop everything: close the window.
