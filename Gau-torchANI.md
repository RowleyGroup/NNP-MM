# Interfacing Gaussian with TorchANI

This script interfaces Gaussian to TorchANI using Gaussian's [External](https://gaussian.com/external/). [TorchANI](https://aiqm.github.io/torchani/) must be installed.

<pre><code>
%chk=optimization.chk
%mem=500MB
#external="Gau_External.ani" opt=(nomicro,modredundant)

a

0 1
C          1.00000        1.00000        0.00000
C         -0.47030        1.00000        0.00000
C          1.70660       -0.04310        0.63640
C          1.72220        2.03380       -0.63570
C         -1.31040       -0.15350       -0.00840
C         -1.21860        2.16320        0.01570
C         -2.65370        0.16440       -0.00170
H         -0.97350       -1.17980       -0.02650
S         -2.89780        1.85240        0.01810
H         -3.50400       -0.50190       -0.00860
H         -0.86940        3.18460        0.03890
C          3.11560       -0.05220        0.64030
H          1.16840       -0.83580        1.13420
C          3.82890        0.98260        0.00560
H          3.64800       -0.85300        1.13300
C          3.13120        2.02570       -0.63300
H          4.90970        0.97610        0.00800
H          3.67550        2.81930       -1.12410
H          1.19740        2.83220       -1.13860

D 3 1 2 5 -180.0 B
D 3 1 2 5 S 72 5.0 

</pre></code>
