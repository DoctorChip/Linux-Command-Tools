This is an (evergrowing) list of useful linux commands. To make the most use out of these on Windows, either install and use WSL (Windows Subsystem for Linux) and the Windows Store Ubuntu package, or use Git Bash, a shell you probably installed along with Git.

### Prepending / Appending to lines of a file with sed

The linux package sed is a stream editor, editing lines one at a time from a file or stdin.
Basic usage: `sed [options] commands [file-to-edit]`.

By default, sed will output to stdout unless told otherwise. You can redirect the output with a pipe operator if you wish, or with an arrow to save to a file: `sed commands input.txt > output.txt`.

Alternatively, sed can be ran in interactive mode with the -i flag, which will edit the file in place.
To prepend: `sed -i -e 's/^/[YOUR STRING HERE]/' input.txt`

This will add [YOUR STRING HERE] to the beginning of every line of the file. To append, simply change ^ to $.
Append: `sed -i -e 's/$/[YOUR STRING HERE]/' input.txt`





### Formatting a CSV as a SQL Statement

This method uses a number of different tools piped together to take a comma seperated list of parameters and output a SQL file as you wish.

An example:

```
cat CoNoUTR.csv | 
tr ',' ' ' | 
awk '{print "UPDATE c SET c.CorporationTaxReference = \x27"$2"\x27 FROM SMALive.dbo.Co
mpanies c WHERE c.CompanyNumber = \x27"$1"\x27;\r\n"}' > UpdateUTRs.sql
```

`cat`
cat is a basic tool for concatenating files together, but if we just pass one file it's a quick and easy way to get a file into a pipe, as we are doing here.

`tr`
tr (think translate) is a simple string replace tool. It accepts a string to search for and then a string to replace with. We're swapping the commas in the CSV with spaces. This means that the pipe operator will assign the variables $1, $2, $3... etc, to each of our columns. Without the tr step, the entire row will be assigned to $1.

`awk`
Awk is a very powerful text processing tool. It will take in from the pipe and allow you to apply conditions to the input and pass it to another command. In this case all we're doing is passing it to 'print', which allows us to just add in our variables ($1, $2, $3...) to our SQL statement!

`print`
The print command is very basic - it'll just print a list of strings, variables, etc... as one. Here, we're writing out SQL statement and adding in our CSV values ($1 and $2) to format the statement. It's important to note that any strings with spaces will need to be surrounded by double-quotes, as they are here. The code \x27 represents a single-quote, which our SQL commands need, but if used in their literal form would escape the awk command and break our chain.

finally, the output of the awk is sent to a .sql file with >.




### Stripping BOMs

When working with unix tools like sed, it can be common for nasty bom characters to appear.

To strip them out, you can just add on an additional argument to your sed call:
`-e 's/\xEF\xBB\xBF//'`

This will perform your sed command and then strip out any boms.





### Piping into SQL Server directly from the commandline

When working with large CSV files (500,000+ rows) that need to be imported into SQL Server, it can often be awkward to format them and run them in SSMS.

For cases like this, you can format your csv file using the above tips, and then save it out to a file. Take that file and pass it directly into SQL Server with this:

`sqlcmd -S SERVER_NAME -E -i input.sql`

Where `-S` is a flag for the server name, most likely your machine name.
`-E` specifies it's a trusted connection, and so you don't need login details.
`-i` is an input file. Similarly, if you want an output, you can use `-o`.
All params are case sensitive.



### Stripping blank lines from a file

To remove all blank lines from a file, that may include whitespace, sed can be used.

`sed -i '/^\s*$/d' input.file`

`^` means to begin at the start of the line.
`\s` means white-space, and * means any number of characters.
`$` means the end of the line.
`/d` tells sed to delete the line.

So, we're asking sed to delete the line where, from the start to the end of the line, the line contains only whitespace.



### Joining multiple files together

For joining multiple files, you can simply use `cat` (think concatenate). E.g.

`cat fileone.txt filetwo.txt > output.txt`


or

`cat *.txt > allfiles.txt`

However, this will not add anything inbetween the files. If for example you're joining text files that make up documentation into a single file, you can use `sed` - all glory to the power of `sed`!

`sed -e '$s/$/\n/' -s *.txt > final.txt`
This will add a \n to the end of each file in the collection of .txt files in the current directory, outputting to `final.txt`.
