#!/bin/bash -x

package=$1
if [[ -z "$package" ]]; then
  echo "usage: $0 <package-name>"
  exit 1
fi
package_split=(${package//\// })
package_name=${package_split[-1]}

#platforms=("windows/amd64" "windows/386" "darwin/amd64")
platforms=("windows/amd64")

for platform in "${platforms[@]}"
do
    platform_split=(${platform//\// })
    GOOS=${platform_split[0]}
    GOARCH=${platform_split[1]}
    CGO_ENABLED="1"
    GCC="/usr/bin/x86_64-w64-mingw32-gcc"
    GCC="/usr/bin/x86_64-w64-mingw32-gcc"
    CGO_LDFLAGS="-L/usr/local/ssl/lib"
    output_name=$package_name'-'$GOOS'-'$GOARCH
    if [ $GOOS = "windows" ]; then
        output_name+='.exe'
    fi  


    # GOARCH=386 CGO_ENABLED=1 CXX_FOR_TARGET=i686-w64-mingw32-g++ CC_FOR_TARGET=i686-w64-mingw32-gcc    CGO_LDFLAGS="-L/usr/local/ssl/lib -lcrypto -lws2_32 -lgdi32 -lcrypt32" CGO_CFLAGS=-I/usr/local/ssl/include go build

 
    #env GO_ENABLED=1 CGO_ENABLED="1" CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++ GOOS=windows GOARCH=amd64 go build -o $output_name $package
    env GO_ENABLED=1 GOOS=$GOOS GOARCH=$GOARCH CGO_ENABLED="1"  CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++ CXX_FOR_TARGET="/usr/bin/x86_64-w64-mingw32-g++" CC_FOR_TARGET="/usr/bin/x86_64-w64-mingw32-gcc" CGO_LDFLAGS="-L/usr/local/ssl/lib" CGO_CFLAGS="-I/usr/local/ssl/include" -std="c++11" go build -o $output_name $package

    env GOOS=$GOOS GOARCH=$GOARCH CGO_ENABLED="1"  CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++ CXX_FOR_TARGET="/usr/bin/x86_64-w64-mingw32-g++" CC_FOR_TARGET="/usr/bin/x86_64-w64-mingw32-gcc" CGO_LDFLAGS="-L/usr/local/ssl/lib" CGO_CFLAGS="-I/usr/local/ssl/include" -std="c++11" go build -o $output_name $package
    if [ $? -ne 0 ]; then
        echo 'An error has occurred! Aborting the script execution...'
        exit 1
    fi
done

