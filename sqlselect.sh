##
## Selects out a result set as a CSV for a given input query.
## The script requires:
##      -s server
##      -o output file name
##      -q SQL query
##
## and assumes the user is a trusted connection (-E flag).
##
## The ~ character is used as a field seperator, so will fail on any dataset using this character.
## If this is the case, the use of this character can be chaged to one not used, on line 31 and 32.
##

while getopts ":s:o:q:" opt; do
  case $opt in
    s) server="$OPTARG"
    ;;
    o) output="$OPTARG"
    ;;
    q) query="$OPTARG"
    ;;
    \?) echo "Invalid option: -$OPTARG" >&2
    ;;
  esac
done

query="set nocount on; ${query}"
out="fmt_${output}"

$(sqlcmd -o "${output}" -j -E -S "${server}" -s '~' -W -Q "${query}")
$(cat $output | sed -b -E '/^\s*$/d; 2d; s/\xEF\xBB\xBF//; s/"/""/g; s/~/","/g; s/^/"/g; s/$/"/g' > $out)
$(rm $output)
