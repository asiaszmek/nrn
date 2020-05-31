@echo on

:: install numpy dependency
python -m pip install numpy

:: download installer
pwsh -command Invoke-WebRequest -MaximumRetryCount 3 -OutFile nrn.exe https://github.com/pramodk/nrn/releases/download/nightly/nrn8.0setup-AMD64.exe
.\nrn.exe /S /D=C:\nrn_test

:: setup environment
dir C:\nrn_test
set PATH=C:\nrn_test\bin;%PATH%
set PYTHONPATH=C:\nrn_test\lib\python;%PYTHONPATH%
set NEURONHOME=C:\nrn_test

:: test all pythons
C:\Python27\python -c "import neuron; neuron.test(); neuron.test_rxd(); quit()" || goto :error
C:\Python35\python -c "import neuron; neuron.test(); neuron.test_rxd(); quit()" || goto :error
C:\Python36\python -c "import neuron; neuron.test(); neuron.test_rxd(); quit()" || goto :error
C:\Python37\python -c "import neuron; neuron.test(); neuron.test_rxd(); quit()" || goto :error
C:\Python38\python -c "import neuron; neuron.test(); neuron.test_rxd(); quit()" || goto :error

:: run also using whatever is system python
python --version
python -c "import neuron; neuron.test(); neuron.test_rxd(); quit()" || goto :error

:: test python and nrniv
python -c "from neuron import h; s = h.Section(); s.insert('hh'); quit()" || goto :error
nrniv -python -c "from neuron import h; s = h.Section(); s.insert('hh'); quit()" || goto :error

:: test mpi
mpiexec -n 2 nrniv %cd%\src\parallel\test0.hoc -mpi || goto :error
mpiexec -n 2 python %cd%\src\parallel\test0.py -mpi --expected-hosts 2 || goto :error

:: test mknrndll
set N=C:\nrn_test
set PATH=C:\nrn_test\mingw\usr\bin;%PATH%
copy /A share\examples\nrniv\nmodl\cacum.mod .
C:\nrn_test\mingw\usr\bin\bash -c "mknrndll" || goto :error
python -c "import neuron; from neuron import h; s = h.Section(); s.insert('cacum'); quit()" || goto :error

:: test of association with hoc files
del temp.txt
echo wopen("temp.txt") > .\temp.hoc
echo fprint("hello\n") >> .\temp.hoc
echo wopen() >> .\temp.hoc
echo quit() >> .\temp.hoc
start .\temp.hoc
::timeout /T 10
ping -n 5 127.0.0.1
cat temp.txt
findstr /i "^hello$" temp.txt || goto :error

echo "All tests finished!"

:: uninstall neuron
C:\nrn_test\uninstall /S || goto :error
echo "Uninstalled NEURON"

:: if all goes well, go to end
goto :EOF

:: something has failed, teminate with error code
:error
echo ERROR : exiting with error code %errorlevel%
exit /b %errorlevel%