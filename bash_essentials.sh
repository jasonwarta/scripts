confirm () {
    read -r -p "${1:-Are you sure? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

function cleanup {
	exit
}

trap cleanup SIGHUP SIGINT SIGKILL SIGTERM SIGSTOP