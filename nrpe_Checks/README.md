#NRPE Checks
==========

We are using some NRPE-Checks for our Servers. I think it is greate to share this too:

###check_ms_win_DiskLoad.ps1
As the name mention. We check the Diskspace with this simple script. Warning/Error must be added as parameter.
Call it like:
    check_ms_win_DiskLoad.ps1 c: 97 99

###check_ms_win_memoryLoad.ps1
As the name mention. We check the Memory with this simple script. Warning is fixed by 90%. Error at 99%.
Call it like:
    check_ms_win_memoryLoad.ps1