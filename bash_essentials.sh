# useful batch functions and scripts for use in a vareity of programs

# confirm function, takes y/n
confirm () {
    read -r -p "${1:-Are you sure? [y/N]} " response </dev/tty
    case $response in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}


# catches Ctrl+C and other kill commands
function cleanup {
	exit
}
trap cleanup SIGHUP SIGINT SIGKILL SIGTERM SIGSTOP


# option input for generic program
for i in "$@"; do
    case $i in
        -t=*|--title=*)
        title="${i#*=}"
        shift # past argument=value
        ;;
        -y=*|--year=*)
        year="${i#*=}"
        shift # past argument=value
        ;;
        -e=*|--extension=*)
        extension="${i#*=}"
        shift # past argument=value
        ;;
    esac
done