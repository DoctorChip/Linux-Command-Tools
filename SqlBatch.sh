## Chunk a big list of commands into smaller commands, optionally passing a header and trailer to be
## ran before and after each chunk of commands.

DEFAULTCHUNK=1000;
SERVER_NAME="Vegan-Cookies";

# i is required, shown by the : following
# h and f are optional
# c is the chunk size
while getopts 'i:h:f:c:' flag; do
    case "${flag}" in
    i) INPUT=${OPTARG};;
    h) HEADER=${OPTARG};;
    f) FOOTER=${OPTARG};;
    c) CHUNKSIZE=${OPTARG};;
    esac
done

# If header or footer are files, read them into the vars
if [[ $HEADER != "" ]] && [ -r $HEADER ]; then
    echo ">> header is a file, reading..."
    HEADER=$(cat $HEADER)
fi

if [[ $FOOTER != "" ]] && [ -r $FOOTER ]; then
    echo ">> Footer is a file, reading..."
    FOOTER=$(cat $FOOTER)
fi

# Count how many lines we have
LINECOUNT=$(cat $INPUT | sed '/^\s*$/d' | wc -l)
echo ">> "$LINECOUNT" lines found in input, chunking into chunks of "${CHUNKSIZE:-$DEFAULTCHUNK}" lines..."

# Find how many batches we're going to need to do
((CHUNKCOUNT=$LINECOUNT/${CHUNKSIZE:-$DEFAULTCHUNK}+1))
echo ">> This will take "$CHUNKCOUNT" chunks. Continue? (Y/n)"
read  -n 1 CONTINUE_SELECTION

if [[ $CONTINUE_SELECTION == n ]]; then
    echo ""
    echo "Quitting..."
    exit
fi

echo ""
echo "Starting..."

# Iterate over...
for ((i=0; i<$CHUNKCOUNT;i++))
do
    SKIP=$(((${CHUNKSIZE:-$DEFAULTCHUNK}*$i)+1))
    SEDCMD='sed -n -e '$SKIP','$(($SKIP-1+${CHUNKSIZE:-$DEFAULTCHUNK}))'p '$INPUT
    LINES=$($SEDCMD)
    OUTPUT="$HEADER $LINES $FOOTER"
    r=$(sqlcmd -S $SERVER_NAME -E -Q "$OUTPUT")
    echo $r
done
