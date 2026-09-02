# probes/ — executed evidence, one directory per investigation

These scripts drove the plugin's own machine code under Unicorn and produced
the findings the named docs record. They are EVIDENCE, not gates: none runs in
`make verify`, none is maintained. Re-run one only to re-derive its finding;
the doc that cites it is the authority on what it proved.
