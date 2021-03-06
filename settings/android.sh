function pulldb() {
    adb shell ls /data/data|grep "$*"|dos2unix|while read package;do
    (
        local files=$(adb shell ls /data/data/$package/databases/|dos2unix|grep db$)
        [[ -n "$files" ]]  && echo "$files"|while read file;do adb pull /data/data/$package/databases/$file $package/$file;done
    );
    done
}

function pulllog() {
    adb shell ls /sdcard/\*.log\|grep "$*"|dos2unix|while read -r line;
    do
        local file="$line"
        local localFile=$(echo "$line"|sed 's/^\/sdcard\///g')
        (adb pull "$file" "$localFile" && adb shell rm "$file")
    done
}

function deletelog() {
    adb shell ls -al /sdcard/|dos2unix|grep '\b\<[0-9]\+\.\(log\|db\)$'|grep "$*"|while read -r line
    do
        local file=$(echo $line|sed -e 's/  / /g' -e 's/^.*[0-9]\{4,4\}-[0-9: \-]\{12,12\}//g')
        echo "delete $file ..."
        adb shell rm "/sdcard/$file"
    done
}

function lsdcard() {
    adb shell ls -al /sdcard/|dos2unix|grep '\b\<[0-9]\+.\(log\|db\)$'
}

function deletedb() {
    [[ -z "$*" ]] && echo "must specify package pattern" && kill -INT $$
    adb shell ls /data/data|grep "$*"|dos2unix|while read package;do
        echo "remove $package's database."
        adb shell rm -rf /data/data/$package/databases
    done
}

function useUSB() {
    export ANDROID_SERIAL=$(adb devices|awk '/device$/{print $1}'|grep -v -e ":5555" -v -e "emulator-")
}

function usblogcat() {
    (export ANDROID_SERIAL=$(adb devices|awk '/device$/{print $1}'|grep -v -e ":5555" -v -e "emulator-") && logcat "$*")
}

function useGenymotion() {
    export ANDROID_SERIAL=$(adb devices|awk '/device$/{print $1}'|grep -e ":5555" -e "emulator-")
}

function genymotionlogcat() {
    (export ANDROID_SERIAL=$(adb devices|awk '/device$/{print $1}'grep -e ":5555" -e "emulator-") && logcat "$*")
}

function syncAndroidDeviceTime() {
    local time=$(date '+%G%m%d.%H%M%S')
    adb shell "su 0 date -s $time"
}

function androidScreen() {
    adb shell screencap -p /sdcard/androidScreen.png
    adb pull /sdcard/androidScreen.png
    adb shell rm /sdcard/androidScreen.png
}

function device_proxy () {
    local BASEDIR="$HOME/.sys.config"
    local file=""
    [[ -d "$BASEDIR/bin" ]] || mkdir "$BASEDIR/bin"
    if [[ "x$1" = "xon" ]]; then
        file="$BASEDIR/bin/proxy_on"
    elif [[ "x$1" = "xoff" ]]; then
        file="$BASEDIR/bin/proxy_off"
    elif [[ "x$1" = "xbackup" ]]; then
        if [[ "x$2" == "xoff" ]]; then
            file="$BASEDIR/bin/proxy_off"
        else
            file="$BASEDIR/bin/proxy_on"
        fi
        echo "backup device proxy settings to $file"
        adb pull /data/misc/wifi/ipconfig.txt "$file"
        return 0
    fi
    if [[ -z "$file" ]]; then
        echo "Usage device_proxy [on|off|backup [on|off]]"
        kill -INT $$
    fi
    adb shell svc wifi disable
    adb push "$file" /data/misc/wifi/ipconfig.txt
    adb shell svc wifi enable
}

function akill() {
    adb shell ps\|grep "$1" | column 2| xargs adb shell kill
}
