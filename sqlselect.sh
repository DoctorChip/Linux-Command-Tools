while getopts ":s:o:q:" opt; do
  case $opt in
    s) server="$OPTARG" >&2
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
$(cat $output | sed -b -E '/^\s*$/d; 2d; s/\xEF\xBB\xBF//; s/~/","/g; s/^/"/g; s/$/"/g' > $out)
$(rm $output)
