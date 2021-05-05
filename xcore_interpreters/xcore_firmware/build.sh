set -e

echo "****************************"
echo "* Building xcore_firmware"
echo "****************************"

mkdir -p build
cd build
cmake ../
make install
cd ..
