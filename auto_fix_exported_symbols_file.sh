# EXPORTED_SYMBOLS_FILE="./Example/exported_symbols.txt"
# export VALID_ARCHS\=arm64\ arm64e\ armv7\ armv7s
# export SWIFT_INCLUDE_PATHS=\ \"~/Library/Developer/Xcode/DerivedData/SwiftFuckKit-xx/Build/Intermediates.noindex/ArchiveIntermediates/SwiftFuckKit-Example/BuildProductsPath/Release-iphoneos/DemoPodOne\"
#\ \"~/Library/Developer/Xcode/DerivedData/SwiftFuckKit-xx/Build/Intermediates.noindex/ArchiveIntermediates/SwiftFuckKit-Example/BuildProductsPath/Release-iphoneos/SwiftFuckKit\"

if [ -z $EXPORTED_SYMBOLS_FILE ]; then
    echo "No exported symbols file, exit."
    exit 0
fi

arch=($(echo $VALID_ARCHS | awk 'BEGIN{FS=" ";OFS=" "} {print $1}'))
swift_include_paths_trim_quota=($(echo $SWIFT_INCLUDE_PATHS | sed 's/\"//g'))
swift_pods=()
# Get all gaia symbol.
symbols=()
for swift_module_path in ${swift_include_paths_trim_quota[@]};
do
    pod_name=${swift_module_path##*/}
    swift_pods[${#swift_pods[@]}]=$pod_name
    echo $swift_module_path
    swift_interface_path="$swift_module_path/$pod_name.swiftmodule/$arch.swiftinterface"
    echo $swift_interface_path
    gaia_symbols_str=`cat $swift_interface_path | pcregrep -o "(?<=@_silgen_name\(\").*?(?=\"\))"`
    for str in ${gaia_symbols_str[@]};
    do
        symbols[${#symbols[@]}]="_$str"
    done
done

echo ${swift_pods[@]}
echo "symbols:"
echo ${symbols[@]}

unique_symbols=($(printf "%s\n" "${symbols[@]}" | sort -u))
echo "unique_symbols:"
echo ${unique_symbols[@]}


# Get original exported symbols.
exported_symbols=()

if [ -f $EXPORTED_SYMBOLS_FILE ]; then
    while read line
    do
        exported_symbols[${#exported_symbols[@]}]=$line
    done < $EXPORTED_SYMBOLS_FILE
fi

# Add gaia symbols into exported symbol file.
for var in ${unique_symbols[@]}
do
    if [[ "${exported_symbols[@]}" =~ "$var" ]]; then
        echo "$var exists."
    else 
        echo "$var added to the exported symbols file successfully."
        echo $var >> $EXPORTED_SYMBOLS_FILE
    fi
done
