export LIBRARY_PATH=~/Desktop/mirrors-dev/dylib
export DYLD_FALLBACK_LIBRARY_PATH="$LIBRARY_PATH"

read -p "Compile before running? (y/n): " compile

if [ "$compile" = "y" ]; then
  crystal build ../src/mirrors.cr -o ../bin/mirrors --link-flags "-L." --release
  install_name_tool -change @rpath/libvoidcsfml-graphics.2.4.dylib @loader_path/../dylib/libvoidcsfml-graphics.2.4.dylib ../bin/mirrors
  install_name_tool -change @rpath/libvoidcsfml-window.2.4.dylib @loader_path/../dylib/libvoidcsfml-window.2.4.dylib ../bin/mirrors
  install_name_tool -change @rpath/libvoidcsfml-system.2.4.dylib @loader_path/../dylib/libvoidcsfml-system.2.4.dylib ../bin/mirrors
  install_name_tool -change /usr/lib/libpcre.0.dylib @loader_path/../dylib/libpcre.0.dylib ../bin/mirrors
  install_name_tool -change /usr/local/opt/bdw-gc/lib/libgc.1.dylib @loader_path/../dylib/libgc.1.dylib ../bin/mirrors
  install_name_tool -change /usr/local/opt/libevent/lib/libevent-2.1.6.dylib @loader_path/../dylib/libevent-2.1.6.dylib ../bin/mirrors
  install_name_tool -change /usr/lib/libiconv.2.dylib @loader_path/../dylib/libiconv.2.dylib ../bin/mirrors
  echo "Done compiling!"
fi

echo "Running!"
../bin/mirrors