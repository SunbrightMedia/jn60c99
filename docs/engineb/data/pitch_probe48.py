import sys
sys.path.insert(0, "/home/user/jn60c99/tools/engineb")
import null_b
null_b.SR = 48000.0
P = "/home/user/jn60c99/docs/engineb/data/pitch_precision_probe.py"
g = {"__name__": "__main__", "__file__": P}
sys.argv = ["probe48"] + sys.argv[1:]
exec(compile(open(P).read(), P, "exec"), g)
