#! /bin/bash

# Copyright 2017-present Cisco Systems, Inc.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Install the P4-16 (and also P4-14) compiler, but not the behavioral-model
# software packet forwarding program.

# You will likely need to enter your password for multiple uses of 'sudo'
# spread throughout this script.

# This script has been tested on a freshly installed Ubuntu 16.04
# system, from a file with this name: ubuntu-16.04.4-desktop-amd64.iso

# The maximum number of gcc/g++ jobs to run in parallel.  3 can easily
# take 1 to 1.5G of RAM, and the build will fail if you run out of RAM,
# so don't make this number huge on a machine with 4G of RAM, for example.
# 3 will work on a machine with 2 GB of RAM as long as you are not
# running any other processes using significant memory.
MAX_PARALLEL_JOBS=3

# Remember the current directory when the script was started:
INSTALL_DIR="${PWD}"

THIS_SCRIPT_FILE_MAYBE_RELATIVE="$0"
THIS_SCRIPT_DIR_MAYBE_RELATIVE="${THIS_SCRIPT_FILE_MAYBE_RELATIVE%/*}"
THIS_SCRIPT_DIR_ABSOLUTE=`readlink -f "${THIS_SCRIPT_DIR_MAYBE_RELATIVE}"`

echo "------------------------------------------------------------"
echo "Time and disk space used before installation begins:"
date
df -h .

# Install Ubuntu packages needed by protobuf v3.2.0, from its src/README.md
sudo apt-get --yes install autoconf automake libtool curl make g++ unzip
# Install Ubuntu dependencies needed by p4c, from its README.md
# Matches latest p4c README.md instructions as of 2018-Aug-13
sudo apt-get --yes install g++ git automake libtool libgc-dev bison flex libfl-dev libgmp-dev libboost-dev libboost-iostreams-dev libboost-graph-dev pkg-config python python-scapy python-ipaddr python-ply tcpdump cmake





echo "------------------------------------------------------------"
echo "Installing Google protobuf, needed for p4lang/p4c"
echo "start install protobuf:"
date

cd "${INSTALL_DIR}"
git clone https://github.com/google/protobuf
cd protobuf
# As of 2017-Dec-06, the p4lang/p4c README recommends v3.0.2 of protobuf.
#
# However, that version might not work with the latest version of
# p4lang/PI.
#
# This email message linked below suggests that v3.2.0 should soon
# become the recommended version for both p4lang/p4c and p4lang/PI.
#
# http://lists.p4.org/pipermail/p4-dev_lists.p4.org/2017-December/001655.html
#git checkout v3.0.2
git checkout v3.2.0
./autogen.sh
./configure
make
sudo make install
sudo ldconfig
# Save about 0.5G of storage by cleaning up protobuf build
make clean

echo "end install protobuf:"
date


echo "------------------------------------------------------------"
echo "Installing p4lang/p4c"
echo "start install p4c:"
date

cd "${INSTALL_DIR}"
# Clone p4c and its submodules:
git clone --recursive https://github.com/p4lang/p4c.git
cd p4c
mkdir build
cd build
# Configure for a debug build
cmake .. -DCMAKE_BUILD_TYPE=DEBUG $*
make -j${MAX_PARALLEL_JOBS}

echo "end install p4c:"
date

echo "------------------------------------------------------------"
echo "Time and disk space used when installation was complete:"
date
df -h .

P4C="${INSTALL_DIR}/p4c"
P4GUIDE_BIN="${THIS_SCRIPT_DIR_ABSOLUTE}"

echo ""
echo "You may wish to add lines like the ones below to your .bashrc or"
echo ".profile files in your home directory to add commands like p4c-bm2-ss"
echo "and simple_switch to your command path every time you log in or create"
echo "a new shell:"
echo ""
echo "P4C=\"${P4C}\""
echo "P4GUIDE_BIN=\"${P4GUIDE_BIN}\""
echo "export PATH=\"\$P4GUIDE_BIN:\$P4C/build:/usr/local/bin:\$PATH\""
echo ""
echo "If you use the tcsh or csh shells instead, the following lines can be"
echo "added to your .tcshrc or .cshrc file in your home directory:"
echo ""
echo "set P4C=\"${P4C}\""
echo "set P4GUIDE_BIN=\"${P4GUIDE_BIN}\""
echo "set path ( \$P4GUIDE_BIN \$P4C/build /usr/local/bin \$path )"
