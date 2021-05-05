set -e

echo "****************************"
echo "* Building python_bindings"
echo "****************************"

mkdir -p build
cd build
cmake ../
make install
cd ..
